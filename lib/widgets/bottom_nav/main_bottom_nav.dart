import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (idx) {
        if (idx == currentIndex) return;
        switch (idx) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/carrom-home');
            break;
          case 2:
            context.go('/lottery-home');
            break;
          case 3:
            context.go('/wallet-dashboard');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: AppStrings.home),
        BottomNavigationBarItem(icon: Icon(Icons.gamepad_rounded), label: AppStrings.carrom),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_rounded), label: AppStrings.lottery),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: AppStrings.wallet),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: AppStrings.profile),
      ],
    );
  }
}
