import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String geminiKey;
  final String deepSeekKey;
  final bool isLoading;

  SettingsState({
    this.geminiKey = '',
    this.deepSeekKey = '',
    this.isLoading = true,
  });

  SettingsState copyWith({String? geminiKey, String? deepSeekKey, bool? isLoading}) {
    return SettingsState(
      geminiKey: geminiKey ?? this.geminiKey,
      deepSeekKey: deepSeekKey ?? this.deepSeekKey,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      geminiKey: prefs.getString('gemini_key') ?? '',
      deepSeekKey: prefs.getString('deepseek_key') ?? '',
      isLoading: false,
    );
  }

  Future<void> saveKeys({String? gemini, String? deepSeek}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (gemini != null) {
      await prefs.setString('gemini_key', gemini);
      state = state.copyWith(geminiKey: gemini);
    }
    
    if (deepSeek != null) {
      await prefs.setString('deepseek_key', deepSeek);
      state = state.copyWith(deepSeekKey: deepSeek);
    }
  }
  
  String getKeyForModel(String modelId) {
    if (modelId.startsWith('deepseek')) return state.deepSeekKey;
    return state.geminiKey; 
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((_) {
  return SettingsNotifier();
});