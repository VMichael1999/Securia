import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';

/// Marcador baliza táctica pulsante para incidentes en el mapa policial
class BeaconMarkerWidget extends StatefulWidget {
  final IncidentModel incident;
  final bool isSelected;
  final bool isAssignedToMe;
  final VoidCallback onTap;

  const BeaconMarkerWidget({
    super.key,
    required this.incident,
    required this.isSelected,
    this.isAssignedToMe = false,
    required this.onTap,
  });

  @override
  State<BeaconMarkerWidget> createState() => _BeaconMarkerWidgetState();
}

class _BeaconMarkerWidgetState extends State<BeaconMarkerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.incident.urgency == UrgencyLevel.critica ? 800 : 1400,
      ),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isAssignedToMe
        ? PatrolColors.cyanAccent
        : widget.incident.urgency == UrgencyLevel.critica
            ? PatrolColors.alertCrimson
            : widget.incident.type.color;

    final isResolved = widget.incident.status == IncidentStatus.resuelto;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Onda expansiva de baliza activa
            if (!isResolved)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: _fadeAnimation.value),
                      ),
                    ),
                  );
                },
              ),

            // Halo estático de selección
            if (widget.isSelected)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

            // Núcleo del marcador con icono de categoría
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.incident.type.icon,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
