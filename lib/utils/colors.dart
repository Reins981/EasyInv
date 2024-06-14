// lib/utils/colors.dart
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class AppColors {
  static const Color rosa = Color(0xFFE1BEE7);
  static const Color white = Colors.white;
  static const Color pink = Colors.pink;
}


class GradientIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final double size;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.gradientColors,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: gradientColors,
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // This color is overridden by the ShaderMask
      ),
    );
  }
}

