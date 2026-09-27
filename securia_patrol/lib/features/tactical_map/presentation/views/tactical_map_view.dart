import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../bloc/patrol_bloc.dart';
import '../bloc/patrol_event.dart';
import '../bloc/patrol_state.dart';
import '../widgets/beacon_marker_widget.dart';
import '../widgets/patrol_marker_widget.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/utils/phone_launcher.dart';
import '../models/dispatch_step.dart';
import '../widgets/incoming_alert_overlay.dart';
import '../widgets/resolution_sheet.dart';
import '../widgets/status_toast.dart';
import '../widgets/tactical_hud_sheet.dart';

/// Vista de Mapa Táctico en Tiempo Real para Unidades de Patrullaje PNP / Serenazgo
class TacticalMapView extends StatefulWidget {
  const TacticalMapView({super.key});

  @override
  State<TacticalMapView> createState() => _TacticalMapViewState();
}

class _TacticalMapViewState extends State<TacticalMapView> {
  final MapController _mapController = MapController();

  /// Invierte los tiles claros de OSM: fondo casi negro azulado, calles y
  /// textos claros y legibles de noche
  static const ColorFilter _nightMapFilter = ColorFilter.matrix([
    -0.85, 0, 0, 0, 230, //
    0, -0.85, 0, 0, 235, //
    0, 0, -0.80, 0, 245, //
    0, 0, 0, 1, 0, //
  ]);
  String? _toast;
  Timer? _toastTimer;

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

  void _centerOnPatrol(LatLng patrolPos) {
    _mapController.move(patrolPos, 15.0);
  }

