import 'package:dio/dio.dart';
import 'package:refresh_token_interceptor/riverpod/refresh_token_riverpod_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client.g.dart';

@riverpod
Dio httpClient(HttpClientRef ref) {
  final dio = Dio();
  dio.options.baseUrl = 'https://refresh-token-interceptor.glitch.me/';
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
    ),
  );

  dio.interceptors.add(
    RefreshTokenRiverpodInterceptor(
      ref,
      client: dio,
    ),
  );

  return dio;
}
