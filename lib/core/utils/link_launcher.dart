import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_info.dart';
import 'file_download_stub.dart'
    if (dart.library.js_interop) 'file_download_web.dart'
    as download;

abstract final class LinkLauncher {
  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      final external = uri.scheme == 'http' || uri.scheme == 'https';
      return await launchUrl(
        uri,
        mode: external
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
        webOnlyWindowName: external ? '_blank' : '_self',
      );
    } catch (e) {
      debugPrint('Could not open $url: $e');
      return false;
    }
  }

  static Future<bool> email({String? subject}) {
    final query = subject == null
        ? ''
        : '?subject=${Uri.encodeComponent(subject)}';
    return open('${AppInfo.emailUri}$query');
  }

  static Future<bool> phone() => open(AppInfo.phoneUri);
  static Future<bool> linkedIn() => open(AppInfo.linkedInUrl);
  static Future<bool> gitHub() => open(AppInfo.gitHubUrl);

  /// Downloads the original resume PDF. On the web this uses an anchor with
  /// the `download` attribute, which works on desktop and mobile browsers.
  static Future<bool> downloadResume() async {
    if (download.downloadFile(AppInfo.resumePath, AppInfo.resumeFileName)) {
      return true;
    }
    return open(AppInfo.resumePath);
  }
}
