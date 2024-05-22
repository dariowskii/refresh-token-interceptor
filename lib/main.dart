import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refresh_token_interceptor/widgets/home_page.dart';
import 'package:refresh_token_interceptor/widgets/home_page_riverpod.dart';

void main() {
  // runApp(const MyApp());
  runApp(
    const ProviderScope(
      child: MyAppRiverpod(),
    ),
  );
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

class MyAppRiverpod extends StatelessWidget {
  const MyAppRiverpod({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refresh Token',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePageRiverpod(),
    );
  }
}
