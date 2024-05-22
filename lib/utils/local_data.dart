import 'package:refresh_token_interceptor/models.dart';
import 'package:refresh_token_interceptor/riverpod/user_auth/user_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kAuthTokenKey = 'authToken';
const kRefreshTokenKey = 'refreshToken';

class LocalData {
  LocalData._();

  static final LocalData _instance = LocalData._();
  static LocalData get instance => _instance;

  Future<String?> get authToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kAuthTokenKey);
  }

  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kRefreshTokenKey);
  }

  Future<void> saveToken(UserAuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(kAuthTokenKey, response.token),
      prefs.setString(kRefreshTokenKey, response.refreshToken)
    ]);
  }

  Future<void> saveTokenFromAuth(UserAuth auth) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(kAuthTokenKey, auth.token),
      prefs.setString(kRefreshTokenKey, auth.refreshToken)
    ]);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait(
        [prefs.remove(kAuthTokenKey), prefs.remove(kRefreshTokenKey)]);
  }
}
