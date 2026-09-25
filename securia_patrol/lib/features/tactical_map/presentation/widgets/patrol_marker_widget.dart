import 'package:flutter/material.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';

/// Marcador táctico de unidad policial o patrullero en el mapa
class PatrolMarkerWidget extends StatefulWidget {
  final String unitCode;
  final bool isSirenActive;

  const PatrolMarkerWidget({
    super.key,
    required this.unitCode,
    this.isSirenActive = false,
  });

  @override
  State<PatrolMarkerWidget> createState() => _PatrolMarkerWidgetState();
}

class _PatrolMarkerWidgetState extends State<PatrolMarkerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _sirenController;

  @override
  void initState() {
    super.initState();
    _sirenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.isSirenActive) {
      _sirenController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PatrolMarkerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSirenActive && !oldWidget.isSirenActive) {
      _sirenController.repeat(reverse: true);
    } else if (!widget.isSirenActive && oldWidget.isSirenActive) {
      _sirenController.stop();
      _sirenController.reset();
    }
  }

  @override
  void dispose() {
    _sirenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sirenController,
      builder: (context, child) {
        final glowColor = widget.isSirenActive
            ? (_sirenController.value > 0.5
                ? PatrolColors.alertCrimson
                : PatrolColors.policeBlue)
            : PatrolColors.cyanAccent;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge con el código de patrulla
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: PatrolColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: glowColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                widget.unitCode,
                style: PatrolTypography.tacticalCode.copyWith(
                  fontSize: 10,
                  color: glowColor,
                ),
              ),
            ),
            const SizedBox(height: 3),

            // Icono central de patrulla con halo brillante
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PatrolColors.tacticalNavy,
                border: Border.all(color: glowColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: widget.isSirenActive ? 0.8 : 0.4),
                    blurRadius: widget.isSirenActive ? 14 : 8,
                    spreadRadius: widget.isSirenActive ? 3 : 1,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.isSirenActive
                      ? Icons.emergency_rounded
                      : Icons.local_police_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
