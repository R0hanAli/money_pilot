import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _key = 'theme_mode';
  final _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDark => _themeMode.value == ThemeMode.dark ||
      (_themeMode.value == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'dark') {
      _themeMode.value = ThemeMode.dark;
    } else if (saved == 'light') {
      _themeMode.value = ThemeMode.light;
    } else {
      _themeMode.value = ThemeMode.system;
    }
    Get.changeThemeMode(_themeMode.value);
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.dark:
        await prefs.setString(_key, 'dark');
        break;
      case ThemeMode.light:
        await prefs.setString(_key, 'light');
        break;
      default:
        await prefs.setString(_key, 'system');
    }
  }

  void toggleTheme() {
    if (_themeMode.value == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}
