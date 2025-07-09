// === lib/utils/theme_provider.dart ===
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  ThemeData get currentTheme => _isDark ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}