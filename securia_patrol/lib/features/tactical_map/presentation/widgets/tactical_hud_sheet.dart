import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../models/dispatch_step.dart';
import 'dispatch_action_button.dart';
import 'telemetry_tile.dart';

/// Ficha inferior de la intervención: qué, dónde, a cuánto y un solo botón
/// con el siguiente paso.
class TacticalHudSheet extends StatelessWidget {
  final IncidentModel incident;
  final String patrolId;
  final double? distanceMeters;
  final int? etaMinutes;
  final ValueChanged<DispatchStep> onAction;
  final VoidCallback onCallCitizen;

  /// `null` oculta el botón cerrar (despacho propio en curso)
  final VoidCallback? onClose;

  const TacticalHudSheet({
    super.key,
    required this.incident,
    required this.patrolId,
    this.distanceMeters,
    this.etaMinutes,
    required this.onAction,
    required this.onCallCitizen,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final step = DispatchStep.of(incident, patrolId: patrolId);
    final takenByOther =
        step == DispatchStep.none &&
        !incident.status.isClosed &&
        incident.assignedPatrolCode != null;
    final distance = distanceMeters;
    final eta = etaMinutes;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: PatrolColors.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: PatrolColors.surfaceBorder, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: PatrolColors.background.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: PatrolColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Qué y en qué estado
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: incident.type.color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    incident.type.icon,
                    color: PatrolColors.textPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.type.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PatrolTypography.titleMedium.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: PatrolColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Badge(
                            text: incident.urgency.label.toUpperCase(),
                            color: incident.urgency.color,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: _Badge(
                              text: incident.status.label,
                              color: incident.status.badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: PatrolColors.textSecondary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: PatrolColors.surfaceElevated,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Dónde y lo que dijo el ciudadano
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: PatrolColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    incident.location.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PatrolColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (incident.photoPath != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      color: PatrolColors.policeAccent,
                      size: 16,
                    ),
                  ),
              ],
            ),
            if (incident.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                incident.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PatrolColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ],
            const SizedBox(height: 12),

            // A cuánto + contacto
            Row(
              children: [
                Expanded(
                  child: TelemetryTile(
                    label: DispatchStrings.distanceLabel,
                    value:
                        distance == null
                            ? DispatchStrings.noValue
                            : GeoUtils.formatDistance(distance / 1000),
                    icon: Icons.straighten_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TelemetryTile(
                    label: DispatchStrings.etaLabel,
                    value:
                        eta == null
                            ? DispatchStrings.noValue
                            : DispatchStrings.minutes(eta),
                    icon: Icons.timer_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 58,
                  height: 58,
                  child: IconButton(
                    tooltip: DispatchStrings.callCitizen,
                    onPressed: onCallCitizen,
                    icon: const Icon(Icons.phone_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: PatrolColors.policeBlue,
                      foregroundColor: PatrolColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          color: PatrolColors.surfaceBorder,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (takenByOther)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: PatrolColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  DispatchStrings.takenBy(incident.assignedPatrolCode!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PatrolColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              DispatchActionButton(step: step, onPressed: () => onAction(step)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.8)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
