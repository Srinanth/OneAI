import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get apiBaseUrl {
    final port = dotenv.env['BACKEND_PORT'] ?? '6767';
    
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port';
    }
    return 'http://localhost:$port';
  }

  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in .env');
    }
    return url;
  }

  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in .env');
    }
    return key;
  }
  
  static const List<String> supportedModels = [
    'gemini-1.5-flash',
    'deepseek/deepseek-chat',
  ];
}