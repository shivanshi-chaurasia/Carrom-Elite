import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../bottom_nav/main_bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.showBottomNav = true,
  });

  final Widget child;
  final int currentIndex;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: child),
      bottomNavigationBar: showBottomNav ? MainBottomNav(currentIndex: currentIndex) : null,
    );
  }
}
