import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _createOrUpdateSession(credential.user!.uid);
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String address,
    required String state,
    required String city,
    required bool isBrindador,
    String? numExt,
    String? colonia,
    String? cp,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection(isBrindador ? 'UsersInAct' : 'Recolectores')
          .doc(credential.user!.uid)
          .set({
        'fName': fullName,
        'email': email,
        'address': address,
        'state': state,
        'mcipio': city,
        'numExt': numExt,
        'colonia': colonia,
        'cp': cp,
        'points': isBrindador ? 0 : null,
        'estado': isBrindador ? '0' : null,
        'isBrindador': isBrindador ? '1' : null,
        'isRecolector': !isBrindador ? '1' : null,
        'usuariosR': !isBrindador ? 0 : null,
      });

      await _createOrUpdateSession(credential.user!.uid);
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> _createOrUpdateSession(String userId) async {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('sessions').doc(userId).set({
      'sessionId': sessionId,
      'lastLoginTime': FieldValue.serverTimestamp(),
      'deviceModel': 'Flutter App',
    });
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado';
      case 'user-not-found':
        return 'No existe un usuario con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'La contraseña es muy débil';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}