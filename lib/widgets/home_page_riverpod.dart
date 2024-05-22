import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refresh_token_interceptor/riverpod/auth_controller/auth_controller.dart';
import 'package:refresh_token_interceptor/utils/base_mixin.dart';
import 'package:refresh_token_interceptor/widgets/home_body.dart';

class HomePageRiverpod extends ConsumerStatefulWidget {
  const HomePageRiverpod({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HomePageRiverpodState();
}

class _HomePageRiverpodState extends ConsumerState<HomePageRiverpod>
    with BaseMixin {
  @override
  void login() async {
    try {
      toggleLoading();

      await ref.read(authControllerProvider.notifier).login('user');
      showSnackBar('Logged in as "user"!');
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      toggleLoading();
    }
  }

  @override
  void getHomeData() async {
    try {
      toggleLoading();

      final data = await ref.read(authControllerProvider.notifier).getHome();

      if (!mounted) return;

      showSnackBar('Home data: $data');
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        ref.read(authControllerProvider.notifier).setAuth(null);
        showSnackBar('Unauthorized! Please login again.');
        return;
      }

      showSnackBar('Error: ${error.message}');
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      toggleLoading();
    }
  }

  @override
  void logout() async {
    try {
      toggleLoading();

      await ref.read(authControllerProvider.notifier).logout();
      showSnackBar('Logged out!');
    } catch (e) {
      showSnackBar('Error: $e');
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
