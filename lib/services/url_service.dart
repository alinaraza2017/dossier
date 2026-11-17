import 'package:url_launcher/url_launcher.dart';

class UrlService {
  UrlService._();

  static Future<bool> openUrl(String rawUrl) async {
    try {
      var trimmed = rawUrl.trim();
      if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
        trimmed = 'https://$trimmed';
      }

      final uri = Uri.tryParse(trimmed);
      if (uri == null) return false;

      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
