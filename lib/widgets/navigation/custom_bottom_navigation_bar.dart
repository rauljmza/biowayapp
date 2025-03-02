// lib/widgets/navigation/custom_bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../screens/home/main_activity.dart';
import '../../screens/profile/user_info_screen.dart';
import '../../screens/shop/tienda_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Comercio',
        ),
      ],
      backgroundColor: const Color(0xFFF7CE00),
    );
  }
}
