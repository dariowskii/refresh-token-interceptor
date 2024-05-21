import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:refresh_token_interceptor/auth_repository/auth_repository.dart';
import 'package:refresh_token_interceptor/models.dart';
import 'package:refresh_token_interceptor/refresh_token_interceptor.dart';
import 'package:refresh_token_interceptor/utils/local_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Dio httpClient;
  late final AuthRepository authRepository;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    _initScreen();
  }

  void _initScreen() {
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

      if (!mounted) return;

      _showSnackBar('Logged in as "user"!');
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Error: $e');
    } finally {
      _toggleLoading();
    }
  }

  void _getHomeData() async {
    try {
      _toggleLoading();

      final homeResponse = await authRepository.getHome();

      if (!mounted) return;

      _showSnackBar('Home data: ${homeResponse.data}');
    } on DioException catch (error) {
      if (!mounted) return;

      if (error.response?.statusCode == 401) {
        _showSnackBar('Unauthorized! Please login again.');
        return;
      }

      _showSnackBar('Error: ${error.message}');
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Error: $e');
    } finally {
      _toggleLoading();
    }
  }

  void _logout() async {
    try {
      _toggleLoading();

      await authRepository.logout();
      await LocalData.instance.clearToken();

      if (!mounted) return;

      _showSnackBar('Logged out!');
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
    if (mounted) {
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh Token'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: !_isLoading ? _login : null,
                child: const Text('Login with username "user"'),
              ),
              ElevatedButton(
                onPressed: !_isLoading ? _getHomeData : null,
                child: const Text('Get Home data'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: !_isLoading ? _logout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
