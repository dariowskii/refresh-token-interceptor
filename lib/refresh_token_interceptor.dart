import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:refresh_token_interceptor/auth_repository/auth_repository.dart';
import 'package:refresh_token_interceptor/models.dart';
import 'package:refresh_token_interceptor/utils/local_data.dart';

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

    final userToken = await LocalData.instance.authToken;
    if (userToken != null && userToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $userToken';
    }

    handler.next(options);
  }

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
    } on DioException catch (e) {
      return handler.next(e);
    } catch (e) {
      return handler.next(err);
    }

    _debugPrint('### Token refreshed! ###');

    await LocalData.instance.saveToken(authResponse);

    err.requestOptions.headers['Authorization'] =
        'Bearer ${authResponse.token}';
    return handler.resolve(await client.fetch(err.requestOptions));
  }

  void _debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
