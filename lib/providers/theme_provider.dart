import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  String? _pin;
  bool _pinEnabled = false;

  bool get isDark => _isDark;
  bool get pinEnabled => _pinEnabled;
  String? get pin => _pin;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('dark_mode') ?? true;
    _pin = prefs.getString('pin');
    _pinEnabled = prefs.getBool('pin_enabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDark);
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    _pin = pin;
    _pinEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin', pin);
    await prefs.setBool('pin_enabled', true);
    notifyListeners();
  }

  Future<void> disablePin() async {
    _pin = null;
    _pinEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pin');
    await prefs.setBool('pin_enabled', false);
    notifyListeners();
  }

  bool checkPin(String input) {
    return _pin == input;
  }
}
