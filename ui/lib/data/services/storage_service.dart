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

  static const String claudeKey = 'claude_key';
  static const String claudeModel = 'claude_model';

  static const String grokKey = 'grok_key';
  static const String grokModel = 'grok_model';

  static const String theme = 'theme_mode';

  
  // Gemini
  String? getGeminiKey() => prefs.getString(geminiKey);
  String getGeminiModel() => prefs.getString(geminiModel) ?? 'gemini-2.5-flash';
  
  // DeepSeek
  String? getDeepSeekKey() => prefs.getString(deepSeekKey);
  String getDeepSeekModel() => prefs.getString(deepSeekModel) ?? 'deepseek/deepseek-chat';

  // ChatGPT
  String? getOpenRouterKey() => prefs.getString(openRouterKey);
  String getOpenRouterModel() => prefs.getString(openRouterModel) ?? 'openai/gpt-4o'; 

  // Claude
  String? getClaudeKey() => prefs.getString(claudeKey);
  String getClaudeModel() => prefs.getString(claudeModel) ?? 'anthropic/claude-3-haiku';

  // Grok
  String? getGrokKey() => prefs.getString(grokKey);
  String getGrokModel() => prefs.getString(grokModel) ?? 'xai/grok-beta';



  Future<void> setKeys({
    String? gemini, 
    String? deepseek, 
    String? chatgpt,
    String? claude,
    String? grok,
  }) async {
    if (gemini != null) await prefs.setString(geminiKey, gemini);
    if (deepseek != null) await prefs.setString(deepSeekKey, deepseek);
    if (chatgpt != null) await prefs.setString(openRouterKey, chatgpt);
    if (claude != null) await prefs.setString(claudeKey, claude);
    if (grok != null) await prefs.setString(grokKey, grok);
  }

  Future<void> setModel(String provider, String modelId) async {
    await prefs.setString('${provider.toLowerCase()}_model', modelId);
  }
  bool get isDarkMode => prefs.getBool(theme) ?? false;
  Future<void> setDarkMode(bool value) => prefs.setBool(theme, value);
}