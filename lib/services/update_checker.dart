import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Info about an available update, surfaced when a newer tagged release
/// exists on GitHub than the version currently installed.
class UpdateInfo {
  final String latestVersion;
  final String releaseUrl;
  final String? windowsDownloadUrl;

  const UpdateInfo({
    required this.latestVersion,
    required this.releaseUrl,
    this.windowsDownloadUrl,
  });
}

/// Checks GitHub's public "latest release" endpoint for a newer tagged
/// version than the one currently running. The only network call the app
/// ever makes - a single passive GET, nothing about the user is sent.
/// Returns null on any failure (offline, rate limit, no release yet) -
/// silent by design so a flaky connection never disrupts the app.
Future<UpdateInfo?> checkForUpdate() async {
  try {
    final response = await http
        .get(
          Uri.parse(
            'https://api.github.com/repos/zJeremi3-dev/dev_tools/releases/latest',
          ),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = (json['tag_name'] as String?)?.replaceFirst('v', '');
    final url = json['html_url'] as String?;
    if (tag == null || url == null) return null;

    final current = (await PackageInfo.fromPlatform()).version;
    if (!_isNewer(tag, current)) return null;

    final assets = (json['assets'] as List<dynamic>?) ?? [];
    String? windowsUrl;
    for (final a in assets) {
      final asset = a as Map<String, dynamic>;
      if ((asset['name'] as String).endsWith('.exe')) {
        windowsUrl = asset['browser_download_url'] as String?;
        break;
      }
    }

    return UpdateInfo(
      latestVersion: tag,
      releaseUrl: url,
      windowsDownloadUrl: windowsUrl,
    );
  } catch (_) {
    return null;
  }
}

bool _isNewer(String latest, String current) {
  final l = latest.split('.').map(int.parse).toList();
  final c = current.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    final lv = i < l.length ? l[i] : 0;
    final cv = i < c.length ? c[i] : 0;
    if (lv != cv) return lv > cv;
  }
  return false;
}
