import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';

/// Banner HUD flotante de alerta de proximidad táctica
class ProximityRadarBanner extends StatelessWidget {
  final IncidentModel incident;
  final double distanceMeters;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const ProximityRadarBanner({
    super.key,
    required this.incident,
    required this.distanceMeters,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = distanceMeters >= 1000
        ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
        : '${distanceMeters.toStringAsFixed(0)} m';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PatrolColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PatrolColors.alertCrimson,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: PatrolColors.alertCrimson.withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PatrolColors.alertCrimson.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: PatrolColors.alertCrimson,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🚨 ALERTA EN RADAR',
                          style: TextStyle(
                            color: PatrolColors.alertCrimson,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: PatrolColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: PatrolColors.surfaceBorder),
                          ),
                          child: Text(
                            distanceText,
                            style: PatrolTypography.telemetry.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${incident.type.title}: ${incident.title}',
                      style: PatrolTypography.titleMedium.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      incident.location.address,
                      style: PatrolTypography.bodySmall.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: PatrolColors.textMuted, size: 20),
                onPressed: onDismiss,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text(
                    'ACEPTAR DESPACHO INMEDIATO',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PatrolColors.alertCrimson,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
