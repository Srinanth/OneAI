import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
  class ModelMetadata {
  final String displayName;
  final String provider;
  final int maxTokens;

  const ModelMetadata({
    required this.displayName,
    required this.provider,
    required this.maxTokens,
  });
}
class AppConstants {
  static String get apiBaseUrl {
    final hostedUrl = dotenv.env['BACKEND_URL'];
    if (hostedUrl != null && hostedUrl.isNotEmpty) {
      return '$hostedUrl/api';
    }

    final port = dotenv.env['BACKEND_PORT'] ?? '6767';
    
    if (Platform.isAndroid) {
      return 'http://192.168.31.142:$port/api';
    }
    return 'http://localhost:$port/api';
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
  
  static const Map<String, List<String>> modelFamilies = {
    'Gemini': ['gemini-2.5-flash', 'gemini-3-pro-preview', 'gemini-2-flash'],
    'DeepSeek': ['deepseek/deepseek-chat', 'deepseek/deepseek-reasoner'],
    'ChatGPT': ['openai/gpt-5-chat', 'openai/gpt-5-pro'],
  };

  static const Map<String, ModelMetadata> modelRegistry = {
    'gemini-2.5-flash': ModelMetadata(displayName: 'Gemini 2.5 Flash', provider: 'Gemini', maxTokens: 100000),
    'gemini-3-pro-preview': ModelMetadata(displayName: 'Gemini 3 Pro', provider: 'Gemini', maxTokens: 3000000),
    'deepseek/deepseek-chat': ModelMetadata(displayName: 'DeepSeek Chat', provider: 'DeepSeek', maxTokens: 15000),
    'openai/gpt-5-chat': ModelMetadata(displayName: 'GPT-5 Chat', provider: 'ChatGPT', maxTokens: 10000),
    'openai/gpt-5-pro': ModelMetadata(displayName: 'GPT-5 Pro', provider: 'ChatGPT', maxTokens: 5000),
  };

  static const List<String> supportedModels = ['Gemini', 'DeepSeek', 'ChatGPT'];

  static int getLimitForModel(String? modelId) {
    if (modelId == null) return 100000;
    return modelRegistry[modelId]?.maxTokens ?? 100000;
  }

  static String getDisplayName(String modelId) {
    return modelRegistry[modelId]?.displayName ?? modelId;
  }
}