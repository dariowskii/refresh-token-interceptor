import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:refresh_token_interceptor/auth_repository/auth_repository.dart';
import 'package:refresh_token_interceptor/models.dart';
import 'package:refresh_token_interceptor/utils/local_data.dart';

class RefreshTokenInterceptor extends Interceptor {
  final AuthRepository authRepository;

  RefreshTokenInterceptor({
    required this.authRepository,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _addTokenIfNeeded(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 403) {
      return handler.next(err);
    }

    _refreshTokenAndResolveError(err, handler);
  }

  /// Adds the user token to the request headers if it's not already there.
  /// If the token is not present, the request will be sent without it.
  ///
  /// If the token is present, it will be added to the headers.
  void _addTokenIfNeeded(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }

    final userToken = await LocalData.instance.authToken;
    if (userToken != null && userToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $userToken';
    }

    handler.next(options);
  }

  /// Refreshes the user token and retries the request.
  /// If the token refresh fails, the error will be passed to the next interceptor.
  void _refreshTokenAndResolveError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _debugPrint('### Refreshing token... ###');
    final refreshToken = await LocalData.instance.refreshToken;

    if (refreshToken == null) {
      return handler.next(err);
    }

    late final UserAuthResponse authResponse;

    try {
      authResponse = await authRepository.refreshToken(
        TokenRequest(token: refreshToken),
      );
    } catch (e) {
      await LocalData.instance.clearToken();

      if (e is DioException) {
        return handler.next(e);
      }

      return handler.next(err);
    }

    _debugPrint('### Token refreshed! ###');

    await LocalData.instance.saveToken(authResponse);

    err.requestOptions.headers['Authorization'] =
        'Bearer ${authResponse.token}';

    final refreshResponse = await Dio().fetch(err.requestOptions);
    return handler.resolve(refreshResponse);
  }

  void _debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