  void _centerOnTarget(LatLng targetPos) {
    _mapController.move(targetPos, 16.0);
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
        final note = await ResolutionSheet.show(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      body: BlocConsumer<PatrolBloc, PatrolState>(
        listenWhen:
            (prev, curr) =>
                curr.statusMessage != null &&
                curr.statusMessage != prev.statusMessage,
        listener: (context, state) => _showToast(state.statusMessage!),
        builder: (context, state) {
          final patrolLatLng = state.currentPatrol.location.toLatLng();
          final displayedIncident =
              state.activeDispatchedIncident ?? state.selectedIncident;
          final incomingAlert =
              state.activeDispatchedIncident == null
                  ? state.proximityAlertIncident
                  : null;
          final incomingKm =
              incomingAlert == null
                  ? 0.0
                  : GeoUtils.calculateDistanceKm(
                    state.currentPatrol.location,
                    incomingAlert.location,
                  );

          return Stack(
            children: [
              // 1. Mapa Interactivo Táctico con capa oscura
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: patrolLatLng,
                  initialZoom: 14.5,
                  minZoom: 11.0,
                  maxZoom: 18.0,
                ),
                children: [
                  // Capa base OSM (sin API key) invertida a modo noche con tinte azul
                  // oscuro: coherente con la terminal negra y sin deslumbrar
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'pe.securia.patrol',
                    tileBuilder:
                        (context, tileWidget, tile) => ColorFiltered(
                          colorFilter: _nightMapFilter,
                          child: tileWidget,
                        ),
                  ),
                  const SimpleAttributionWidget(
                    source: Text('OpenStreetMap'),
                    backgroundColor: PatrolColors.surfaceCard,
                  ),

                  // Perímetro de Radar de Cobertura de la Patrulla (3.5 km)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: patrolLatLng,
                        radius: state.radarRadiusKm * 1000,
                        useRadiusInMeter: true,
                        color: PatrolColors.policeAccent.withValues(
                          alpha: 0.08,
                        ),
                        borderColor: PatrolColors.policeAccent.withValues(
                          alpha: 0.4,
                        ),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),

                  // Polilínea dinámica de intercepción táctica (Patrulla -> Incidente)
                  if (state.routePolyline.isNotEmpty) ...[
                    // Halo sutil de ruta
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.routePolyline,
                          color: PatrolColors.policeAccent.withValues(
                            alpha: 0.25,
                          ),
                          strokeWidth: 6.0,
                        ),
                      ],
                    ),
                    // Línea principal de ruta
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.routePolyline,
                          color:
                              state.isSirenActive
                                  ? PatrolColors.alertCrimson
                                  : PatrolColors.policeAccent,
                          strokeWidth: 3.8,
                        ),
                      ],
                    ),
                  ],

                  // Marcadores de incidentes y balizas
                  MarkerLayer(
                    markers: [
                      // Marcador de la unidad de patrulla policial
                      Marker(
                        point: patrolLatLng,
                        width: 90,
                        height: 72,
                        alignment: Alignment.center,
                        child: PatrolMarkerWidget(
                          unitCode: state.currentPatrol.unitCode,
                          isSirenActive: state.isSirenActive,
                        ),
                      ),

                      // Balizas de todos los incidentes activos
                      ...state.allIncidents.map((incident) {
                        final isSelected = displayedIncident?.id == incident.id;
                        final isAssignedToMe =
                            incident.assignedPatrolId == state.currentPatrol.id;

                        return Marker(
                          point: incident.location.toLatLng(),
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          child: BeaconMarkerWidget(
                            incident: incident,
                            isSelected: isSelected,
                            isAssignedToMe: isAssignedToMe,
                            onTap: () {
                              context.read<PatrolBloc>().add(
                                PatrolSelectIncident(incident),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // 2. Barra Superior Táctica de Estado y Sirena
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Tarjeta de Identificación de Patrulla
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: PatrolColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: PatrolColors.surfaceBorder),
                          boxShadow: [
                            BoxShadow(
                              color: PatrolColors.background.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: PatrolColors.successGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.currentPatrol.unitCode,
                                  style: PatrolTypography.tacticalCode.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  state.currentPatrol.officerName,
                                  style: PatrolTypography.bodySmall.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Botón Sirena Policial de Respuesta Rápida
                      InkWell(
                        onTap: () {
                          context.read<PatrolBloc>().add(
                            const PatrolToggleSiren(),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient:
                                state.isSirenActive
                                    ? PatrolColors.policeSirenGradient
                                    : null,
                            color:
                                state.isSirenActive
                                    ? null
                                    : PatrolColors.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  state.isSirenActive
                                      ? PatrolColors.textPrimary
                                      : PatrolColors.surfaceBorder,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    state.isSirenActive
                                        ? PatrolColors.alertCrimson.withValues(
                                          alpha: 0.5,
                                        )
                                        : PatrolColors.background.withValues(
                                          alpha: 0.4,
                                        ),
                                blurRadius: state.isSirenActive ? 12 : 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                state.isSirenActive
                                    ? Icons.emergency_rounded
                                    : Icons.notifications_active_outlined,
                                color:
                                    state.isSirenActive
                                        ? PatrolColors.textPrimary
                                        : PatrolColors.alertCrimson,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.isSirenActive
                                    ? 'SIRENA ACTIVA'
                                    : 'CÓDIGO SIRENA',
                                style: TextStyle(
                                  color:
                                      state.isSirenActive
                                          ? PatrolColors.textPrimary
                                          : PatrolColors.alertCrimson,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Avisos de estado bajo la barra superior (no tapan la acción)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: StatusToast(message: _toast),
                  ),
                ),
              ),

              // 3. Zona inferior: recentrar + ficha de intervención
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 12),
                      child: Column(
                        children: [
                          if (displayedIncident != null) ...[
                            FloatingActionButton.small(
                              heroTag: 'target_center',
                              backgroundColor: PatrolColors.alertCrimson,
                              foregroundColor: PatrolColors.textPrimary,
                              onPressed:
                                  () => _centerOnTarget(
                                    displayedIncident.location.toLatLng(),
                                  ),
                              child: const Icon(Icons.gps_fixed_rounded),
                            ),
                            const SizedBox(height: 10),
                          ],
                          FloatingActionButton.small(
                            heroTag: 'patrol_center',
                            backgroundColor: PatrolColors.surfaceCard,
                            foregroundColor: PatrolColors.policeAccent,
                            elevation: 3,
                            onPressed: () => _centerOnPatrol(patrolLatLng),
                            child: const Icon(Icons.local_police_rounded),
                          ),
                        ],
                      ),
                    ),
                    if (displayedIncident != null)
                      TacticalHudSheet(
                        incident: displayedIncident,
                        patrolId: state.currentPatrol.id,
                        distanceMeters: state.distanceToTargetMeters,
                        etaMinutes: state.etaMinutes,
                        onAction:
                            (step) =>
                                _runStep(context, step, displayedIncident),
                        onCallCitizen:
                            () => _callCitizen(context, displayedIncident),
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

              // 4. Alerta entrante a pantalla completa (por encima de todo)
              if (incomingAlert != null)
                Positioned.fill(
                  child: IncomingAlertOverlay(
                    incident: incomingAlert,
                    distanceMeters: incomingKm * 1000.0,
                    etaMinutes: GeoUtils.estimateEtaMinutes(
                      incomingKm,
                      averageSpeedKmh: GeoUtils.patrolResponseSpeedKmh,
                    ),
                    onAccept:
                        () => context.read<PatrolBloc>().add(
                          PatrolAcceptDispatch(incomingAlert),
                        ),
                    onIgnore:
                        () => context.read<PatrolBloc>().add(
                          PatrolDismissProximityAlert(incomingAlert.id),
                        ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
