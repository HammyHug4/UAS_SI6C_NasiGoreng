import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider instance =
      LanguageProvider._internal();

  LanguageProvider._internal();

  factory LanguageProvider() {
    return instance;
  }

  static const String _languageKey = 'languageCode';
  static const Locale defaultLocale = Locale('id');

  Locale _currentLocale = defaultLocale;

  Locale get currentLocale => _currentLocale;

  String get languageCode => _currentLocale.languageCode;

  bool get isIndonesian => languageCode == 'id';

  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode =
        prefs.getString(_languageKey) ??
            defaultLocale.languageCode;

    _currentLocale = Locale(savedLanguageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_currentLocale.languageCode ==
        locale.languageCode) {
      return;
    }

    _currentLocale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _languageKey,
      locale.languageCode,
    );
  }
}