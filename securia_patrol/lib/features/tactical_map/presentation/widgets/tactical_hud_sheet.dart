import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../../app/widgets/dispatch_flow.dart';
import '../../../../app/widgets/urgency_badge.dart';
import '../models/dispatch_step.dart';
import 'dispatch_action_button.dart';
import 'telemetry_tile.dart';

/// Ficha inferior de la intervención: en qué paso vas, qué pasa, dónde, a
/// cuánto, y abajo siempre el mismo botón con el siguiente paso.
class TacticalHudSheet extends StatelessWidget {
  final IncidentModel incident;
  final String patrolId;
  final double? distanceMeters;
  final int? etaMinutes;
  final ValueChanged<DispatchStep> onAction;
  final VoidCallback onCallCitizen;

  /// `null` oculta el botón cerrar (despacho propio en curso)
  final VoidCallback? onClose;

  /// Hora actual (inyectable en pruebas) para la hora estimada de llegada
  final DateTime? now;

  const TacticalHudSheet({
    super.key,
    required this.incident,
    required this.patrolId,
    this.distanceMeters,
    this.etaMinutes,
    required this.onAction,
    required this.onCallCitizen,
    this.onClose,
    this.now,
  });

  static const double _callButtonSize = 72;

  @override
  Widget build(BuildContext context) {
    final step = DispatchStep.of(incident, patrolId: patrolId);
    final takenByOther =
        step == DispatchStep.none &&
        !incident.status.isClosed &&
        incident.assignedPatrolCode != null;
    final distance = distanceMeters;
    final eta = etaMinutes;
    final arrival =
        eta == null
            ? DispatchStrings.noValue
            : DateFormat(
              'HH:mm',
            ).format((now ?? DateTime.now()).add(Duration(minutes: eta)));

    return Container(
      padding: const EdgeInsets.fromLTRB(
        SecuriaSpace.md,
        SecuriaSpace.sm + 2,
        SecuriaSpace.md,
        SecuriaSpace.md,
      ),
      decoration: const BoxDecoration(
        color: PatrolColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SecuriaRadius.xl - 2),
        ),
        border: Border(top: BorderSide(color: PatrolColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      step == DispatchStep.none
                          ? Text(
                            incident.status.label,
                            style: PatrolTypography.caption,
                          )
                          : DispatchFlow(current: step.index),
                ),
                if (onClose != null)
                  IconButton(
                    tooltip: DispatchStrings.closeCard,
                    onPressed: onClose,
                    constraints: const BoxConstraints.tightFor(
                      width: SecuriaTouch.patrol,
                      height: SecuriaTouch.patrol - 16,
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: PatrolColors.inkMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SecuriaSpace.xs),

            // Qué y dónde, con la urgencia a la derecha
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.type.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PatrolTypography.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        incident.location.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PatrolTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SecuriaSpace.sm),
                UrgencyBadge(urgency: incident.urgency, compact: true),
              ],
            ),
            if (incident.description.isNotEmpty) ...[
              const SizedBox(height: SecuriaSpace.xs),
              _CitizenQuote(
                text: incident.description,
                hasPhoto: incident.photoPath != null,
              ),
            ],
            const SizedBox(height: SecuriaSpace.sm),

            TelemetryStrip(
              items: [
                (
                  DispatchStrings.distanceLabel,
                  distance == null
                      ? DispatchStrings.noValue
                      : GeoUtils.formatDistance(distance / 1000),
                ),
                (
                  DispatchStrings.etaLabel,
                  eta == null
                      ? DispatchStrings.noValue
                      : DispatchStrings.minutes(eta),
                ),
                (DispatchStrings.arrivalTimeLabel, arrival),
              ],
            ),
            const SizedBox(height: SecuriaSpace.sm),

            // Llamar a la izquierda; la acción principal ocupa el resto
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CallButton(onPressed: onCallCitizen, size: _callButtonSize),
                const SizedBox(width: SecuriaSpace.xs),
                Expanded(
                  child:
                      takenByOther
                          ? _TakenByOther(unit: incident.assignedPatrolCode!)
                          : DispatchActionButton(
                            step: step,
                            onPressed: () => onAction(step),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CitizenQuote extends StatelessWidget {
  final String text;
  final bool hasPhoto;

  const _CitizenQuote({required this.text, required this.hasPhoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: SecuriaSpace.sm - 2),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: PatrolColors.border, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '“$text”',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: PatrolTypography.bodyMedium,
            ),
          ),
          if (hasPhoto) ...[
            const SizedBox(width: SecuriaSpace.xs),
            const Icon(
              Icons.photo_camera_rounded,
              size: 18,
              color: PatrolColors.inkMuted,
            ),
          ],
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const _CallButton({required this.onPressed, required this.size});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SecuriaRadius.lg + 2);

    return Semantics(
      button: true,
      label: DispatchStrings.callCitizenHint,
      excludeSemantics: true,
      child: Material(
        color: PatrolColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: PatrolColors.border),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_rounded,
                  color: PatrolColors.ink,
                  size: 26,
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SecuriaSpace.xxs,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DispatchStrings.callCitizen,
                      maxLines: 1,
                      style: PatrolTypography.caption.copyWith(
                        color: PatrolColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TakenByOther extends StatelessWidget {
  final String unit;

  const _TakenByOther({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: SecuriaTouch.primaryAction),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: SecuriaSpace.md),
      decoration: BoxDecoration(
        color: PatrolColors.card,
        borderRadius: BorderRadius.circular(SecuriaRadius.lg + 2),
        border: Border.all(color: PatrolColors.border),
      ),
      child: Text(
        DispatchStrings.takenBy(unit),
        textAlign: TextAlign.center,
        style: PatrolTypography.label.copyWith(color: PatrolColors.inkMuted),
      ),
    );
  }
}
