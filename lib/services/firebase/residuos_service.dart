// lib/services/firebase/residuos_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/material_reciclable.dart';

class ResiduosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtiene la lista de materiales reciclables desde Firestore.
  Stream<List<MaterialReciclable>> getMaterialesReciclables() {
    return _firestore
        .collection('Reciclables')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MaterialReciclable.fromFirestore(doc.id, doc.data()))
        .toList());
  }

  // Registra los residuos enviados por el usuario.
  Future<void> registrarResiduos({
    required String userId,
    required Map<String, Map<String, dynamic>> selectedMaterials,
  }) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('UsersInAct').doc(userId);
    final historialRef = userRef.collection('Historial');
    final residuosRef = userRef.collection('Residuos');

    // Actualiza el estado del usuario y suma puntos.
    batch.update(userRef, {
      'estado': '1',
      'points': FieldValue.increment(20.0),
    });

    // Para cada material seleccionado, registra en el historial y actualiza en residuos.
    for (var entry in selectedMaterials.entries) {
      final historialDoc = historialRef.doc();
      batch.set(historialDoc, {
        'fecha': FieldValue.serverTimestamp(),
        'material': entry.key,
        'cantidad': entry.value['cantMin'],
        'unidad': entry.value['unit'],
      });

      final residuoDoc = residuosRef.doc(entry.key);
      batch.set(
        residuoDoc,
        {
          'cantAcum': FieldValue.increment(entry.value['cantMin'] as double),
          'activoParaRecoleccion': true,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}
