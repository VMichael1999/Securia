import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';

/// Marcador estilizado en el mapa para incidentes de seguridad
class IncidentMarkerWidget extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;

  const IncidentMarkerWidget({
    super.key,
    required this.incident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = incident.type.color;
    final isToday = incident.isToday;
    final isResolved = incident.status == IncidentStatus.resuelto;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo de brillo exterior si es de hoy y está activo
          if (isToday && !isResolved)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),

          // Pin principal
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isResolved ? const Color(0xFF64748B) : color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              incident.type.icon,
              color: Colors.white,
              size: 18,
            ),
          ),

          // Mini indicador de 'Hoy' o 'Resuelto'
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isResolved ? const Color(0xFF10B981) : (isToday ? color : Colors.grey),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                isResolved ? Icons.check : (isToday ? Icons.priority_high : Icons.access_time),
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
