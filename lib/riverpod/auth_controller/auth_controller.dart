import 'package:refresh_token_interceptor/models.dart';
import 'package:refresh_token_interceptor/riverpod/auth_repository/auth_repository.dart';
import 'package:refresh_token_interceptor/riverpod/user_auth/user_auth.dart';
import 'package:refresh_token_interceptor/utils/local_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<UserAuth?> build() async {
    _observeState();
    return _restoreFromSharedPreferences();
  }

  void setAuth(UserAuthResponse? auth) {
    if (auth == null) {
      state = const AsyncData(null);
      return;
    }

    state = AsyncData(
      UserAuth(
        token: auth.token,
        refreshToken: auth.refreshToken,
      ),
    );
  }

  Future<void> login(String username) async {
    final response = await ref.read(authRepositoryProvider).login(
          UserAuthRequest(username: username),
        );

    setAuth(response);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<String> getHome() async {
    final response = await ref.read(authRepositoryProvider).getHome();
    return response.data;
  }

  Future<void> refreshToken() async {
    final userAuth = state.requireValue;
    if (userAuth == null) throw StateError('User not logged in');

    final response = await ref.read(authRepositoryProvider).refreshToken(
          TokenRequest(token: userAuth.refreshToken),
        );

    setAuth(response);
  }

  Future<UserAuth?> _restoreFromSharedPreferences() async {
    final [token, refreshToken] = await Future.wait([
      LocalData.instance.authToken,
      LocalData.instance.refreshToken,
    ]);

    if (token == null || refreshToken == null) {
      return null;
    }

    return UserAuth(token: token, refreshToken: refreshToken);
  }

  void _observeState() async {
    ref.listenSelf((_, next) async {
      if (next.isLoading || next.hasError) return;

      final auth = next.requireValue;

      if (auth == null) {
        await LocalData.instance.clearToken();
        return;
      }

      await LocalData.instance.saveTokenFromAuth(auth);
    });
  }
}
