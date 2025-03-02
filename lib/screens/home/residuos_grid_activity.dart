// lib/screens/home/residuos_grid_activity.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/material_reciclable.dart';
import '../../services/firebase/residuos_service.dart' as service;
import '../../widgets/cards/material_selection_card.dart';
import '../../widgets/dialogs/confirmation_dialog.dart';
import '../../theme/app_colors.dart';
import 'tirar_activity.dart';

class ResiduosGridActivity extends StatefulWidget {
  final String selectedCantMin;

  const ResiduosGridActivity({
    Key? key,
    required this.selectedCantMin,
  }) : super(key: key);

  @override
  _ResiduosGridActivityState createState() => _ResiduosGridActivityState();
}

class _ResiduosGridActivityState extends State<ResiduosGridActivity> {
  final service.ResiduosService _residuosService = service.ResiduosService();
  final ValueNotifier<Map<String, Map<String, dynamic>>> _selectedMaterialsNotifier =
  ValueNotifier<Map<String, Map<String, dynamic>>>({});
  final ValueNotifier<int> _checkedButtonsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> _currentMinimumNotifier = ValueNotifier<String>('');
  List<MaterialReciclable>? _cachedMaterials;

  @override
  void initState() {
    super.initState();
    _currentMinimumNotifier.value = widget.selectedCantMin;
  }

  @override
  void dispose() {
    _selectedMaterialsNotifier.dispose();
    _checkedButtonsNotifier.dispose();
    _currentMinimumNotifier.dispose();
    super.dispose();
  }

  void _handleMaterialSelection(MaterialReciclable material, bool isSelected) {
    final currentSelected = Map<String, Map<String, dynamic>>.from(_selectedMaterialsNotifier.value);

    if (isSelected) {
      currentSelected[material.id] = {
        'cantMin': material.cantidadMinima,
        'unit': material.unidad,
      };
      _checkedButtonsNotifier.value++;
      _currentMinimumNotifier.value = '${material.cantidadMinima} ${material.unidad}';
    } else {
      currentSelected.remove(material.id);
      _checkedButtonsNotifier.value--;
      if (currentSelected.isEmpty) {
        _currentMinimumNotifier.value = widget.selectedCantMin;
      } else {
        final lastMaterial = currentSelected.entries.last;
        _currentMinimumNotifier.value =
        '${lastMaterial.value['cantMin']} ${lastMaterial.value['unit']}';
      }
    }

    _selectedMaterialsNotifier.value = currentSelected;
  }

  Future<void> _showConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: '¡RECUERDA!',
        message: 'Para donar debes tener el mínimo especificado de material que vas a brindar.',
        confirmText: 'CONTINUAR',
        cancelText: 'ATRÁS',
      ),
    );

    if (result == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TirarActivity(
            selectedMaterials: _selectedMaterialsNotifier.value,
          ),
        ),
      );
    }
  }

  Future<void> _openMoreInfo() async {
    final infoUrl = 'https://bioway.com.mx/biowayapp.html#guia-reciclaje';
    final url = Uri.parse(infoUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  Widget _buildMinimumQuantityHeader() {
    return ValueListenableBuilder<String>(
      valueListenable: _currentMinimumNotifier,
      builder: (context, currentMinimum, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.scale,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Cantidad mínima aceptada',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        currentMinimum,
                        key: ValueKey<String>(currentMinimum),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
                valueListenable: _selectedMaterialsNotifier,
                builder: (context, selectedMaterials, _) {
                  if (selectedMaterials.length > 1) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+${selectedMaterials.length - 1}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialCard(MaterialReciclable material) {
    return ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
      valueListenable: _selectedMaterialsNotifier,
      builder: (context, selectedMaterials, _) {
        return MaterialSelectionCard(
          key: ValueKey(material.id),
          material: material,
          initialSelected: selectedMaterials.containsKey(material.id),
          onSelected: (isSelected) => _handleMaterialSelection(material, isSelected),
        );
      },
    );
  }

  Widget _buildMaterialsGrid() {
    return StreamBuilder<List<MaterialReciclable>>(
      stream: _residuosService.getMaterialesReciclables(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Error cargando materiales',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No hay materiales disponibles',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        _cachedMaterials = snapshot.data;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _cachedMaterials!.length,
          itemBuilder: (context, index) {
            return _buildMaterialCard(_cachedMaterials![index]);
          },
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return ValueListenableBuilder<int>(
      valueListenable: _checkedButtonsNotifier,
      builder: (context, count, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: _buildButton(
                    "MÁS INFORMACIÓN",
                    Icons.info_outline,
                    _openMoreInfo,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                    "CONTINUAR",
                    Icons.arrow_forward,
                    count > 0 ? _showConfirmationDialog : null,
                    isOutlined: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(
      String text,
      IconData icon,
      VoidCallback? onPressed,
      {bool isOutlined = false}
      ) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: !isOutlined && onPressed != null
            ? LinearGradient(
          colors: [AppColors.primary, AppColors.color4],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        borderRadius: BorderRadius.circular(22),
        border: isOutlined
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        color: onPressed == null ? Colors.grey.shade200 : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: onPressed == null
                      ? Colors.grey
                      : isOutlined
                      ? AppColors.primary
                      : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: onPressed == null
                        ? Colors.grey
                        : isOutlined
                        ? AppColors.primary
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seleccionar Materiales',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.color4],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildMinimumQuantityHeader(),
          Expanded(
            child: _buildMaterialsGrid(),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }
}