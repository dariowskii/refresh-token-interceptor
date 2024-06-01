import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:refresh_token_interceptor/riverpod/auth_controller/auth_controller.dart';
import 'package:refresh_token_interceptor/riverpod/http_client/http_client.dart';

class RefreshTokenRiverpodInterceptor extends Interceptor {
  final HttpClientRef ref;

  RefreshTokenRiverpodInterceptor(this.ref);

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

    final userToken = await _getToken();

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

    try {
      await ref.read(authControllerProvider.notifier).refreshToken();
    } catch (e) {
      ref.read(authControllerProvider.notifier).setAuth(null);

      if (e is DioException) {
        return handler.next(e);
      }

      return handler.next(err);
    }

    _debugPrint('### Token refreshed! ###');

    final token = await _getToken();

    if (token == null || token.isEmpty) {
      return handler.next(err);
    }

    err.requestOptions.headers['Authorization'] = 'Bearer $token';

    final refreshResponse = await Dio().fetch(err.requestOptions);
    return handler.resolve(refreshResponse);
  }

  void _debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  Future<String?> _getToken() async {
    return await ref.read(
      authControllerProvider.selectAsync(
        (user) => user?.token,
      ),
    );
  }
}
