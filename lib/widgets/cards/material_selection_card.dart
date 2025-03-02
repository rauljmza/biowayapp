// lib/widgets/cards/material_selection_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/material_reciclable.dart';
import '../../utils/svg_processor.dart';
import '../../theme/app_colors.dart';

class MaterialSelectionCard extends StatefulWidget {
  final MaterialReciclable material;
  final bool initialSelected;
  final ValueChanged<bool> onSelected;

  const MaterialSelectionCard({
    Key? key,
    required this.material,
    required this.initialSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  _MaterialSelectionCardState createState() => _MaterialSelectionCardState();
}

class _MaterialSelectionCardState extends State<MaterialSelectionCard> with SingleTickerProviderStateMixin {
  late bool _selected;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSelection() {
    setState(() {
      _selected = !_selected;
      if (_selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onSelected(_selected);
  }

  Color _getCardColor() {
    try {
      final materialColor = Color(int.parse(widget.material.color.replaceAll('#', '0xFF')));
      return _selected
          ? materialColor.withOpacity(0.15)
          : Colors.white;
    } catch (e) {
      return _selected
          ? AppColors.primary.withOpacity(0.15)
          : Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTap: _toggleSelection,
          child: Container(
            decoration: BoxDecoration(
              color: _getCardColor(),
              border: Border.all(
                color: _selected ? AppColors.primary : Colors.grey.shade300,
                width: _selected ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (_selected)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIcon(),
                      const SizedBox(height: 6),
                      Text(
                        widget.material.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.material.cantidadMinima} ${widget.material.unidad}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.material.icon.isNotEmpty) {
      final processedSvg = processSvg(widget.material.icon);
      return Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _selected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SvgPicture.string(
          processedSvg,
          placeholderBuilder: (context) => const Icon(
            Icons.image,
            size: 24,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image,
          size: 24,
          color: Colors.grey,
        ),
      );
    }
  }
}