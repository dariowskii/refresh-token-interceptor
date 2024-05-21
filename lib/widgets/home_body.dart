import 'package:flutter/material.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
    required this.onLogin,
    required this.onGetHomeData,
    required this.onLogout,
    required this.isLoading,
  });

  final VoidCallback onLogin;
  final VoidCallback onGetHomeData;
  final VoidCallback onLogout;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          ElevatedButton(
            onPressed: !isLoading ? onLogin : null,
            child: const Text('Login with username "user"'),
          ),
          ElevatedButton(
            onPressed: !isLoading ? onGetHomeData : null,
            child: const Text('Get Home data'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: !isLoading ? onLogout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
