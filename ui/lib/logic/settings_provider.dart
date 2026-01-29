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

  SettingsState({
    this.geminiKey = '',
    this.selectedGemini = 'gemini-2.5-flash',
    this.deepSeekKey = '',
    this.selectedDeepSeek = 'deepseek/deepseek-chat',
    this.openRouterKey = '',
    this.selectedOpenRouter = 'openai/gpt-5-chat',
    required this.isDarkMode,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? geminiKey,
    String? selectedGemini,
    String? deepSeekKey,
    String? selectedDeepSeek,
    String? openRouterKey,
    String? selectedOpenRouter,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      geminiKey: geminiKey ?? this.geminiKey,
      selectedGemini: selectedGemini ?? this.selectedGemini,
      deepSeekKey: deepSeekKey ?? this.deepSeekKey,
      selectedDeepSeek: selectedDeepSeek ?? this.selectedDeepSeek,
      openRouterKey: openRouterKey ?? this.openRouterKey,
      selectedOpenRouter: selectedOpenRouter ?? this.selectedOpenRouter,
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
    
    final storedGemini = storage.getGeminiModel();
    final safeGemini = AppConstants.modelFamilies['Gemini']!.contains(storedGemini) 
        ? storedGemini 
        : AppConstants.modelFamilies['Gemini']!.first;

    return SettingsState(
      isDarkMode: storage.isDarkMode,
      geminiKey: storage.getGeminiKey() ?? '',
      selectedGemini: safeGemini,
      deepSeekKey: storage.getDeepSeekKey() ?? '',
      selectedDeepSeek: storage.getDeepSeekModel(),
      openRouterKey: storage.getOpenRouterKey() ?? '',
      selectedOpenRouter: storage.getOpenRouterModel(),
    );
  }

  Future<void> saveProviderSettings(String provider, String key, String model) async {
    final storage = ref.read(storageServiceProvider);
    
    await storage.setKeys(
      gemini: provider == 'Gemini' ? key : null,
      deepseek: provider == 'DeepSeek' ? key : null,
      chatgpt: provider == 'ChatGPT' ? key : null, 
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