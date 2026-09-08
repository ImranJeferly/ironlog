import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/haptics.dart';

/// Result of a finished recording.
class VoiceClip {
  const VoiceClip({required this.bytes, required this.durationMs});

  final Uint8List bytes;
  final int durationMs;
}

/// Records a short AAC clip. Low bitrate on purpose — it has to fit inline in
/// a Firestore document.
class VoiceRecorder {
  final _rec = AudioRecorder();
  DateTime? _startedAt;
  String? _path;

  /// Longest clip we'll accept (keeps the blob well under the 1 MiB cap).
  static const maxDuration = Duration(seconds: 90);

  bool get isRecording => _startedAt != null;

  Duration get elapsed =>
      _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);

  Future<bool> start() async {
    if (!await _rec.hasPermission()) return false;
    final dir = await getTemporaryDirectory();
    _path = p.join(
      dir.path,
      'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    await _rec.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 32000,
        sampleRate: 22050,
        numChannels: 1,
      ),
      path: _path!,
    );
    _startedAt = DateTime.now();
    return true;
  }

  Future<VoiceClip?> stop() async {
    final startedAt = _startedAt;
    _startedAt = null;
    final path = await _rec.stop();
    if (startedAt == null || path == null) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    unawaited(file.delete().catchError((_) => file));
    final ms = DateTime.now().difference(startedAt).inMilliseconds;
    if (ms < 700 || bytes.isEmpty) return null;
    return VoiceClip(bytes: bytes, durationMs: ms);
  }

  Future<void> cancel() async {
    _startedAt = null;
    try {
      final path = await _rec.stop();
      if (path != null) unawaited(File(path).delete().catchError((_) => File(path)));
    } on Object {
      // Nothing to cancel.
    }
  }

  void dispose() {
    _rec.dispose();
  }
}

/// Inline player for a voice-note bubble: play/pause, progress, duration.
class VoiceNotePlayer extends StatefulWidget {
  const VoiceNotePlayer({
    super.key,
    required this.bytes,
    required this.durationMs,
    this.mine = false,
  });

  final Uint8List bytes;
  final int durationMs;
  final bool mine;

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  bool _playing = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _stateSub = _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() {
        _playing = s == PlayerState.playing;
        if (s == PlayerState.completed) _position = Duration.zero;
      });
    });
    _posSub = _player.onPositionChanged.listen((d) {
      if (mounted) setState(() => _position = d);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    Haptics.tick();
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play(BytesSource(widget.bytes, mimeType: 'audio/mp4'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = Duration(milliseconds: widget.durationMs);
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final fg = AppColors.textPrimary;
    final track = widget.mine
        ? AppColors.textPrimary.withValues(alpha: 0.25)
        : AppColors.borderStrong;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.mine ? AppColors.textPrimary : AppColors.accent,
            ),
            child: Icon(
              _playing ? Icons.pause : Icons.play_arrow,
              size: 20,
              color: widget.mine ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 6,
                child: LayoutBuilder(
                  builder: (context, c) => Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: track,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Container(
                        width: c.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: fg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _playing ? Fmt.clock(_position) : Fmt.clock(total),
                style: AppText.numeric(
                  size: 11,
                  letterSpacing: 0,
                  color: widget.mine
                      ? AppColors.textPrimary.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
