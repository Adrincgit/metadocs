// lib/providers/visual_state_provider.dart
import 'package:flutter/material.dart';
import 'package:metadocs/theme/theme.dart';

class VisualStateProvider extends ChangeNotifier {
  String _currentRoute = '/';
  String get currentRoute => _currentRoute;

  bool _sidebarExpanded = true;
  bool get sidebarExpanded => _sidebarExpanded;

  ThemeMode _themeMode = AppTheme.themeMode;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setCurrentRoute(String route) {
    if (_currentRoute == route) return;
    _currentRoute = route;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarExpanded = !_sidebarExpanded;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    AppTheme.saveThemeMode(_themeMode);
    notifyListeners();
  }
}
