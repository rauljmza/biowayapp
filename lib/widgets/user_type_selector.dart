import 'package:flutter/material.dart';
import 'package:biowayapp/theme/app_colors.dart';

class UserTypeSelector extends StatelessWidget {
  final String? selected; // "brindador" o "recolector"
  final ValueChanged<String> onChanged;
  final TextStyle? textStyle;

  const UserTypeSelector({
    Key? key,
    required this.selected,
    required this.onChanged,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle =
        textStyle ?? const TextStyle(fontSize: 14, color: Colors.black87);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "Selecciona el tipo de usuario:",
            style: effectiveTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged("brindador"),
                child: Card(
                  color: selected == "brindador"
                      ? Colors.green[100]
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: selected == "brindador"
                          ? Colors.green
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        "Brindador",
                        style: effectiveTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged("recolector"),
                child: Card(
                  color: selected == "recolector"
                      ? Colors.green[100]
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: selected == "recolector"
                          ? Colors.green
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        "Recolector",
                        style: effectiveTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (selected != null)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              selected == "brindador"
                  ? "Usuario que separa y brinda sus residuos reciclables desde casa, mediante la app para saber qué, cómo y cuándo reciclar; así gana puntos y conoce su impacto en la reducción de CO₂."
                  : "Usuario que recibe la ubicación de materiales reciclables previamente separados para su recolección. Esto reduce riesgos para tu salud, dignifica tu labor, y obtienes ingresos mejores y estables.",
              style: effectiveTextStyle.copyWith(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
