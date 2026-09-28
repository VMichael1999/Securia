import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_map_style.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../../app/utils/phone_launcher.dart';
import '../bloc/patrol_bloc.dart';
import '../bloc/patrol_event.dart';
import '../bloc/patrol_state.dart';
import '../models/dispatch_step.dart';
import '../widgets/incoming_alert_overlay.dart';
import '../widgets/resolution_sheet.dart';
import '../widgets/status_toast.dart';
import '../widgets/tactical_hud_sheet.dart';

/// Mapa de la unidad en servicio: incidentes del sector, ruta al despacho en
/// curso y, abajo, la ficha con un solo botón para el siguiente paso.
class TacticalMapView extends StatefulWidget {
  const TacticalMapView({super.key});

  @override
  State<TacticalMapView> createState() => _TacticalMapViewState();
}

/// Cómo se dibuja un incidente en el mapa
enum _MarkerLook { critical, high, neutral, mine, takenByOther }

class _TacticalMapViewState extends State<TacticalMapView> {
  final _map = SecuriaMapController();
  final Map<String, BitmapDescriptor> _icons = {};
  final Set<String> _loadingIcons = {};
  String? _toast;
  Timer? _toastTimer;

  static const double _markerSize = 40;
  static const double _selectedMarkerSize = 52;

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() => _toast = message);
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  /// Ícono del marcador; se genera la primera vez y luego sale del caché
  BitmapDescriptor? _icon(
    String key, {
    required IconData icon,
    required Color fill,
    required Color iconColor,
    required Color ring,
    required double size,
  }) {
    final cached = _icons[key];
    if (cached != null || _loadingIcons.contains(key)) return cached;
    _loadingIcons.add(key);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    MapMarkerIcons.circle(
      icon: icon,
      fill: fill,
      iconColor: iconColor,
      ring: ring,
      size: size,
      devicePixelRatio: dpr,
    ).then((descriptor) {
      if (mounted) setState(() => _icons[key] = descriptor);
    });
    return null;
  }

  _MarkerLook _lookOf(IncidentModel incident, String patrolId) {
    if (incident.assignedPatrolId == patrolId) return _MarkerLook.mine;
    if (incident.assignedPatrolId != null) return _MarkerLook.takenByOther;
    return switch (incident.urgency) {
      UrgencyLevel.critica => _MarkerLook.critical,
      UrgencyLevel.alta => _MarkerLook.high,
      UrgencyLevel.media || UrgencyLevel.baja => _MarkerLook.neutral,
    };
  }

  BitmapDescriptor? _incidentIcon(
    IncidentModel incident,
    String patrolId,
    bool selected,
  ) {
    final look = _lookOf(incident, patrolId);
    final (fill, iconColor, ring) = switch (look) {
      _MarkerLook.critical => (
        PatrolColors.criticalFill,
        PatrolColors.onCritical,
        PatrolColors.background,
      ),
      _MarkerLook.high => (
        PatrolColors.high,
        PatrolColors.onAction,
        PatrolColors.background,
      ),
      _MarkerLook.neutral => (
        PatrolColors.elevated,
        PatrolColors.ink,
        PatrolColors.inkMuted,
      ),
      _MarkerLook.mine => (
        PatrolColors.action,
        PatrolColors.onAction,
        PatrolColors.background,
      ),
      _MarkerLook.takenByOther => (
        PatrolColors.card,
        PatrolColors.inkMuted,
        PatrolColors.border,
      ),
    };
    final size = selected ? _selectedMarkerSize : _markerSize;
    return _icon(
      '${incident.type.name}-${look.name}-$size',
      icon: incident.type.icon,
      fill: fill,
      iconColor: iconColor,
      ring: ring,
      size: size,
    );
  }

  Future<void> _runStep(
    BuildContext context,
    DispatchStep step,
    IncidentModel incident,
  ) async {
    final bloc = context.read<PatrolBloc>();
    switch (step) {
      case DispatchStep.accept:
        bloc.add(PatrolAcceptDispatch(incident));
      case DispatchStep.onTheWay:
        bloc.add(PatrolEnCamino(incident));
      case DispatchStep.arrived:
        bloc.add(PatrolEnLugar(incident));
      case DispatchStep.conclude:
        final note = await ResolutionSheet.show(
          context,
          acceptedAt: bloc.state.dispatchAcceptedAt,
          arrivedAt: bloc.state.dispatchArrivedAt,
        );
        if (note != null) {
          bloc.add(
            PatrolResolveIncident(incident: incident, resolutionNote: note),
          );
        }
      case DispatchStep.none:
        break;
    }
  }

  Future<void> _callCitizen(
    BuildContext context,
    IncidentModel incident,
  ) async {
    final ok = await PhoneLauncher.call(incident.citizenPhone);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(DispatchStrings.callUnavailable)),
      );
    }
  }

  List<SecuriaMapMarker> _markers(BuildContext context, PatrolState state) {
    final unit = state.currentPatrol;
    final displayed = state.activeDispatchedIncident ?? state.selectedIncident;

    return [
      SecuriaMapMarker(
        id: 'unit',
        position: unit.location,
        zIndex: 3,
        semanticLabel: DispatchStrings.unitMarker(unit.unitCode),
        icon: _icon(
          'unit',
          icon: Icons.navigation_rounded,
          fill: PatrolColors.background,
          iconColor: PatrolColors.action,
          ring: PatrolColors.action,
          size: 36,
        ),
      ),
      for (final incident in state.activeIncidents)
        SecuriaMapMarker(
          id: incident.id,
          position: incident.location,
          zIndex: incident.id == displayed?.id ? 2 : 1,
          icon: _incidentIcon(incident, unit.id, incident.id == displayed?.id),
          semanticLabel: DispatchStrings.incidentMarker(
            incident.urgency.label.toLowerCase(),
            incident.type.title,
            GeoUtils.formatDistance(
              GeoUtils.calculateDistanceKm(unit.location, incident.location),
            ),
          ),
          onTap:
              () => context.read<PatrolBloc>().add(
                PatrolSelectIncident(incident),
              ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      body: MultiBlocListener(
        listeners: [
          BlocListener<PatrolBloc, PatrolState>(
            listenWhen:
                (prev, curr) =>
                    curr.statusMessage != null &&
                    curr.statusMessage != prev.statusMessage,
            listener: (context, state) => _showToast(state.statusMessage!),
          ),
          // Al tomar un despacho, la cámara va al incidente
          BlocListener<PatrolBloc, PatrolState>(
            listenWhen:
                (prev, curr) =>
                    curr.activeDispatchedIncident != null &&
                    curr.activeDispatchedIncident?.id !=
                        prev.activeDispatchedIncident?.id,
            listener:
                (context, state) => _map.moveTo(
                  state.activeDispatchedIncident!.location,
                  zoom: 15,
                ),
          ),
        ],
        child: BlocBuilder<PatrolBloc, PatrolState>(
          builder: (context, state) {
            final unit = state.currentPatrol;
            final displayed =
                state.activeDispatchedIncident ?? state.selectedIncident;
            final incoming =
                state.activeDispatchedIncident == null
                    ? state.proximityAlertIncident
                    : null;

            return Stack(
              children: [
                Positioned.fill(
                  key: const ValueKey('map'),
                  child: SecuriaMap(
                    controller: _map,
                    center: unit.location,
                    zoom: 14.5,
                    style: PatrolMapStyle.night,
                    markers: _markers(context, state),
                    circles: [
                      SecuriaMapCircle(
                        id: 'coverage',
                        center: unit.location,
                        radiusMeters: state.radarRadiusKm * 1000,
                        fill: PatrolColors.action.withValues(alpha: 0.05),
                        stroke: PatrolColors.action.withValues(alpha: 0.35),
                      ),
                    ],
                    route: state.routePolyline,
                    routeColor: PatrolColors.action,
                    padding: EdgeInsets.only(
                      top: 64,
                      bottom: displayed == null ? 0 : 300,
                    ),
                  ),
                ),

                // Sirena y código de unidad, como se dice por radio
                Positioned(
                  key: const ValueKey('top'),
                  left: 0,
                  right: 0,
                  top: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SecuriaSpace.sm + 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Detrás de la alerta entrante no deben asomar
                          Offstage(
                            offstage: incoming != null,
                            child: Row(
                              children: [
                                _SirenChip(
                                  active: state.isSirenActive,
                                  onTap:
                                      () => context.read<PatrolBloc>().add(
                                        const PatrolToggleSiren(),
                                      ),
                                ),
                                const SizedBox(width: SecuriaSpace.xs),
                                _MapChip(
                                  child: Text(
                                    unit.unitCode,
                                    style: PatrolTypography.mono(size: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusToast(message: _toast),
                        ],
                      ),
                    ),
                  ),
                ),

                // Recentrar y ficha de intervención
                Positioned(
                  key: const ValueKey('bottom'),
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          SecuriaSpace.md,
                          SecuriaSpace.sm,
                        ),
                        child: Column(
                          children: [
                            if (displayed != null) ...[
                              _MapButton(
                                icon: Icons.location_searching_rounded,
                                label: DispatchStrings.centerOnTarget,
                                onTap:
                                    () => _map.moveTo(
                                      displayed.location,
                                      zoom: 16,
                                    ),
                              ),
                              const SizedBox(height: SecuriaSpace.xs),
                            ],
                            _MapButton(
                              icon: Icons.my_location_rounded,
                              label: DispatchStrings.centerOnMe,
                              onTap: () => _map.moveTo(unit.location),
                            ),
                          ],
                        ),
                      ),
                      if (displayed != null)
                        TacticalHudSheet(
                          incident: displayed,
                          patrolId: unit.id,
                          distanceMeters: state.distanceToTargetMeters,
                          etaMinutes: state.etaMinutes,
                          onAction:
                              (step) => _runStep(context, step, displayed),
                          onCallCitizen: () => _callCitizen(context, displayed),
                          // Un despacho propio en curso no se cierra desde aquí
                          onClose:
                              state.activeDispatchedIncident != null
                                  ? null
                                  : () => context.read<PatrolBloc>().add(
                                    const PatrolClearActiveDispatch(),
                                  ),
                        ),
                    ],
                  ),
                ),

                // Alerta entrante a pantalla completa (por encima de todo)
                if (incoming != null)
                  Positioned.fill(
                    key: const ValueKey('incoming'),
                    child: _incomingOverlay(context, state, incoming),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _incomingOverlay(
    BuildContext context,
    PatrolState state,
    IncidentModel incoming,
  ) {
    final km = GeoUtils.calculateDistanceKm(
      state.currentPatrol.location,
      incoming.location,
    );
    return IncomingAlertOverlay(
      key: ValueKey(incoming.id),
      incident: incoming,
      distanceMeters: km * 1000.0,
      etaMinutes: GeoUtils.estimateEtaMinutes(
        km,
        averageSpeedKmh: GeoUtils.patrolResponseSpeedKmh,
      ),
      queuedCount: (state.pendingCount - 1).clamp(0, 99),
      onAccept:
          () => context.read<PatrolBloc>().add(PatrolAcceptDispatch(incoming)),
      onIgnore:
          () => context.read<PatrolBloc>().add(
            PatrolDismissProximityAlert(incoming.id),
          ),
    );
  }
}

/// Pastilla flotante sobre el mapa
class _MapChip extends StatelessWidget {
  final Widget child;

  const _MapChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: SecuriaSpace.sm),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PatrolColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(SecuriaRadius.pill),
        border: Border.all(color: PatrolColors.border),
      ),
      child: child,
    );
  }
}

/// Sirena: pastilla que se toca para encenderla o apagarla.
/// El área táctil llega a 64 px de alto aunque la pastilla mida 40.
class _SirenChip extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _SirenChip({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: active,
      label: active ? DispatchStrings.sirenOn : DispatchStrings.sirenOff,
      hint: DispatchStrings.sirenHint,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: SecuriaTouch.patrol,
          child: Center(
            child: _MapChip(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          active
                              ? PatrolColors.critical
                              : PatrolColors.inkMuted,
                      boxShadow:
                          active
                              ? [
                                BoxShadow(
                                  color: PatrolColors.critical.withValues(
                                    alpha: 0.3,
                                  ),
                                  spreadRadius: 3,
                                ),
                              ]
                              : null,
                    ),
                  ),
                  const SizedBox(width: SecuriaSpace.xs - 1),
                  Text(
                    active ? DispatchStrings.sirenOn : DispatchStrings.sirenOff,
                    style: PatrolTypography.caption.copyWith(
                      color: active ? PatrolColors.ink : PatrolColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón redondo de 64 px para recentrar el mapa
class _MapButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MapButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: PatrolColors.surface,
        shape: const CircleBorder(side: BorderSide(color: PatrolColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: SecuriaTouch.patrol,
            height: SecuriaTouch.patrol,
            child: Icon(icon, color: PatrolColors.ink),
          ),
        ),
      ),
    );
  }
}
