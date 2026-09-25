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
import '../widgets/proximity_radar_banner.dart';
import '../widgets/tactical_hud_sheet.dart';

/// Vista de Mapa Táctico en Tiempo Real para Unidades de Patrullaje PNP / Serenazgo
class TacticalMapView extends StatefulWidget {
  const TacticalMapView({super.key});

  @override
  State<TacticalMapView> createState() => _TacticalMapViewState();
}

class _TacticalMapViewState extends State<TacticalMapView> {
  final MapController _mapController = MapController();

  void _centerOnPatrol(LatLng patrolPos) {
    _mapController.move(patrolPos, 15.0);
  }

  void _centerOnTarget(LatLng targetPos) {
    _mapController.move(targetPos, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      body: BlocConsumer<PatrolBloc, PatrolState>(
        listener: (context, state) {
          if (state.statusMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.statusMessage!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: PatrolColors.tacticalNavy,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final patrolLatLng = state.currentPatrol.location.toLatLng();
          final displayedIncident =
              state.activeDispatchedIncident ?? state.selectedIncident;

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
                  // Capa base de Tiles OpenStreetMap con filtro oscuro táctico
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'pe.securia.patrol',
                    tileBuilder: (context, tileWidget, tile) {
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.25, 0, 0, 0, 0,
                          0, 0.28, 0, 0, 0,
                          0, 0, 0.35, 0, 0,
                          0, 0, 0, 1.0, 0,
                        ]),
                        child: tileWidget,
                      );
                    },
                  ),

                  // Perímetro de Radar de Cobertura de la Patrulla (3.5 km)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: patrolLatLng,
                        radius: state.radarRadiusKm * 1000,
                        useRadiusInMeter: true,
                        color: PatrolColors.cyanAccent.withValues(alpha: 0.06),
                        borderColor: PatrolColors.cyanAccent.withValues(alpha: 0.4),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),

                  // Polilínea dinámica de intercepción táctica (Patrulla -> Incidente)
                  if (state.routePolyline.isNotEmpty) ...[
                    // Halo brillante de ruta
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.routePolyline,
                          color: PatrolColors.cyanAccent.withValues(alpha: 0.25),
                          strokeWidth: 8.0,
                        ),
                      ],
                    ),
                    // Línea principal de ruta
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.routePolyline,
                          color: state.isSirenActive
                              ? PatrolColors.alertCrimson
                              : PatrolColors.cyanAccent,
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
                        height: 60,
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
                              context
                                  .read<PatrolBloc>()
                                  .add(PatrolSelectIncident(incident));
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      // Tarjeta de Identificación de Patrulla
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: PatrolColors.surfaceCard.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PatrolColors.surfaceBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 10,
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
                                  style: PatrolTypography.tacticalCode.copyWith(fontSize: 12),
                                ),
                                Text(
                                  state.currentPatrol.officerName,
                                  style: PatrolTypography.bodySmall.copyWith(fontSize: 10),
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
                          context.read<PatrolBloc>().add(const PatrolToggleSiren());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: state.isSirenActive
                                ? PatrolColors.policeSirenGradient
                                : null,
                            color: state.isSirenActive ? null : PatrolColors.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.isSirenActive
                                  ? Colors.white
                                  : PatrolColors.surfaceBorder,
                            ),
                            boxShadow: state.isSirenActive
                                ? [
                                    BoxShadow(
                                      color: PatrolColors.alertCrimson.withValues(alpha: 0.6),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                state.isSirenActive
                                    ? Icons.emergency_rounded
                                    : Icons.notifications_active_outlined,
                                color: state.isSirenActive ? Colors.white : PatrolColors.cyanAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.isSirenActive ? 'SIRENA ACTIVA' : 'CÓDIGO SIRENA',
                                style: TextStyle(
                                  color: state.isSirenActive ? Colors.white : PatrolColors.textPrimary,
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

              // 3. Banner flotante de detección de proximidad táctica
              if (state.proximityAlertIncident != null &&
                  state.activeDispatchedIncident == null)
                Positioned(
                  top: 75,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: ProximityRadarBanner(
                      incident: state.proximityAlertIncident!,
                      distanceMeters: GeoUtils.calculateDistanceKm(
                        state.currentPatrol.location,
                        state.proximityAlertIncident!.location,
                      ) * 1000.0,
                      onAccept: () {
                        context.read<PatrolBloc>().add(
                              PatrolAcceptDispatch(state.proximityAlertIncident!),
                            );
                      },
                      onDismiss: () {
                        context.read<PatrolBloc>().add(
                              PatrolDismissProximityAlert(
                                state.proximityAlertIncident!.id,
                              ),
                            );
                      },
                    ),
                  ),
                ),

              // 4. Botones flotantes de recentrado
              Positioned(
                right: 16,
                bottom: displayedIncident != null ? 280 : 24,
                child: Column(
                  children: [
                    if (displayedIncident != null) ...[
                      FloatingActionButton.small(
                        heroTag: 'target_center',
                        backgroundColor: PatrolColors.alertCrimson,
                        foregroundColor: Colors.white,
                        onPressed: () =>
                            _centerOnTarget(displayedIncident.location.toLatLng()),
                        child: const Icon(Icons.gps_fixed_rounded),
                      ),
                      const SizedBox(height: 10),
                    ],
                    FloatingActionButton.small(
                      heroTag: 'patrol_center',
                      backgroundColor: PatrolColors.surfaceCard,
                      foregroundColor: PatrolColors.cyanAccent,
                      onPressed: () => _centerOnPatrol(patrolLatLng),
                      child: const Icon(Icons.local_police_rounded),
                    ),
                  ],
                ),
              ),

              // 5. HUD Inferior de Intervención si hay incidente seleccionado o asignado
              if (displayedIncident != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: TacticalHudSheet(
                    incident: displayedIncident,
                    distanceMeters: state.distanceToTargetMeters,
                    etaMinutes: state.etaMinutes,
                    isAssignedToMe:
                        displayedIncident.assignedPatrolId == state.currentPatrol.id,
                    onAcceptDispatch: () {
                      context
                          .read<PatrolBloc>()
                          .add(PatrolAcceptDispatch(displayedIncident));
                    },
                    onEnCamino: () {
                      context
                          .read<PatrolBloc>()
                          .add(PatrolEnCamino(displayedIncident));
                    },
                    onEnLugar: () {
                      context
                          .read<PatrolBloc>()
                          .add(PatrolEnLugar(displayedIncident));
                    },
                    onResolve: (note) {
                      context.read<PatrolBloc>().add(
                            PatrolResolveIncident(
                              incident: displayedIncident,
                              resolutionNote: note,
                            ),
                          );
                    },
                    onClose: () {
                      context
                          .read<PatrolBloc>()
                          .add(const PatrolSelectIncident(null));
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
