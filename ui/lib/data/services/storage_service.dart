import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences prefs;

  StorageService(this.prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  static const String geminiKey = 'gemini_key';
  static const String geminiModel = 'gemini_model';
  static const String deepSeekKey = 'deepseek_key';
  static const String deepSeekModel = 'deepseek_model';
  static const String openRouterKey = 'openrouter_key';
  static const String openRouterModel = 'chatgpt_model';
  static const String theme = 'theme_mode';


  String? getGeminiKey() => prefs.getString(geminiKey);
  String getGeminiModel() => prefs.getString(geminiModel) ?? 'gemini-2.5-flash';
  
  String? getDeepSeekKey() => prefs.getString(deepSeekKey);
  String getDeepSeekModel() => prefs.getString(deepSeekModel) ?? 'deepseek/deepseek-chat';

  String? getOpenRouterKey() => prefs.getString(openRouterKey);
  String getOpenRouterModel() => prefs.getString(openRouterModel) ?? 'openai/gpt-5-chat';

  Future<void> setKeys({String? gemini, String? deepseek, String? chatgpt}) async {
    if (gemini != null) await prefs.setString(geminiKey, gemini);
    if (deepseek != null) await prefs.setString(deepSeekKey, deepseek);
    if (chatgpt != null) await prefs.setString(openRouterKey, chatgpt);
  }

  Future<void> setModel(String provider, String modelId) async {
    await prefs.setString('${provider.toLowerCase()}_model', modelId);
  }
  bool get isDarkMode => prefs.getBool(theme) ?? false;
  Future<void> setDarkMode(bool value) => prefs.setBool(theme, value);
}