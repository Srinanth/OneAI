import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/core/constants.dart';
import '../data/services/storage_service.dart';

class SettingsState {
  final bool isDarkMode;
  
  final String geminiKey;
  final String selectedGemini;
  
  final String deepSeekKey;
  final String selectedDeepSeek;
  
  final String openRouterKey;
  final String selectedOpenRouter;
  
  final String claudeKey;
  final String selectedClaude;
  
  final String grokKey;
  final String selectedGrok;

  SettingsState({
    required this.isDarkMode,
    this.geminiKey = '',
    this.selectedGemini = 'gemini-2.5-flash',
    this.deepSeekKey = '',
    this.selectedDeepSeek = 'deepseek/deepseek-chat',
    this.openRouterKey = '',
    this.selectedOpenRouter = 'openai/gpt-4o',
    this.claudeKey = '',
    this.selectedClaude = 'anthropic/claude-3-haiku',
    this.grokKey = '',
    this.selectedGrok = 'xai/grok-beta',
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? geminiKey,
    String? selectedGemini,
    String? deepSeekKey,
    String? selectedDeepSeek,
    String? openRouterKey,
    String? selectedOpenRouter,
    String? claudeKey,
    String? selectedClaude,
    String? grokKey,
    String? selectedGrok,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      geminiKey: geminiKey ?? this.geminiKey,
      selectedGemini: selectedGemini ?? this.selectedGemini,
      deepSeekKey: deepSeekKey ?? this.deepSeekKey,
      selectedDeepSeek: selectedDeepSeek ?? this.selectedDeepSeek,
      openRouterKey: openRouterKey ?? this.openRouterKey,
      selectedOpenRouter: selectedOpenRouter ?? this.selectedOpenRouter,
      claudeKey: claudeKey ?? this.claudeKey,
      selectedClaude: selectedClaude ?? this.selectedClaude,
      grokKey: grokKey ?? this.grokKey,
      selectedGrok: selectedGrok ?? this.selectedGrok,
    );
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(); 
});

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final storage = ref.watch(storageServiceProvider);

    String getSafeModel(String? storedModel, String providerName) {
      final family = AppConstants.modelFamilies[providerName];
      if (family == null || family.isEmpty) return storedModel ?? '';
      return family.contains(storedModel) ? storedModel! : family.first;
    }

    return SettingsState(
      isDarkMode: storage.isDarkMode,
      
      geminiKey: storage.getGeminiKey() ?? '',
      selectedGemini: getSafeModel(storage.getGeminiModel(), 'Gemini'),
      
      deepSeekKey: storage.getDeepSeekKey() ?? '',
      selectedDeepSeek: getSafeModel(storage.getDeepSeekModel(), 'DeepSeek'),
      
      openRouterKey: storage.getOpenRouterKey() ?? '',
      selectedOpenRouter: getSafeModel(storage.getOpenRouterModel(), 'ChatGPT'),
      
      claudeKey: storage.getClaudeKey() ?? '',
      selectedClaude: getSafeModel(storage.getClaudeModel(), 'Claude'),
      
      grokKey: storage.getGrokKey() ?? '',
      selectedGrok: getSafeModel(storage.getGrokModel(), 'Grok'),
    );
  }

  Future<void> saveProviderSettings(String provider, String key, String model) async {
    final storage = ref.read(storageServiceProvider);
    

    await storage.setKeys(
      gemini: provider == 'Gemini' ? key : null,
      deepseek: provider == 'DeepSeek' ? key : null,
      chatgpt: provider == 'ChatGPT' ? key : null, 
      claude: provider == 'Claude' ? key : null,
      grok: provider == 'Grok' ? key : null,
    );
    
    await storage.setModel(provider, model);
    
    ref.invalidateSelf(); 
  }

  Future<void> toggleTheme(bool isDark) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setDarkMode(isDark);
    state = state.copyWith(isDarkMode: isDark);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});