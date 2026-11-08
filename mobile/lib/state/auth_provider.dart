import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, signedIn, signedOut }

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const adminMessage = 'Admin accounts use the web panel at /admin. Sign in here with a student account.';

  late final ApiService api = ApiService(onUnauthorized: _clearSession);
  AuthStatus status = AuthStatus.unknown;
  AppUser? user;

  /// Restore a saved session on app start.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    api.token = prefs.getString(_tokenKey);
    if (api.token == null) {
      _set(AuthStatus.signedOut);
      return;
    }
    try {
      final me = await api.me();
      if (me.role == 'admin') {
        await logout();
        return;
      }
      user = me;
      _set(AuthStatus.signedIn);
    } on ApiException catch (e) {
      // Drop the saved token only if the server rejected it; when offline, keep it for next launch.
      if (e.status == 401) {
        await _clearSession();
      } else {
        _set(AuthStatus.signedOut);
      }
    }
  }

  Future<void> login(String email, String password) async => _save(await api.login(email, password));

  Future<void> register(String name, String email, String password) async =>
      _save(await api.register(name, email, password));

  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {
      // Sign out locally even if the server is unreachable.
    }
    await _clearSession();
  }

  Future<void> _save((String, AppUser) result) async {
    final (token, signedIn) = result;

    // The app is for students. Revoke the admin's fresh token and point them to the web panel.
    if (signedIn.role == 'admin') {
      api.token = token;
      try {
        await api.logout();
      } catch (_) {}
      api.token = null;
      throw const ApiException(adminMessage, 403);
    }

    api.token = token;
    user = signedIn;
    (await SharedPreferences.getInstance()).setString(_tokenKey, token);
    _set(AuthStatus.signedIn);
  }

  Future<void> _clearSession() async {
    api.token = null;
    user = null;
    (await SharedPreferences.getInstance()).remove(_tokenKey);
    _set(AuthStatus.signedOut);
  }

  void _set(AuthStatus s) {
    status = s;
    notifyListeners();
  }
}
