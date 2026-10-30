import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  double _fontScale = 1.0; // 0.9 (Small), 1.0 (Normal), 1.15 (Large), 1.3 (Extra Large)
  Color _primaryColor = Colors.indigo;

  double get fontScale => _fontScale;
  Color get primaryColor => _primaryColor;

  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
