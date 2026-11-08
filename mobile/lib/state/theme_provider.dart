import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the chosen theme (System / Light / Dark) and remembers it between launches.
/// Any widget that watches it rebuilds when the user changes the setting.
class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode mode = ThemeMode.system;

  Future<void> init() async {
    final saved = (await SharedPreferences.getInstance()).getString(_key);
    mode = ThemeMode.values.asNameMap()[saved] ?? ThemeMode.system;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode next) async {
    if (next == mode) return;
    mode = next;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_key, next.name);
  }

  /// Quick toggle: flips whatever is currently on screen.
  void toggle(Brightness current) => setMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}
