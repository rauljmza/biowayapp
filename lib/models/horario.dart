// lib/models/horario.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Horario {
  final String dia;          // nombre del doc (domingo, lunes, etc.)
  final String horario;      // p.ej. "16:00 HRS - 19:00 HRS"
  final String matinfo;      // p.ej. "CARTÓN - PAPEL"
  final String clrEr;        // p.ej. "Seco, sin manchas..."
  final String qnr;          // p.ej. "Empaques con alimentos..."
  final String cantidadMinima; // p.ej. "2kg"
  final int numDia;          // p.ej. 1 = lunes, ..., 7 = domingo

  Horario({
    required this.dia,
    required this.horario,
    required this.matinfo,
    required this.clrEr,
    required this.qnr,
    required this.cantidadMinima,
    required this.numDia,
  });

  factory Horario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Manejo flexible de numDia: si viene como int o como String
    int parsedNumDia = 0;
    final rawNumDia = data['numDia'];
    if (rawNumDia is int) {
      parsedNumDia = rawNumDia;
    } else if (rawNumDia is String) {
      parsedNumDia = int.tryParse(rawNumDia) ?? 0;
    }

    return Horario(
      dia: doc.id,  // El nombre del documento (domingo, lunes, etc.)
      horario: data['horario'] ?? '',
      matinfo: data['matinfo'] ?? '',
      clrEr: data['CLRER'] ?? '',
      qnr: data['QNR'] ?? '',
      cantidadMinima: data['cantMin'] ?? '',
      numDia: parsedNumDia,
    );
  }
}
