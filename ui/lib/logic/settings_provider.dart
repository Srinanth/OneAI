import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError();
});

class SettingsState {
  final String geminiKey;
  final String deepSeekKey;

  SettingsState({this.geminiKey = '', this.deepSeekKey = ''});

  SettingsState copyWith({String? geminiKey, String? deepSeekKey}) {
    return SettingsState(
      geminiKey: geminiKey ?? this.geminiKey,
      deepSeekKey: deepSeekKey ?? this.deepSeekKey,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    // Access the service
    final storage = ref.watch(storageServiceProvider);
    
    return SettingsState(
      geminiKey: storage.getGeminiKey() ?? '',
      deepSeekKey: storage.getDeepSeekKey() ?? '',
    );
  }

  Future<void> saveKeys({String? gemini, String? deepSeek}) async {
    final storage = ref.read(storageServiceProvider);
    final currentState = state.value ?? SettingsState();
    var newState = currentState;

    if (gemini != null) {
      await storage.setGeminiKey(gemini);
      newState = newState.copyWith(geminiKey: gemini);
    }

    if (deepSeek != null) {
      await storage.setDeepSeekKey(deepSeek);
      newState = newState.copyWith(deepSeekKey: deepSeek);
    }

    state = AsyncValue.data(newState);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});