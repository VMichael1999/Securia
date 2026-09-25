import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../bloc/citizen_bloc.dart';
import '../bloc/citizen_event.dart';
import '../bloc/citizen_state.dart';
import '../widgets/active_alert_banner.dart';
import '../widgets/incident_marker_widget.dart';
import '../widgets/incident_quick_preview_sheet.dart';
import '../widgets/sos_button.dart';
import '../widgets/sos_report_dialog.dart';
import '../../../history/presentation/views/incident_detail_view.dart';

/// Pantalla Principal con Mapa Interactivo OpenStreetMap y Botón SOS
class CitizenMapView extends StatefulWidget {
  const CitizenMapView({super.key});

  @override
  State<CitizenMapView> createState() => _CitizenMapViewState();
}

class _CitizenMapViewState extends State<CitizenMapView> {
  final MapController _mapController = MapController();

  void _recenterMap(LatLng target) {
    _mapController.move(target, 15.0);
  }

  void _openSosDialog(BuildContext context, CitizenState state) {
    SosReportDialog.show(
      context: context,
      currentLocation: state.userLocation,
      onReportSubmitted: ({
        required IncidentType type,
        required String description,
        String? photoPath,
        required UrgencyLevel urgency,
        required GeoLocation location,
      }) {
        context.read<CitizenBloc>().add(
              CitizenReportSosRequested(
                type: type,
                description: description,
                photoPath: photoPath,
                urgency: urgency,
                location: location,
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.emergencyRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Alerta SOS emitida! Patrullas policiales notificadas en tiempo real.',
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CitizenBloc, CitizenState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.emergencyRed,
              content: Text(state.errorMessage!),
            ),
          );
        }
      },
      builder: (context, state) {
        final incidents = state.filteredIncidents;
        final userLatLng = state.userLocation.toLatLng();

        return Scaffold(
          body: Stack(
            children: [
              // 1. Mapa Interactivo OpenStreetMap
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userLatLng,
                  initialZoom: 15.0,
                  maxZoom: 18.5,
                  minZoom: 11.0,
                  onTap: (_, __) {
                    context.read<CitizenBloc>().add(
                          const CitizenSelectIncidentForPreview(null),
                        );
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.securia.citizen',
                  ),

                  // Marcador de ubicación del usuario
                  MarkerLayer(
                    markers: [
                      // Círculo de pulso del usuario
                      Marker(
                        point: userLatLng,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Marcadores de incidentes reportados
                      ...incidents.map((incident) {
                        return Marker(
                          point: incident.location.toLatLng(),
                          width: 48,
                          height: 48,
                          child: IncidentMarkerWidget(
                            incident: incident,
                            onTap: () {
                              context.read<CitizenBloc>().add(
                                    CitizenSelectIncidentForPreview(incident),
                                  );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // 2. Barra Superior: Filtro "Hoy" vs "Todos" y Categorías
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Banner de Alerta Activa si existe
                      if (state.activeSosIncident != null)
                        ActiveAlertBanner(
                          incident: state.activeSosIncident!,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => IncidentDetailView(
                                  incident: state.activeSosIncident!,
                                ),
                              ),
                            );
                          },
                          onCancel: () {
                            context.read<CitizenBloc>().add(
                                  CitizenCancelActiveSos(state.activeSosIncident!.id),
                                );
                          },
                        ),

                      const SizedBox(height: 6),

                      // Tarjeta de Filtros
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Filtro de temporalidad: Hoy vs Todos
                              FilterChip(
                                label: Text(
                                  state.filterTodayOnly ? '📅 Solo Hoy' : '🗓️ Todos los días',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: state.filterTodayOnly ? Colors.white : AppColors.primaryNavy,
                                  ),
                                ),
                                selected: state.filterTodayOnly,
                                selectedColor: AppColors.primaryNavy,
                                backgroundColor: AppColors.surfaceMuted,
                                checkmarkColor: Colors.white,
                                onSelected: (val) {
                                  context.read<CitizenBloc>().add(
                                        CitizenFilterChanged(filterTodayOnly: val),
                                      );
                                },
                              ),

                              const SizedBox(width: 8),

                              // Filtro: Categoría Todas
                              FilterChip(
                                label: Text(
                                  'Todas (${incidents.length})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: state.selectedCategory == null ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                selected: state.selectedCategory == null,
                                selectedColor: AppColors.accentBlue,
                                backgroundColor: AppColors.surfaceMuted,
                                onSelected: (_) {
                                  context.read<CitizenBloc>().add(
                                        const CitizenFilterChanged(clearCategory: true),
                                      );
                                },
                              ),

                              const SizedBox(width: 8),

                              // Categorías individuales
                              ...[
                                IncidentType.asalto,
                                IncidentType.robo,
                                IncidentType.emergenciaMedica,
                                IncidentType.accidenteTransito,
                                IncidentType.sospechoso,
                              ].map((type) {
                                final isSelected = state.selectedCategory == type;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    avatar: Icon(type.icon, size: 14, color: isSelected ? Colors.white : type.color),
                                    label: Text(
                                      type.title.split(' ').first,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: type.color,
                                    backgroundColor: AppColors.surfaceMuted,
                                    onSelected: (_) {
                                      context.read<CitizenBloc>().add(
                                            CitizenFilterChanged(
                                              selectedCategory: isSelected ? null : type,
                                              clearCategory: isSelected,
                                            ),
                                          );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Botón de recentrar ubicación
              Positioned(
                right: 18,
                bottom: 120,
                child: FloatingActionButton.small(
                  heroTag: 'recenter_gps',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryNavy,
                  elevation: 4,
                  onPressed: () => _recenterMap(userLatLng),
                  child: const Icon(Icons.my_location_rounded, size: 20),
                ),
              ),

              // 4. Hoja de vista previa rápida al tocar un marcador
              if (state.selectedPreviewIncident != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 100,
                  child: IncidentQuickPreviewSheet(
                    incident: state.selectedPreviewIncident!,
                    onClose: () {
                      context.read<CitizenBloc>().add(
                            const CitizenSelectIncidentForPreview(null),
                          );
                    },
                    onViewFullDetail: () {
                      final inc = state.selectedPreviewIncident!;
                      context.read<CitizenBloc>().add(
                            const CitizenSelectIncidentForPreview(null),
                          );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => IncidentDetailView(incident: inc),
                        ),
                      );
                    },
                  ),
                ),

              // 5. Botón Flotante Central SOS PÁNICO
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: SosButton(
                    isSending: state.isReportingSos,
                    onTap: () => _openSosDialog(context, state),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
