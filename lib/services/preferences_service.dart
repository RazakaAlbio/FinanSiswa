import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layanan untuk menyimpan preferensi pengguna
class PreferencesService extends ChangeNotifier {
  static const _keyCurrency = 'pref_currency';
  static const _keyLocale = 'pref_locale';
  static const _keyTheme = 'pref_theme'; // 'light' | 'dark'
  static const _keyFirstLaunch = 'pref_first_launch';

  late SharedPreferences _prefs;

  /// Inisialisasi SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Mata uang
  String get currency => _prefs.getString(_keyCurrency) ?? 'IDR';
  Future<void> setCurrency(String value) => _prefs.setString(_keyCurrency, value);

  // Locale
  String get locale => _prefs.getString(_keyLocale) ?? 'id_ID';
  Future<void> setLocale(String value) => _prefs.setString(_keyLocale, value);

  // Tema
  // 'light' | 'dark' | 'system'
  String get theme => _prefs.getString(_keyTheme) ?? 'system';
  Future<void> setTheme(String value) async {
    await _prefs.setString(_keyTheme, value);
    notifyListeners();
  }

  // First launch
  bool get isFirstLaunch => _prefs.getBool(_keyFirstLaunch) ?? true;
  Future<void> setFirstLaunchFalse() => _prefs.setBool(_keyFirstLaunch, false);
}