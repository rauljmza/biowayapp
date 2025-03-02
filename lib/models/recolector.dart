// lib/models/recolector.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Recolector {
  final String id;
  final String nombre;
  final String email;
  final String direccion;
  final String estado;
  final String municipio;
  final int usuariosRecolectados;

  Recolector({
    required this.id,
    required this.nombre,
    required this.email,
    required this.direccion,
    required this.estado,
    required this.municipio,
    required this.usuariosRecolectados,
  });

  factory Recolector.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recolector(
      id: doc.id,
      nombre: data['fName'] ?? '',
      email: data['email'] ?? '',
      direccion: data['address'] ?? '',
      estado: data['state'] ?? '',
      municipio: data['mcipio'] ?? '',
      usuariosRecolectados: (data['usuariosR'] ?? 0).toInt(),
    );
  }
}