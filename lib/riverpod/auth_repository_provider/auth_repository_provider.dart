import 'package:refresh_token_interceptor/auth_repository/auth_repository.dart';
import 'package:refresh_token_interceptor/riverpod/http_client/http_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(httpClientProvider));
}
