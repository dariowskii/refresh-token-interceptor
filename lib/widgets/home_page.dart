import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:refresh_token_interceptor/auth_repository/auth_repository.dart';
import 'package:refresh_token_interceptor/models.dart';
import 'package:refresh_token_interceptor/refresh_token_interceptor.dart';
import 'package:refresh_token_interceptor/utils/base_mixin.dart';
import 'package:refresh_token_interceptor/utils/local_data.dart';
import 'package:refresh_token_interceptor/widgets/home_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with BaseMixin {
  late final Dio httpClient;
  late final AuthRepository authRepository;

  @override
  void initState() {
    super.initState();

    _initClient();
  }

  void _initClient() {
    httpClient = Dio();
    httpClient.options.baseUrl = 'https://refresh-token-interceptor.glitch.me/';
    httpClient.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    authRepository = AuthRepository(httpClient);
    httpClient.interceptors.add(
      RefreshTokenInterceptor(
        authRepository: authRepository,
      ),
    );
  }

  @override
  void login() async {
    try {
      toggleLoading();

      final userAuthRequest = UserAuthRequest(username: 'user');
      final authResponse = await authRepository.login(userAuthRequest);

      await LocalData.instance.saveToken(authResponse);
      showSnackBar('Logged in as "user"!');
    } catch (e) {
      handleNetworkError(e);
    } finally {
      toggleLoading();
    }
  }

  @override
  void getHomeData() async {
    try {
      toggleLoading();

      final homeResponse = await authRepository.getHome();
      showSnackBar('Home data: ${homeResponse.data}');
    } catch (e) {
      handleNetworkError(e);
    } finally {
      toggleLoading();
    }
  }

  @override
  void logout() async {
    try {
      toggleLoading();

      await authRepository.logout();
      await LocalData.instance.clearToken();

      showSnackBar('Logged out!');
    } catch (e) {
      handleNetworkError(e);
    } finally {
      toggleLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh Token'),
      ),
      body: SafeArea(
        child: HomeBody(
          onLogin: login,
          onGetHomeData: getHomeData,
          onLogout: logout,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
