// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Nueva paleta de colores inspirada en la imagen
  static const Color color1 = Color(0xFFB2FF9E); // Verde muy claro
  static const Color color2 = Color(0xFFD7FFC9); // Verde clarísimo
  static const Color color3 = Color(0xFFC9FDD9); // Verde pastel claro
  static const Color color4 = Color(0xFF8FE4BB); // Verde pastel
  static const Color color5 = Color(0xFF5ADBB5); // Verde turquesa
  static const Color color6 = Color(0xFF60C197); // Verde más oscuro

  // Colores para texto
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF777777);

  // Lista constante para el gradiente
  static const List<Color> gradientColors = [
    color1,
    color2,
    color3,
    color4,
    color5,
    color6,
  ];

  // Color primario (para botones, etc.)
  static const Color primary = color5;

  // Colores de fondo y tarjetas
  static const Color background = Colors.white;
  static const Color cardBackground = Colors.white;
}
