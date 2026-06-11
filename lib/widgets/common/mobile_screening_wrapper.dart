import 'package:flutter/material.dart';

class MobileScreeningWrapper extends StatelessWidget {
  const MobileScreeningWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If screen width is wider than a mobile device (480px),
        // constrain it to a centered portrait standing position.
        if (constraints.maxWidth > 480) {
          return Container(
            color: const Color(0xFF0A0A0C), // Outer background
            alignment: Alignment.center,
            child: Container(
              width: 450,
              height: double.infinity, // standing position: full height
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 32,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          );
        }

        // On standard mobile screens, render full screen naturally.
        return child;
      },
    );
  }
}
