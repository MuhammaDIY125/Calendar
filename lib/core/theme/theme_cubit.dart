import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  static const _key = 'theme_mode';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    switch (saved) {
      case 'light':
        emit(ThemeMode.light);
      case 'dark':
        emit(ThemeMode.dark);
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> setLight() => _save(ThemeMode.light);
  Future<void> setDark() => _save(ThemeMode.dark);
  Future<void> setSystem() => _save(ThemeMode.system);

  void toggle() {
    if (state == ThemeMode.dark) {
      _save(ThemeMode.light);
    } else {
      _save(ThemeMode.dark);
    }
  }

  Future<void> _save(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
