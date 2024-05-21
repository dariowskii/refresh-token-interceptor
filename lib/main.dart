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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged in as "user"!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  void _getHomeData() async {
    try {
      final homeResponse = await authRepository.getHome();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Home data: ${homeResponse.data}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh Token'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login with username "user"'),
            ),
            ElevatedButton(
              onPressed: _getHomeData,
              child: const Text('Get Home data'),
            ),
          ],
        ),
      ),
    );
  }
}
