// lib/widgets/cards/horario_card.dart
import 'package:flutter/material.dart';
import '../../models/horario.dart';
import '../../theme/app_colors.dart';

class HorarioCard extends StatelessWidget {
  final Horario horario;
  final bool isToday;
  final VoidCallback onTapBrindar;

  const HorarioCard({
    Key? key,
    required this.horario,
    required this.isToday,
    required this.onTapBrindar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTapBrindar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 130,
          decoration: BoxDecoration(
            color: isToday ? AppColors.color5 : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: isToday ? Colors.white : AppColors.color5,
                  size: 36,
                ),
                const SizedBox(height: 8),
                // Mostrar el día
                Text(
                  horario.dia,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                // Si tu modelo 'Horario' tuviera una propiedad para la hora, por ejemplo:
                // Text(
                //   horario.horaInicio, // Reemplaza 'horaInicio' por el nombre correcto
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: isToday ? Colors.white : AppColors.textLight,
                //   ),
                // ),
                // En este ejemplo, se omite la hora ya que la propiedad no existe.
              ],
            ),
          ),
        ),
      ),
    );
  }
}
