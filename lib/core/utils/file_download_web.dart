import 'package:web/web.dart' as web;

/// Triggers a browser download of a file served next to the app.
bool downloadFile(String path, String fileName) {
  try {
    final anchor = web.HTMLAnchorElement()
      ..href = path
      ..download = fileName
      ..rel = 'noopener'
      ..style.display = 'none';
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return true;
  } catch (_) {
    return false;
  }
}
