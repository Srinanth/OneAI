import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/storage_service.dart';

class SettingsState {
  final String geminiKey;
  final String deepSeekKey;
  final bool isDarkMode; //for later

  SettingsState({
    this.geminiKey = '',
    this.deepSeekKey = '',
    this.isDarkMode = false,
  });

  SettingsState copyWith({
    String? geminiKey,
    String? deepSeekKey,
    bool? isDarkMode,
  }) {
    return SettingsState(
      geminiKey: geminiKey ?? this.geminiKey,
      deepSeekKey: deepSeekKey ?? this.deepSeekKey,
      isDarkMode: isDarkMode ?? this.isDarkMode,
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
    
    return SettingsState(
      geminiKey: storage.getGeminiKey() ?? '',
      deepSeekKey: storage.getDeepSeekKey() ?? '',
      isDarkMode: storage.isDarkMode,
    );
  }

  Future<void> saveKeys({required String gemini, required String deepSeek}) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setGeminiKey(gemini);
    await storage.setDeepSeekKey(deepSeek);
    
    state = state.copyWith(geminiKey: gemini, deepSeekKey: deepSeek);
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