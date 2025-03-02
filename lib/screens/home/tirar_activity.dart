// lib/screens/home/tirar_activity.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase/residuos_service.dart';
import '../../widgets/dialogs/active_status_dialog.dart';
import '../../widgets/buttons/animated_button.dart';
import '../../theme/app_colors.dart';
import 'main_activity.dart';
import '../../widgets/intro_page.dart';

class TirarActivity extends StatefulWidget {
  final Map<String, Map<String, dynamic>> selectedMaterials;

  const TirarActivity({
    Key? key,
    required this.selectedMaterials,
  }) : super(key: key);

  @override
  _TirarActivityState createState() => _TirarActivityState();
}

class _TirarActivityState extends State<TirarActivity>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ResiduosService _residuosService = ResiduosService();
  int _currentPage = 0;
  bool _showFinalButton = false;

  final List<Map<String, dynamic>> _introPages = [
    {
      'title': 'Comienza tu proceso de brindar residuo reciclable',
      'description':
      'En las siguientes páginas encontrarás información sobre los materiales.',
      'image': 'assets/images/z_r.png',
    },
    {
      'title': 'Deposita tu residuo/Tira tu residuo',
      'description':
      'Ahora que tienes tu residuo separado y ordenado es momento de depositarlo en una bolsa/contenedor para que el recolector pueda llevarlo a los centros de acopio.',
      'image': 'assets/images/i2.png',
    },
    {
      'title': 'Finalizar tarea',
      'description':
      'Por favor pulsa sobre el botón finalizar tarea, de esta manera concluirás tu tarea y se te activará como punto de recolección para que el recolector sepa que hay residuos reciclables cerca de tu domicilio.',
      'image': 'assets/images/i4.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _introPages.length,
            onPageChanged: _handlePageChange,
            itemBuilder: (context, index) {
              return IntroPage(
                title: _introPages[index]['title'],
                description: _introPages[index]['description'],
                imagePath: _introPages[index]['image'],
              );
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (!_showFinalButton) ...[
                  TabPageSelector(
                    controller: TabController(
                      length: _introPages.length,
                      vsync: this,
                      initialIndex: _currentPage,
                    ),
                    selectedColor: AppColors.color5,
                  ),
                  FloatingActionButton(
                    onPressed: _nextPage,
                    child: const Icon(Icons.arrow_forward),
                    backgroundColor: AppColors.color5,
                  ),
                ] else
                  FadeTransition(
                    opacity: const AlwaysStoppedAnimation(1.0),
                    child: SlideTransition(
                      position: const AlwaysStoppedAnimation(Offset.zero),
                      child: AnimatedButton(
                        onPressed: _finalizarTarea,
                        child: const Text(
                          '¡Finalizar Tarea!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePageChange(int page) {
    setState(() {
      _currentPage = page;
      _showFinalButton = page == _introPages.length - 1;
    });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finalizarTarea() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await _residuosService.registrarResiduos(
        userId: userId,
        selectedMaterials: widget.selectedMaterials,
      );

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ActiveStatusDialog(
          onClose: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MainActivity()),
                  (route) => false,
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al registrar los residuos. Por favor intenta de nuevo.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
