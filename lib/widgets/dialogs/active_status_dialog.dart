// lib/widgets/dialogs/active_status_dialog.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ActiveStatusDialog extends StatelessWidget {
  final VoidCallback onClose;

  const ActiveStatusDialog({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AHORA ACTIVO',
              style: const TextStyle(
                color: Color(0xFFFFB81C), // Valor literal para el amarillo (anteriormente yellow33)
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Ahora mismo estás activo para que el recolector tome tus reciclables.',
              style: const TextStyle(
                color: AppColors.textDark, // Se usa textDark en lugar de titulo1
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Si tu basura NO es recolectada CONTÁCTANOS.',
              style: const TextStyle(
                color: AppColors.textDark, // Se usa textDark en lugar de titulo1
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: onClose,
              icon: Image.asset(
                'assets/icons/paloma.png',
                width: 50,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
