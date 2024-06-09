import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/domain/providers/shared_preferences_provider.dart';

part 'app_theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    initTheme();

    return ThemeMode.light;
  }

  Future<void> setTheme(String theme) async {
    var prefs = await ref.read(sharedPreferencesProvider.future);

    switch (theme.toLowerCase()) {
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'light':
        state = ThemeMode.light;
        break;
      default:
        state = ThemeMode.system;
    }

    logger.d('Theme changed to ${state.name}');

    prefs.setString('theme', state.name);
  }

  Future<void> initTheme() async {
    var prefs = await ref.read(sharedPreferencesProvider.future);

    var theme = prefs.getString('theme');
    var value = ThemeMode.values.byName(theme ?? 'light');

    state = value;
  }
}
