import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../../app/widgets/patrol_buttons.dart';
import '../../../../app/widgets/urgency_badge.dart';
import 'telemetry_tile.dart';

/// Alerta entrante a pantalla completa: se lee en dos segundos.
///
/// El texto va alineado a la izquierda y en el orden en que se decide:
/// urgencia, qué pasa, dónde y a cuánto. Entra desde abajo con un solo pulso
/// (sin parpadeo continuo que distraiga al manejar), vibra y se anuncia al
/// lector de pantalla.
class IncomingAlertOverlay extends StatefulWidget {
  final IncidentModel incident;
  final double distanceMeters;
  final int etaMinutes;

  /// Otras alertas que esperan en la cola
  final int queuedCount;
  final VoidCallback onAccept;
  final VoidCallback onIgnore;

  /// Reloj inyectable para el "hace N s"
  final DateTime Function()? clock;

  const IncomingAlertOverlay({
    super.key,
    required this.incident,
    required this.distanceMeters,
    required this.etaMinutes,
    required this.onAccept,
    required this.onIgnore,
    this.queuedCount = 0,
    this.clock,
  });

  @override
  State<IncomingAlertOverlay> createState() => _IncomingAlertOverlayState();
}

class _IncomingAlertOverlayState extends State<IncomingAlertOverlay> {
  Timer? _ticker;

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  @override
  void didUpdateWidget(IncomingAlertOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.incident.id != widget.incident.id) _notify();
  }

  void _notify() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    final incident = widget.incident;
    SemanticsService.announce(
      DispatchStrings.incomingAnnouncement(
        incident.urgency.label,
        incident.type.title,
        GeoUtils.formatDistance(widget.distanceMeters / 1000),
      ),
      Directionality.of(context),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final time = DateFormat('HH:mm').format(incident.timestamp);

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: UrgencyBadge(urgency: incident.urgency),
        ),
        const SizedBox(height: SecuriaSpace.sm),
        Text(incident.type.title, style: PatrolTypography.display),
        const SizedBox(height: SecuriaSpace.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.location_on_rounded,
                size: 18,
                color: PatrolColors.inkMuted,
              ),
            ),
            const SizedBox(width: SecuriaSpace.xs),
            Expanded(
              child: Text(
                incident.location.address,
                style: PatrolTypography.bodyLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: SecuriaSpace.sm),
        Row(
          children: [
            Expanded(
              child: TelemetryTile(
                label: DispatchStrings.distanceLabel,
                value: GeoUtils.formatDistance(widget.distanceMeters / 1000),
              ),
            ),
            const SizedBox(width: SecuriaSpace.xs),
            Expanded(
              child: TelemetryTile(
                label: DispatchStrings.etaLabel,
                value: DispatchStrings.minutes(widget.etaMinutes),
              ),
            ),
          ],
        ),
        const SizedBox(height: SecuriaSpace.sm),
        Container(
          padding: const EdgeInsets.only(left: SecuriaSpace.sm - 2),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: PatrolColors.border, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (incident.description.isNotEmpty)
                Text(
                  '“${incident.description}”',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PatrolTypography.bodyMedium,
                ),
              Text(
                incident.type == IncidentType.emergenciaGeneral
                    ? DispatchStrings.sosAt(time)
                    : DispatchStrings.reportedAt(time),
                style: PatrolTypography.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: SecuriaSpace.md),
        PrimaryActionButton(
          label: DispatchStrings.incomingAccept,
          icon: Icons.check_rounded,
          semanticHint: DispatchStrings.actionHintAccept,
          onPressed: widget.onAccept,
        ),
        const SizedBox(height: SecuriaSpace.xxs),
        TextButton(
          onPressed: widget.onIgnore,
          style: TextButton.styleFrom(
            foregroundColor: PatrolColors.inkMuted,
            minimumSize: const Size.fromHeight(SecuriaTouch.patrol),
            textStyle: PatrolTypography.label,
          ),
          child: Text(
            widget.queuedCount > 0
                ? DispatchStrings.incomingIgnoreQueued(widget.queuedCount)
                : DispatchStrings.incomingIgnore,
          ),
        ),
      ],
    );

    if (!reduceMotion) {
      body = body
          .animate()
          .fadeIn(duration: SecuriaMotion.normal)
          .slideY(
            begin: 0.12,
            end: 0,
            duration: SecuriaMotion.slow,
            curve: SecuriaMotion.standard,
          );
    }

    // El título ya mide 32 px: con texto del sistema muy grande se limita la
    // escala para que urgencia, dirección y Aceptar quepan sin desplazarse
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3)),
      child: _frame(body, reduceMotion),
    );
  }

  Widget _frame(Widget body, bool reduceMotion) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: DispatchStrings.incomingTitle,
      child: Material(
        color: PatrolColors.scrim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SecuriaSpace.lg - 2,
              SecuriaSpace.xs,
              SecuriaSpace.lg - 2,
              SecuriaSpace.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _PulseDot(reduceMotion: reduceMotion),
                    const SizedBox(width: SecuriaSpace.sm - 2),
                    Expanded(
                      child: Text(
                        DispatchStrings.incomingTitle,
                        style: PatrolTypography.label,
                      ),
                    ),
                    Text(
                      DispatchStrings.ago(
                        _now.difference(widget.incident.timestamp),
                      ),
                      style: PatrolTypography.mono(
                        size: 12,
                        color: PatrolColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                // Anclado abajo, al alcance del pulgar; se desplaza si el
                // texto grande no cabe
                Expanded(
                  child: SingleChildScrollView(reverse: true, child: body),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Punto rojo que late una sola vez al entrar la alerta
class _PulseDot extends StatelessWidget {
  final bool reduceMotion;

  const _PulseDot({required this.reduceMotion});

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: PatrolColors.critical,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: PatrolColors.critical.withValues(alpha: 0.28),
            spreadRadius: 5,
          ),
        ],
      ),
    );
    if (reduceMotion) return dot;
    // Un solo latido: crece y vuelve a su tamaño, sin repetirse
    return dot.animate().scaleXY(
      begin: 1.6,
      end: 1,
      duration: SecuriaMotion.slow * 2,
      curve: Curves.elasticOut,
    );
  }
}
