// lib/services/firebase/horarios_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/horario.dart';

class HorariosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Horario>> getHorarios() {
    return _firestore
        .collection('Horarios')
        .orderBy('numDia', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Horario.fromFirestore(doc)).toList());
  }

  Future<String?> getCantidadMinima(String dia) async {
    final doc = await _firestore.collection('Horarios').doc(dia).get();
    return doc.data()?['cantMin']?.toString();
  }
}