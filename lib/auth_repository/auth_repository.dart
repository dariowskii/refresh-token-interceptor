import 'package:dio/dio.dart';
import 'package:refresh_token_interceptor/models.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_repository.g.dart';

@RestApi()
abstract class AuthRepository {
  factory AuthRepository(Dio dio, {String baseUrl}) = _AuthRepository;

  @POST('/login')
  Future<UserAuthResponse> login(@Body() UserAuthRequest userAuthRequest);

  @POST('/refresh-token')
  Future<UserAuthResponse> refreshToken(@Body() TokenRequest tokenRequest);

  @GET('/home')
  Future<HomeResponse> getHome();

  @DELETE('/logout')
  Future<void> logout();
}
