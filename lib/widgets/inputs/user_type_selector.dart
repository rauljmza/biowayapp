import 'package:flutter/material.dart';

class UserTypeSelector extends StatelessWidget {
  final bool isBrindador;
  final bool isRecolector;
  final Function(bool) onBrindadorChanged;
  final Function(bool) onRecolectorChanged;

  const UserTypeSelector({
    super.key,
    required this.isBrindador,
    required this.isRecolector,
    required this.onBrindadorChanged,
    required this.onRecolectorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registrarse como:',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text(
                  'Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                value: isBrindador,
                onChanged: (value) {
                  if (value ?? false) {
                    onBrindadorChanged(true);
                    onRecolectorChanged(false);
                  }
                },
                checkColor: Colors.white,
                activeColor: Colors.green,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text(
                  'Recolector',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                value: isRecolector,
                onChanged: (value) {
                  if (value ?? false) {
                    onRecolectorChanged(true);
                    onBrindadorChanged(false);
                  }
                },
                checkColor: Colors.white,
                activeColor: Colors.green,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
        if (isBrindador || isRecolector)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              isBrindador
                  ? 'El usuario brindador es el encargado de separar y colocar sus residuos reciclables conforme los requisitos y horarios establecidos para su recolección, siendo este recompensado con puntos canjeables.'
                  : 'El usuario recolector es el encargado de recolectar los residuos reciclables para su traslado a los centros de acopio conforme los requisitos y horarios establecidos, siendo este quien cobre en los centros de acopio.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}