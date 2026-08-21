import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/models/user_model.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _tokenKey = 'jwt_token';
  static const _userKey  = 'cached_user';

  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);
  String?      getToken()              => _prefs.getString(_tokenKey);
  Future<void> deleteToken()           => _prefs.remove(_tokenKey);
  bool         isLoggedIn()            => getToken() != null;

  Future<void> saveUser(UserModel user) =>
      _prefs.setString(_userKey, jsonEncode(user.toJson()));

  UserModel? getUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() => Future.wait([
        _prefs.remove(_tokenKey),
        _prefs.remove(_userKey),
      ]);
}
