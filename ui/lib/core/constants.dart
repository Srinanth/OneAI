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
    'ChatGPT': ['openai/gpt-4o', 'openai/gpt-4o-mini'],
    'Claude': ['anthropic/claude-3-5-sonnet', 'anthropic/claude-3-5-haiku'],
    'Grok': ['xai/grok-2', 'xai/grok-beta'],
  };

  static const Map<String, ModelMetadata> modelRegistry = {
    // Gemini
    'gemini-2.5-flash': ModelMetadata(displayName: 'Gemini 2.5 Flash', provider: 'Gemini', maxTokens: 1000000),
    'gemini-3-pro-preview': ModelMetadata(displayName: 'Gemini 3 Pro', provider: 'Gemini', maxTokens: 250000),
    'gemini-2-flash': ModelMetadata(displayName: 'Gemini 2 Flash', provider: 'Gemini', maxTokens: 1000000),
    
    // DeepSeek
    'deepseek/deepseek-chat': ModelMetadata(displayName: 'DeepSeek V3', provider: 'DeepSeek', maxTokens: 500000),
    'deepseek/deepseek-reasoner': ModelMetadata(displayName: 'DeepSeek R1', provider: 'DeepSeek', maxTokens: 200000),
    
    // ChatGPT
    'openai/gpt-4o': ModelMetadata(displayName: 'GPT-4o', provider: 'ChatGPT', maxTokens: 100000),
    'openai/gpt-4o-mini': ModelMetadata(displayName: 'GPT-4o Mini', provider: 'ChatGPT', maxTokens: 500000),

    // Claude
    'anthropic/claude-3-5-sonnet': ModelMetadata(displayName: 'Claude 3.5 Sonnet', provider: 'Claude', maxTokens: 50000),
    'anthropic/claude-3-5-haiku': ModelMetadata(displayName: 'Claude 3.5 Haiku', provider: 'Claude', maxTokens: 300000),

    // Grok
    'xai/grok-2': ModelMetadata(displayName: 'Grok 2', provider: 'Grok', maxTokens: 100000),
    'xai/grok-beta': ModelMetadata(displayName: 'Grok Beta', provider: 'Grok', maxTokens: 200000),
  };

  static const List<String> supportedModels = [
    'Gemini', 
    'DeepSeek', 
    'ChatGPT', 
    'Claude', 
    'Grok'
  ];

  static int getLimitForModel(String? modelId) {
    if (modelId == null) return 50000;
    return modelRegistry[modelId]?.maxTokens ?? 50000;
  }

  static String getDisplayName(String modelId) {
    return modelRegistry[modelId]?.displayName ?? modelId;
  }
}