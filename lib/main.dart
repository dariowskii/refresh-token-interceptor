import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:refresh_token_interceptor/auth_repository/auth_repository.dart';
import 'package:refresh_token_interceptor/models.dart';
import 'package:refresh_token_interceptor/refresh_token_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refresh Token',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Dio httpClient;
  late final AuthRepository authRepository;

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
      final userAuthRequest = UserAuthRequest(username: 'user');
      final authResponse = await authRepository.login(userAuthRequest);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('authToken', authResponse.token);
      prefs.setString('refreshToken', authResponse.refreshToken);

      if (!mounted) return;

      _showSnackBar('Logged in as "user"!');
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Error: $e');
    }
  }

  void _getHomeData() async {
    try {
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
    }
  }

  void _logout() async {
    try {
      await authRepository.logout();

      final prefs = await SharedPreferences.getInstance();
      prefs.remove('authToken');
      prefs.remove('refreshToken');

      if (!mounted) return;

      _showSnackBar('Logged out!');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
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
                onPressed: _login,
                child: const Text('Login with username "user"'),
              ),
              ElevatedButton(
                onPressed: _getHomeData,
                child: const Text('Get Home data'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _logout,
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
