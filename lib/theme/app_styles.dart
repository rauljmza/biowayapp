// lib/theme/app_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const cardBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(15)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  static const buttonBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
      // Utilizamos dos colores de la nueva paleta en lugar de green1 y green2
      colors: [AppColors.color4, AppColors.primary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(25)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );
}
