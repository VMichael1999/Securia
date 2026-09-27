import 'package:flutter/material.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';

/// Dato de telemetría grande y legible de un vistazo (distancia, llegada…)
class TelemetryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const TelemetryTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PatrolColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PatrolColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: PatrolColors.policeAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: PatrolColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PatrolTypography.telemetry.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PatrolColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
