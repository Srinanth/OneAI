import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ModelMetadata {
  final int maxTokens;
  final String displayName;

  const ModelMetadata({required this.maxTokens, required this.displayName});
}

class AppConstants {
  static String get apiBaseUrl {
    final port = dotenv.env['BACKEND_PORT'] ?? '6767';
    
    if (Platform.isAndroid) {
      return 'http://192.168.31.142:$port/api';
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
    'gemini-2.5-flash',
    'deepseek/deepseek-chat',
  ];

  static const Map<String, ModelMetadata> modelRegistry = {
    'gemini-2.5-flash': ModelMetadata(
      maxTokens: 100000, 
      displayName: 'Gemini 1.5 Flash',
    ),
    'deepseek/deepseek-chat': ModelMetadata(
      maxTokens: 5000,    // for sample usage,just for now
      displayName: 'DeepSeek Chat',
    ),
  };

  static int getLimitForModel(String? modelId) {
    if (modelId == null) return 100000;
    return modelRegistry[modelId]?.maxTokens ?? 100000;
  }

  static String getDisplayName(String modelId) {
    return modelRegistry[modelId]?.displayName ?? modelId;
  }
}