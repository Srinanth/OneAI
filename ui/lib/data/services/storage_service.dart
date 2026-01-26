import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences prefs;

  StorageService(this.prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  static const String gemini = 'gemini_key';
  static const String deepseek = 'deepseek_key';
  static const String theme = 'theme_mode';

  String? getGeminiKey() => prefs.getString(gemini);
  Future<void> setGeminiKey(String value) => prefs.setString(gemini, value);

  String? getDeepSeekKey() => prefs.getString(deepseek);
  Future<void> setDeepSeekKey(String value) => prefs.setString(deepseek, value);

  bool get isDarkMode => prefs.getBool(theme) ?? false;
  Future<void> setDarkMode(bool value) => prefs.setBool(theme, value);
}