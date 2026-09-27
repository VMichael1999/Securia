import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Panel inferior que reemplaza al botón SOS mientras hay una alerta activa.
///
/// Responde de un vistazo las dos preguntas del ciudadano: ¿me escucharon? y
/// ¿cuánto falta? Deja a mano llamar al 105, agregar detalles o cancelar.
class AlertStatusTracker extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onAddDetails;
  final VoidCallback onCancel;

  const AlertStatusTracker({
    super.key,
    required this.incident,
    required this.onTap,
    required this.onCall,
    required this.onAddDetails,
    required this.onCancel,
  });

  static const List<IncidentStatus> _steps = [
    IncidentStatus.reportado,
    IncidentStatus.asignado,
    IncidentStatus.enCamino,
    IncidentStatus.enLugar,
  ];

  static const List<String> _stepLabels = [
    SosStrings.stepSent,
    SosStrings.stepAssigned,
    SosStrings.stepOnTheWay,
    SosStrings.stepOnSite,
  ];

  String get _headline {
    switch (incident.status) {
      case IncidentStatus.asignado:
        return SosStrings.trackerAssigned;
      case IncidentStatus.enCamino:
        return SosStrings.trackerOnTheWay;
      case IncidentStatus.enLugar:
        return SosStrings.trackerOnSite;
      default:
        return SosStrings.trackerSearching;
    }
  }

  /// Unidad asignada y, si viene en camino, tiempo estimado de llegada
  String? get _detail {
    final unit = incident.assignedPatrolCode;
    if (unit == null) return null;

    final patrolLocation = incident.assignedPatrolLocation;
    if (incident.status == IncidentStatus.enCamino && patrolLocation != null) {
      final km = GeoUtils.calculateDistanceKm(
        patrolLocation,
        incident.location,
      );
      final eta = GeoUtils.estimateEtaMinutes(
        km,
        averageSpeedKmh: GeoUtils.patrolResponseSpeedKmh,
      );
      return '$unit · ${SosStrings.trackerEta(eta)}';
    }
    return '${SosStrings.trackerUnit} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps
        .indexOf(incident.status)
        .clamp(0, _steps.length - 1);
    final isSearching = incident.status == IncidentStatus.reportado;
    final accent =
        isSearching ? AppColors.emergencyRed : AppColors.primaryGreen;
    final detail = _detail;

    return Material(
      color: AppColors.surface,
      elevation: 12,
      shadowColor: AppColors.primaryNavy.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSearching
                          ? Icons.cell_tower_rounded
                          : Icons.local_police_rounded,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _headline,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        if (detail != null)
                          Text(
                            detail,
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _TypeChip(type: incident.type),
                ],
              ),
              const SizedBox(height: 14),
              AlertProgressSteps(
                labels: _stepLabels,
                currentIndex: currentStep,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _TrackerButton(
                      label: SosStrings.call105,
                      icon: Icons.phone_rounded,
                      background: AppColors.primaryNavy,
                      foreground: AppColors.pureWhite,
                      onPressed: onCall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: _TrackerButton(
                      label: SosStrings.addDetails,
                      icon: Icons.add_a_photo_outlined,
                      background: AppColors.primaryGreenLight,
                      foreground: AppColors.primaryGreen,
                      onPressed: onAddDetails,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _TrackerButton(
                      label: SosStrings.cancelAlert,
                      background: AppColors.surfaceMuted,
                      foreground: AppColors.textSecondary,
                      onPressed: onCancel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de progreso por pasos con etiqueta bajo cada segmento
class AlertProgressSteps extends StatelessWidget {
  final List<String> labels;
  final int currentIndex;

  const AlertProgressSteps({
    super.key,
    required this.labels,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        i <= currentIndex
                            ? AppColors.primaryGreen
                            : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        i == currentIndex ? FontWeight.w800 : FontWeight.w600,
                    color:
                        i <= currentIndex
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IncidentType type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 14, color: type.color),
          const SizedBox(width: 4),
          Text(
            type.shortLabel,
            style: TextStyle(
              color: type.color,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackerButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  const _TrackerButton({
    required this.label,
    this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
