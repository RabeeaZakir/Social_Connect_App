import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            cardColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF3F5F9),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white, 
              elevation: 0, 
              iconTheme: IconThemeData(color: Colors.black)
            ),
          );
  }
}