import 'package:dio/dio.dart';
import 'package:refresh_token_interceptor/auth_repository/auth_repository.dart';
import 'package:refresh_token_interceptor/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio client;
  final AuthRepository authRepository;

  RefreshTokenInterceptor({
    required this.client,
    required this.authRepository,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    switch (options.path) {
      case '/refresh-token':
        return handler.next(options);
    }

    _addTokenIfNeeded(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 403 ||
        err.requestOptions.path == '/refresh-token') {
      return handler.next(err);
    }

    _refreshTokenAndResolveError(err, handler);
  }

  void _addTokenIfNeeded(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }

    final prefs = await SharedPreferences.getInstance();

    final userToken = prefs.getString('authToken');
    if (userToken != null && userToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $userToken';
    }

    handler.next(options);
  }

  void _refreshTokenAndResolveError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print('### Refreshing token... ###');

    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      // Sign out the user
      return handler.next(err);
    }

    late final UserAuthResponse authResponse;

    try {
      authResponse = await authRepository.refreshToken(
        TokenRequest(token: refreshToken),
      );
    } on DioException catch (e) {
      // Sign out the user
      return handler.next(e);
    } catch (e) {
      // Sign out the user
      return handler.next(err);
    }

    print('### Token refreshed! ###');

    prefs.setString('authToken', authResponse.token);
    prefs.setString('refreshToken', authResponse.refreshToken);

    err.requestOptions.headers['Authorization'] =
        'Bearer ${authResponse.token}';
    return handler.resolve(await client.fetch(err.requestOptions));
  }
}
