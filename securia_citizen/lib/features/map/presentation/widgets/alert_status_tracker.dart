import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Panel que reemplaza al SOS mientras hay una alerta activa.
///
/// Lo más grande es lo que la persona necesita saber: en cuántos minutos llega
/// la ayuda. El progreso va en un solo color (verde = la ayuda viene) y
/// "Cancelar alerta" queda como enlace, visible pero difícil de tocar sin querer.
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

  double? get _patrolDistanceKm {
    final patrol = incident.assignedPatrolLocation;
    if (patrol == null) return null;
    return GeoUtils.calculateDistanceKm(patrol, incident.location);
  }

  String get _headline {
    final km = _patrolDistanceKm;
    return switch (incident.status) {
      IncidentStatus.asignado => SosStrings.trackerAssigned,
      IncidentStatus.enCamino => km == null
          ? SosStrings.trackerAssigned
          : SosStrings.trackerArrivesIn(
              GeoUtils.estimateEtaMinutes(
                km,
                averageSpeedKmh: GeoUtils.patrolResponseSpeedKmh,
              ),
            ),
      IncidentStatus.enLugar => SosStrings.trackerOnSite,
      _ => SosStrings.trackerSearching,
    };
  }

  /// "PL-402 · S3 C. Ramírez · a 0.8 km"
  String? get _unitLine {
    final unit = incident.assignedPatrolCode;
    if (unit == null) return null;
    final officer = incident.assignedOfficerName ?? '';
    final km = _patrolDistanceKm;
    if (km == null || incident.status == IncidentStatus.enLugar) {
      return SosStrings.trackerUnitNoDistance(unit, officer);
    }
    return SosStrings.trackerUnit(unit, officer, GeoUtils.formatDistance(km));
  }

  @override
  Widget build(BuildContext context) {
    final currentStep =
        _steps.indexOf(incident.status).clamp(0, _steps.length - 1);
    final since = DateFormat('HH:mm').format(incident.timestamp);
    final unitLine = _unitLine;
    final isSearching = incident.status == IncidentStatus.reportado;

    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: AppColors.ink.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(SecuriaRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(SecuriaRadius.xl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SecuriaSpace.lg,
            SecuriaSpace.md,
            SecuriaSpace.lg,
            SecuriaSpace.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tu alerta: el único rojo de la pantalla mientras está activa
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.sos,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: SecuriaSpace.xs),
                  Expanded(
                    child: Text(
                      SosStrings.activeSince(since),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.sos,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SecuriaSpace.sm),
              AlertProgressSteps(labels: _stepLabels, currentIndex: currentStep),
              const SizedBox(height: SecuriaSpace.md),
              Semantics(
                liveRegion: true,
                child: AnimatedSwitcher(
                  duration: SecuriaMotion.of(context, SecuriaMotion.normal),
                  child: Text(
                    _headline,
                    key: ValueKey(_headline),
                    style: AppTypography.headline.copyWith(
                      color: isSearching ? AppColors.ink : AppColors.help,
                    ),
                  ),
                ),
              ),
              if (unitLine != null) ...[
                const SizedBox(height: SecuriaSpace.xxs),
                Text(unitLine, style: AppTypography.mono(size: 14)),
              ],
              const SizedBox(height: SecuriaSpace.xs),
              Row(
                children: [
                  Icon(incident.type.icon, size: 16, color: AppColors.inkSecondary),
                  const SizedBox(width: SecuriaSpace.xxs),
                  Expanded(
                    child: Text(
                      incident.type.title,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SecuriaSpace.md),
              Row(
                children: [
                  Expanded(
                    child: _TrackerButton(
                      label: SosStrings.call105,
                      icon: Icons.call_rounded,
                      filled: true,
                      onPressed: onCall,
                    ),
                  ),
                  const SizedBox(width: SecuriaSpace.xs),
                  Expanded(
                    child: _TrackerButton(
                      label: SosStrings.addDetails,
                      icon: Icons.add_a_photo_outlined,
                      filled: false,
                      onPressed: onAddDetails,
                    ),
                  ),
                ],
              ),
              Center(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.inkSecondary,
                    minimumSize: const Size(SecuriaTouch.min, SecuriaTouch.min),
                  ),
                  child: Text(
                    SosStrings.cancelAlert,
                    style: AppTypography.bodySmall.copyWith(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pasos de la alerta en un solo color, con el texto de cada uno
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
    return Semantics(
      label: '${labels[currentIndex]}, paso ${currentIndex + 1} de ${labels.length}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: SecuriaSpace.xxs + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: SecuriaMotion.of(context, SecuriaMotion.normal),
                    curve: SecuriaMotion.standard,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= currentIndex ? AppColors.help : AppColors.border,
                      borderRadius: BorderRadius.circular(SecuriaRadius.pill),
                    ),
                  ),
                  const SizedBox(height: SecuriaSpace.xxs),
                  Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: i <= currentIndex ? AppColors.ink : AppColors.inkMuted,
                      fontWeight: i == currentIndex ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  const _TrackerButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SecuriaRadius.md),
    );
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: SecuriaSpace.xs),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.buttonLabel,
          ),
        ),
      ],
    );

    return SizedBox(
      height: 52,
      child: filled
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.onColor,
                shape: shape,
              ),
              child: child,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.borderStrong),
                shape: shape,
              ),
              child: child,
            ),
    );
  }
}
