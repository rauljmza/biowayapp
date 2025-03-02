import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/horario.dart';
import '../../models/user_state.dart';
import '../../widgets/navigation/custom_bottom_navigation_bar.dart';
import '../../widgets/gradients/gradient_background.dart';
import '../../theme/app_colors.dart';
import 'residuos_grid_activity.dart';

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  late Stream<List<Horario>> _horariosStream;
  late Stream<UserState> _userStateStream;
  int _selectedIndex = 1;
  String _userEstado = "0";
  String _userName = "Usuario";
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(viewportFraction: 0.3, initialPage: _selectedIndex);
    _initializeStreams();
  }

  void _initializeStreams() {
    _horariosStream = FirebaseFirestore.instance
        .collection('Horarios')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Horario.fromFirestore(doc)).toList());

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStateStream = FirebaseFirestore.instance
          .collection('UsersInAct')
          .doc(user.uid)
          .snapshots()
          .map((doc) => UserState(
        userId: doc.id,
        nombre: doc.data()?['fName'] ?? 'Usuario',
        estado: doc.data()?['estado'] ?? '0',
        token: doc.data()?['token'],
      ));

      _userStateStream.listen((userState) {
        setState(() {
          _userEstado = userState.estado;
          _userName = userState.nombre;
        });
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Header con altura reducida: se ha disminuido el contenedor general (de 110 a 100 + topPadding)
  /// y se han ajustado los márgenes internos (padding superior reducido de topPadding+20 a topPadding+12)
  /// sin cambiar el tamaño de los elementos.
  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      height: 100 + topPadding, // Altura reducida
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.color4],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Se ha reducido el padding superior para disminuir el espacio interno sin modificar los elementos
      padding: EdgeInsets.only(
        top: topPadding + 12,
        left: 20,
        right: 20,
        bottom: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar con indicador de estado
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.person, size: 32, color: AppColors.primary),
                  ),
                  if (_userEstado == "0")
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola, $_userName",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Contenedor con estado (sin cambiar el tamaño de la fuente ni los elementos)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _userEstado == "0"
                            ? Colors.green.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _userEstado == "0"
                            ? "✨ Puedes brindar reciclables"
                            : "⏳ No puedes brindar ahora",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Day Card con márgenes verticales reducidos para un slider más compacto.
  Widget _buildDayCard(Horario? horario, int index, String label) {
    final isSelected = index == _selectedIndex;
    return GestureDetector(
      onTap: () => _onCardSelected(index),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isSelected ? 4 : 8,
          vertical: isSelected ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSelected ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
              if (horario != null)
                Text(
                  horario.dia.toUpperCase(),
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 10,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Contenedor de información detallada con espacios internos ajustados.
  Widget _buildDetailPanel(Horario? horario) {
    if (horario == null) {
      return Center(
        child: Text(
          "No hay información disponible",
          style: TextStyle(fontSize: 16, color: AppColors.textDark),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Sombreados adicionales para resaltar el contenedor
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            horario.matinfo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_getLabel(_selectedIndex)} - ${horario.dia.toUpperCase()}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.access_time, "Horario: ${horario.horario}"),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.block, "No recibe: ${horario.qnr}"),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.info_outline, "Cantidad mínima: ${horario.cantidadMinima}"),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildGradientButton("Más información", Icons.help_outline, _openMoreInfo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGradientButton(
                  _userEstado == "0" ? "Brindar reciclable" : "Esperando recolección",
                  Icons.recycling,
                  _userEstado == "0" ? () => _navigateToResiduos(horario) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(String text, IconData icon, VoidCallback? onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.color4],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToResiduos(Horario horario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResiduosGridActivity(selectedCantMin: horario.cantidadMinima),
      ),
    );
  }

  // Métodos auxiliares sin cambios

  Horario? _findHorarioOrNull(List<Horario> all, int day) {
    for (final h in all) {
      if (h.numDia == day) return h;
    }
    return null;
  }

  List<Horario?> _getAyerHoyManana(List<Horario> all) {
    final now = DateTime.now();
    final hoyNum = now.weekday;
    final ayerNum = (hoyNum == 1) ? 7 : hoyNum - 1;
    final mananaNum = (hoyNum == 7) ? 1 : hoyNum + 1;

    return [
      _findHorarioOrNull(all, ayerNum),
      _findHorarioOrNull(all, hoyNum),
      _findHorarioOrNull(all, mananaNum),
    ];
  }

  String _getLabel(int index) {
    if (index == 0) return "AYER";
    if (index == 1) return "HOY";
    if (index == 2) return "MAÑANA";
    return "";
  }

  void _onCardSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  Future<void> _openMoreInfo() async {
    final Uri url = Uri.parse("https://bioway.com.mx/biowayapp.html#guia-reciclaje");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se pudo abrir el enlace")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<Horario>>(
              stream: _horariosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("No hay datos disponibles"));
                }

                final days = _getAyerHoyManana(snapshot.data!);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 60,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: 3,
                          onPageChanged: _onCardSelected,
                          itemBuilder: (context, index) {
                            return _buildDayCard(days[index], index, _getLabel(index));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 0),
                        child: Text(
                          "¿Qué se recicla hoy?",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ),
                      _buildDetailPanel(days[_selectedIndex]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Implementar navegación
        },
      ),
    );
  }
}
