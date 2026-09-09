import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/now_playing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../settings/settings_widgets.dart';
import 'avatar.dart';

/// Edit what friends see: photo, name, @handle, bio, and whether the phone's
/// now-playing is shared.
class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const MyProfileScreen()),
  );

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  final _name = TextEditingController();
  final _handle = TextEditingController();
  final _bio = TextEditingController();
  bool _seeded = false;
  bool _busy = false;
  String? _handleMessage;
  bool _nowPlayingAccess = false;

  @override
  void initState() {
    super.initState();
    _refreshAccess();
  }

  Future<void> _refreshAccess() async {
    final np = await NowPlayingService.hasAccess();
    if (!mounted) return;
    setState(() => _nowPlayingAccess = np);
  }

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _savePhoto({required bool fromCamera}) async {
    setState(() => _busy = true);
    try {
      final file = await ref
          .read(photoRepositoryProvider)
          .pick(fromCamera: fromCamera);
      if (file == null) return;
      // Small and square-ish: an avatar, not a progress photo. Uploaded to
      // Storage under profiles/{uid}/avatar.jpg.
      final bytes = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 512,
        minHeight: 512,
        quality: 80,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (bytes == null) {
        _toast('Could not read that image.');
        return;
      }
      if (!mounted) return;
      final error = await ref
          .read(socialRepositoryProvider)
          .setPhoto(Uint8List.fromList(bytes));
      if (error != null) _toast(error);
    } on Object catch (e) {
      _toast('Photo failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _busy = true);
    try {
      final error = await ref.read(socialRepositoryProvider).setPhoto(null);
      if (error != null) _toast(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveText() async {
    setState(() => _busy = true);
    await ref
        .read(socialRepositoryProvider)
        .updateProfile(displayName: _name.text, bio: _bio.text);
    // An empty handle field means "leave it" — the profile bootstrap assigns
    // one automatically, so saving just the name must not complain.
    final error = _handle.text.trim().isEmpty
        ? null
        : await ref.read(socialRepositoryProvider).setHandle(_handle.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _handleMessage = error ?? 'Saved.';
    });
    if (error == null) FocusScope.of(context).unfocus();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(myProfileProvider).value;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    if (profile != null && !_seeded) {
      _seeded = true;
      _name.text = profile.displayName;
      _handle.text = profile.handle ?? '';
      _bio.text = profile.bio ?? '';
    }
    // The auto-assigned handle can land after the first frame; show it
    // rather than an empty field the user thinks they still have to fill.
    if (profile?.handle != null && _handle.text.trim().isEmpty) {
      _handle.text = profile!.handle!;
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('My profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          Center(
            child: Column(
              children: [
                Avatar(
                  initial: profile?.initial ?? '?',
                  photo: profile?.photo, photoUrl: profile?.photoUrl,
                  size: 112,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GhostButton(
                      label: 'Camera',
                      icon: Icons.photo_camera_outlined,
                      height: 40,
                      onPressed: _busy ? null : () => _savePhoto(fromCamera: true),
                    ),
                    const SizedBox(width: 8),
                    GhostButton(
                      label: 'Gallery',
                      icon: Icons.photo_library_outlined,
                      height: 40,
                      onPressed: _busy
                          ? null
                          : () => _savePhoto(fromCamera: false),
                    ),
                    if (profile?.photoUrl != null ||
                        profile?.photo != null) ...[
                      const SizedBox(width: 8),
                      IconPill(
                        icon: Icons.delete_outline,
                        color: AppColors.danger,
                        tooltip: 'Remove photo',
                        onTap: _busy ? null : _removePhoto,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Friends see it on your profile and in chats.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const SectionHeader('About you'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Display name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _handle,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_@]')),
                    LengthLimitingTextInputFormatter(21),
                  ],
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'handle (how friends find you)',
                    prefixIcon: Icon(Icons.alternate_email, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _bio,
                  maxLines: 2,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Bio — goal, gym, whatever',
                    prefixIcon: Icon(Icons.edit_note, size: 20),
                    counterText: '',
                  ),
                ),
                if (_handleMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _handleMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _handleMessage == 'Saved.'
                          ? AppColors.accent
                          : AppColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                VoltButton(
                  label: _busy ? 'Saving…' : 'Save',
                  icon: Icons.check_rounded,
                  height: 48,
                  onPressed: _busy ? null : _saveText,
                ),
              ],
            ),
          ),

          const SectionHeader('Now playing'),
          AppCard(
            child: Column(
              children: [
                SettingsSwitchRow(
                  title: 'Share what I’m listening to',
                  subtitle:
                      'Friends see the current track on your profile and in '
                      'the chat header.',
                  value: settings.shareNowPlaying,
                  onChanged: (v) async {
                    await controller.setShareNowPlaying(v);
                    if (!mounted) return;
                    await ref.read(socialHooksProvider).publishNowPlaying();
                  },
                ),
                const Divider(height: AppSpacing.lg),
                _AccessRow(
                  granted: _nowPlayingAccess,
                  title: _nowPlayingAccess
                      ? 'Media access granted'
                      : 'Media access needed',
                  body:
                      'Android calls it “notification access” — it’s how apps '
                      'read the current track. IronLog never reads '
                      'notification content.',
                  action: _nowPlayingAccess ? 'Re-check' : 'Grant',
                  onTap: () async {
                    if (!_nowPlayingAccess) {
                      await NowPlayingService.requestAccess();
                    }
                    await _refreshAccess();
                    if (!mounted) return;
                    await ref.read(socialHooksProvider).publishNowPlaying();
                  },
                ),
              ],
            ),
          ),

          if (profile != null) ...[
            const SectionHeader('What friends see'),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _Peek(
                      value: '${profile.stats.sessions}',
                      label: 'Sessions',
                    ),
                  ),
                  Expanded(
                    child: _Peek(
                      value: '${profile.stats.streak}',
                      label: 'Streak',
                    ),
                  ),
                  Expanded(
                    child: _Peek(value: '${profile.stats.prs}', label: 'PRs'),
                  ),
                  Expanded(
                    child: _Peek(
                      value: Fmt.percent(profile.stats.adherence4w),
                      label: '4-week',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Status line + button for a system permission we can only ask for by
/// sending the user to a settings screen.
class _AccessRow extends StatelessWidget {
  const _AccessRow({
    required this.granted,
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
  });

  final bool granted;
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          granted ? Icons.check_circle_outline : Icons.error_outline,
          size: 17,
          color: granted ? AppColors.accent : AppColors.danger,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(body, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GhostButton(label: action, height: 40, onPressed: onTap),
      ],
    );
  }
}

class _Peek extends StatelessWidget {
  const _Peek({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.numeric(size: 18)),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
