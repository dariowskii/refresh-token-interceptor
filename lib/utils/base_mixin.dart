import 'package:flutter/material.dart';

mixin BaseMixin<T extends StatefulWidget> on State<T> {
  void showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
