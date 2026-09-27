import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import 'telemetry_tile.dart';

/// Alerta entrante a pantalla completa: imposible de pasar por alto.
///
/// Muestra solo lo que el agente necesita para decidir en segundos (qué, dónde,
/// a cuánto) y un botón enorme para aceptar. Vibra y suena al aparecer.
class IncomingAlertOverlay extends StatefulWidget {
  final IncidentModel incident;
  final double distanceMeters;
  final int etaMinutes;
  final VoidCallback onAccept;
  final VoidCallback onIgnore;

  const IncomingAlertOverlay({
    super.key,
    required this.incident,
    required this.distanceMeters,
    required this.etaMinutes,
    required this.onAccept,
    required this.onIgnore,
  });

  @override
  State<IncomingAlertOverlay> createState() => _IncomingAlertOverlayState();
}

class _IncomingAlertOverlayState extends State<IncomingAlertOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _notify();
  }

  @override
  void didUpdateWidget(IncomingAlertOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.incident.id != widget.incident.id) _notify();
  }

  void _notify() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final urgencyColor = incident.urgency.color;

    return Material(
      color: PatrolColors.overlayScrim,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            children: [
              // Encabezado pulsante
              AnimatedBuilder(
                animation: _pulse,
                builder:
                    (context, child) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: PatrolColors.alertCrimson.withValues(
                          alpha: 0.15 + 0.2 * _pulse.value,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: PatrolColors.alertCrimson),
                      ),
                      child: child,
                    ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_rounded,
                      color: PatrolColors.alertCrimson,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        DispatchStrings.incomingTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: PatrolColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Qué pasa
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: incident.type.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  incident.type.icon,
                  color: PatrolColors.textPrimary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                incident.type.title,
                textAlign: TextAlign.center,
                style: PatrolTypography.titleLarge.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: PatrolColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: urgencyColor),
                ),
                child: Text(
                  DispatchStrings.urgency(incident.urgency.label),
                  style: TextStyle(
                    color: urgencyColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Dónde
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: PatrolColors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      incident.location.address,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PatrolColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // A cuánto
              Row(
                children: [
                  Expanded(
                    child: TelemetryTile(
                      label: DispatchStrings.distanceLabel,
                      value: GeoUtils.formatDistance(
                        widget.distanceMeters / 1000,
                      ),
                      icon: Icons.straighten_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TelemetryTile(
                      label: DispatchStrings.etaLabel,
                      value: DispatchStrings.minutes(widget.etaMinutes),
                      icon: Icons.timer_outlined,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Decisión
              SizedBox(
                width: double.infinity,
                height: 72,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onAccept();
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 28),
                  label: const Text(
                    DispatchStrings.incomingAccept,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PatrolColors.policeAccent,
                    foregroundColor: PatrolColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: widget.onIgnore,
                child: const Text(
                  DispatchStrings.incomingIgnore,
                  style: TextStyle(
                    color: PatrolColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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
