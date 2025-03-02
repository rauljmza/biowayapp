// lib/widgets/gradients/gradient_background.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.gradientColors, // Se usa gradientColors en lugar de mainGradient
        ),
      ),
      child: child,
    );
  }
}
