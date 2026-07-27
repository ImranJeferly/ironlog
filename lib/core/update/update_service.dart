import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// A newer build available on GitHub releases.
class UpdateInfo {
  const UpdateInfo({
    required this.buildNumber,
    required this.versionName,
    required this.apkUrl,
    required this.notes,
  });

  final int buildNumber;
  final String versionName;
  final String apkUrl;
  final String notes;
}

/// Checks this (public) repo's GitHub releases for a newer APK and installs it.
///
/// The repo is public, so the releases API and the APK asset download need no
/// token. CI tags each build `apk-build-<n>` where `<n>` is both the release
/// number and the app's `versionCode`, so comparing is a plain integer check.
class UpdateService {
  static const _owner = 'ImranJeferly';
  static const _repo = 'ironlog';
  static const _apiBase = 'https://api.github.com/repos/$_owner/$_repo';

  bool get isSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } on Object {
      return false;
    }
  }

  Future<int> currentBuildNumber() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return int.tryParse(info.buildNumber) ?? 0;
    } on Object {
      return 0;
    }
  }

  Future<String> currentVersionName() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } on Object {
      return '';
    }
  }

  /// The newest release with a higher build than the one installed, or null
  /// when already up to date / offline / unsupported.
  Future<UpdateInfo?> checkForUpdate() async {
    if (!isSupported) return null;
    try {
      final current = await currentBuildNumber();
      final releases = await _getJson('$_apiBase/releases?per_page=30');
      if (releases is! List) return null;

      UpdateInfo? best;
      for (final r in releases) {
        if (r is! Map) continue;
        if (r['draft'] == true) continue;
        final build = _buildFromTag('${r['tag_name'] ?? ''}');
        if (build == null || build <= current) continue;

        final apk = _firstApkUrl(r['assets']);
        if (apk == null) continue;

        if (best == null || build > best.buildNumber) {
          best = UpdateInfo(
            buildNumber: build,
            versionName: '${r['name'] ?? r['tag_name'] ?? 'build $build'}',
            apkUrl: apk,
            notes: '${r['body'] ?? ''}',
          );
        }
      }
      return best;
    } on Object catch (e) {
      debugPrint('IronLog: update check failed ($e)');
      return null;
    }
  }

  /// Downloads the APK to temp storage and hands it to the system installer.
  /// [onProgress] receives a 0..1 fraction when the size is known.
  Future<bool> downloadAndInstall(
    UpdateInfo info, {
    void Function(double)? onProgress,
  }) async {
    if (!isSupported) return false;
    final client = HttpClient();
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/IronLog-${info.buildNumber}.apk');

      final req = await client.getUrl(Uri.parse(info.apkUrl));
      req.headers.set(HttpHeaders.userAgentHeader, 'IronLog-App');
      final resp = await req.close();
      if (resp.statusCode != 200) return false;

      final total = resp.contentLength;
      final sink = file.openWrite();
      var received = 0;
      await for (final chunk in resp) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
      await sink.flush();
      await sink.close();

      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );
      return result.type == ResultType.done;
    } on Object catch (e) {
      debugPrint('IronLog: update download failed ($e)');
      return false;
    } finally {
      client.close();
    }
  }

  int? _buildFromTag(String tag) {
    final m = RegExp(r'(\d+)\s*$').firstMatch(tag);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  String? _firstApkUrl(Object? assets) {
    if (assets is! List) return null;
    for (final a in assets) {
      if (a is Map &&
          '${a['name'] ?? ''}'.toLowerCase().endsWith('.apk')) {
        final url = '${a['browser_download_url'] ?? ''}';
        if (url.isNotEmpty) return url;
      }
    }
    return null;
  }

  Future<Object?> _getJson(String url) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.userAgentHeader, 'IronLog-App');
      req.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      final resp = await req.close();
      if (resp.statusCode != 200) return null;
      final body = await resp.transform(utf8.decoder).join();
      return jsonDecode(body);
    } finally {
      client.close();
    }
  }
}
