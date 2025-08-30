import 'package:shared_preferences/shared_preferences.dart';

class TranslationCache {
  static const String _cacheKeyPrefix = 'translation_cache_';
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> get(String key) async {
    await _init();
    return _prefs?.getString('$_cacheKeyPrefix$key');
  }

  Future<void> set(String key, String value) async {
    await _init();
    await _prefs?.setString('$_cacheKeyPrefix$key', value);
  }
}
