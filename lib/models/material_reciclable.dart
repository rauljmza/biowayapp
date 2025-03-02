// lib/models/material_reciclable.dart
class MaterialReciclable {
  final String id;
  final String nombre;
  final String descripcion;
  final double cantidadMinima;
  final String unidad;
  final String color;
  final String icon;
  final String comoReciben;
  final String queNoReciben;

  MaterialReciclable({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidadMinima,
    required this.unidad,
    required this.color,
    required this.icon,
    required this.comoReciben,
    required this.queNoReciben,
  });

  factory MaterialReciclable.fromFirestore(String docId, Map<String, dynamic> data) {
    return MaterialReciclable(
      id: docId, // Usamos el docId para garantizar que sea único
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      cantidadMinima: (data['cantMin'] ?? 0).toDouble(),
      unidad: data['unidad'] ?? '',
      color: data['color'] ?? '',
      icon: data['icon'] ?? '',
      comoReciben: data['CLRER'] ?? '',
      queNoReciben: data['QNR'] ?? '',
    );
  }
}
