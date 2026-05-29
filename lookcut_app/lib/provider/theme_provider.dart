import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider instance =
      ThemeProvider._internal();

  ThemeProvider._internal();

  factory ThemeProvider() {
    return instance;
  }


  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // CURRENT THEME
  ThemeMode get currentTheme =>
      _isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;

  // LIGHT THEME
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      primaryColor: Colors.orange,

      scaffoldBackgroundColor:
          Colors.grey.shade100,

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shadowColor:
            Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
      ),

      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(
        selectedItemColor: Colors.orange,
        unselectedItemColor:
            Colors.grey.shade600,
        backgroundColor: Colors.white,
      ),
    );
  }

  // DARK THEME
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      primaryColor: Colors.orange,

      scaffoldBackgroundColor:
          const Color(0xff121212),

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.dark,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xff1E1E1E),
        foregroundColor: Colors.white,
      ),

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff1E1E1E),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xff1E1E1E),
        shadowColor:
            Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
      ),

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xff1E1E1E),
      ),
    );
  }

  // TOGGLE THEME
  Future<void> toggleTheme() async {

    _isDarkMode = !_isDarkMode;

    notifyListeners();

    await saveTheme();
  }

  // SAVE THEME
  Future<void> saveTheme() async {

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'isDarkMode',
      _isDarkMode,
    );
  }

  // LOAD THEME
  Future<void> loadTheme() async {

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    _isDarkMode =
        prefs.getBool('isDarkMode') ??
            false;

    notifyListeners();
  }

  // SET DARK MODE
  Future<void> setDarkMode() async {

    _isDarkMode = true;

    notifyListeners();

    await saveTheme();
  }

  // SET LIGHT MODE
  Future<void> setLightMode() async {

    _isDarkMode = false;

    notifyListeners();

    await saveTheme();
  }

  // RESET THEME
  Future<void> resetTheme() async {

    _isDarkMode = false;

    notifyListeners();

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('isDarkMode');
  }

  // CARD COLOR
  Color get cardColor {

    if (_isDarkMode) {
      return const Color(0xff1E1E1E);
    }

    return Colors.white;
  }

  // BACKGROUND COLOR
  Color get backgroundColor {

    if (_isDarkMode) {
      return const Color(0xff121212);
    }

    return Colors.grey.shade100;
  }

  // TEXT COLOR
  Color get textColor {

    if (_isDarkMode) {
      return Colors.white;
    }

    return Colors.black;
  }

  // SUBTITLE COLOR
  Color get subtitleColor {

    if (_isDarkMode) {
      return Colors.grey.shade400;
    }

    return Colors.grey.shade700;
  }

  // BORDER COLOR
  Color get borderColor {

    if (_isDarkMode) {
      return Colors.grey.shade800;
    }

    return Colors.grey.shade300;
  }

  // INPUT FIELD COLOR
  Color get inputFillColor {

    if (_isDarkMode) {
      return const Color(0xff1E1E1E);
    }

    return Colors.white;
  }

  // ICON COLOR
  Color get iconColor {

    if (_isDarkMode) {
      return Colors.orange.shade300;
    }

    return Colors.orange;
  }

  // SHADOW COLOR
  Color get shadowColor {

    if (_isDarkMode) {
      return Colors.black.withValues(alpha: 0.2);
    }

    return Colors.black.withValues(alpha: 0.05);
  }

  // DIVIDER COLOR
  Color get dividerColor {

    if (_isDarkMode) {
      return Colors.grey.shade800;
    }

    return Colors.grey.shade300;
  }

  // SWITCH THEME MANUALLY
  void switchTheme(bool value) {

    _isDarkMode = value;

    notifyListeners();

    saveTheme();
  }

  // INITIALIZE THEME
  Future<void> initializeTheme() async {

    await loadTheme();
  }
}