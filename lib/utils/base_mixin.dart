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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void login();
  void getHomeData();
  void logout();
}
