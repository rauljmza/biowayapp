// lib/models/user_state.dart
class UserState {
  final String userId;
  final String nombre;
  final String estado; // "0" = puede brindar, "1" = ya brindó
  final String? token;

  UserState({
    required this.userId,
    required this.nombre,
    required this.estado,
    this.token,
  });
}