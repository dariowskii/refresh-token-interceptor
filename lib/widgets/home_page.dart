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

  var _isLoading = false;

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
        client: httpClient,
        authRepository: authRepository,
      ),
    );
  }

  void _login() async {
    try {
      _toggleLoading();

      final userAuthRequest = UserAuthRequest(username: 'user');
      final authResponse = await authRepository.login(userAuthRequest);

      await LocalData.instance.saveToken(authResponse);
      showSnackBar('Logged in as "user"!');
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      _toggleLoading();
    }
  }

  void _getHomeData() async {
    try {
      _toggleLoading();

      final homeResponse = await authRepository.getHome();

      if (!mounted) return;

      showSnackBar('Home data: ${homeResponse.data}');
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await LocalData.instance.clearToken();
        showSnackBar('Unauthorized! Please login again.');
        return;
      }

      showSnackBar('Error: ${error.message}');
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      _toggleLoading();
    }
  }

  void _logout() async {
    try {
      _toggleLoading();

      await authRepository.logout();
      await LocalData.instance.clearToken();

      showSnackBar('Logged out!');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      _toggleLoading();
    }
  }

  void _toggleLoading() {
    if (!mounted) return;

    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh Token'),
      ),
      body: SafeArea(
        child: HomeBody(
          onLogin: _login,
          onGetHomeData: _getHomeData,
          onLogout: _logout,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}
