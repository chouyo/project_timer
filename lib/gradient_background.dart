import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final Gradient gradient = brightness == Brightness.dark
        ? const LinearGradient(
            colors: [
              Color(0xFF181818),
              Color(0xFF181818),
              //Color(0xFF565656),
              //Color(0xFF181818),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFFEAEAEA),
              Color(0xFFEAEAEA),
              // Color(0xFFEAEAEA),
              // Color(0xFF8B8B8B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
