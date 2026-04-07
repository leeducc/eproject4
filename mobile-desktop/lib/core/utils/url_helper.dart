import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlHelper {
  static String fixMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    
    
    
    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? 'http://10.0.2.2:8123';
    
    
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    return '$baseUrl$cleanUrl';
  }
}