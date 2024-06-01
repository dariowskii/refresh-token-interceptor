import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

mixin BaseMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = false;

  void toggleLoading() {
    if (!mounted) return;

    setState(() {
      isLoading = !isLoading;
    });
  }

  void showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void handleNetworkError(Object error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        showSnackBar('Unauthorized! Please login again.');
        return;
      }

      showSnackBar('Error: ${error.message}');
      return;
    }

    showSnackBar('Error: $error');
  }

  void login();
  void getHomeData();
  void logout();
}
