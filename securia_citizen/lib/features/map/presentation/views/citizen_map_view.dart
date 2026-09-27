import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../bloc/citizen_bloc.dart';
import '../bloc/citizen_event.dart';
import '../bloc/citizen_state.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/utils/phone_launcher.dart';
import '../widgets/add_details_sheet.dart';
import '../widgets/alert_status_tracker.dart';
import '../widgets/incident_marker_widget.dart';
import '../widgets/incident_quick_preview_sheet.dart';
import '../widgets/incident_report_sheet.dart';
import '../widgets/incident_type_grid_sheet.dart';
import '../widgets/sos_action_panel.dart';
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

  void _showSnack(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color ?? AppColors.primaryNavy,
          content: Text(message),
        ),
      );
  }

  Future<void> _openReport(BuildContext context, CitizenState state) async {
    final bloc = context.read<CitizenBloc>();
    final report = await IncidentReportSheet.show(context);
    if (report == null) return;

    bloc.add(
      CitizenIncidentReportRequested(
        type: report.type,
        location: state.userLocation,
        description: report.description,
        photoPath: report.photoPath,
      ),
    );
    if (context.mounted) {
      _showSnack(
        context,
        SosStrings.alertSentSnack,
        color: AppColors.primaryGreen,
      );
    }
  }

  /// Tras un SOS inmediato, ofrece precisar qué pasa sin bloquear la alerta
  Future<void> _askSosFollowUp(
    BuildContext context,
    IncidentModel incident,
  ) async {
    final bloc = context.read<CitizenBloc>();
    final type = await IncidentTypeGridSheet.show(
      context,
      title: SosStrings.followUpTitle,
      subtitle: SosStrings.followUpSubtitle,
      types: IncidentType.sosFollowUpTypes,
      skipLabel: SosStrings.followUpSkip,
      leading: const Align(
        alignment: Alignment.centerLeft,
        child: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryGreenLight,
          child: Icon(
            Icons.check_rounded,
            color: AppColors.primaryGreen,
            size: 28,
          ),
        ),
      ),
    );
    if (type == null) return;
    bloc.add(CitizenSosDetailsUpdated(incident.id, type: type));
  }

  Future<void> _addDetails(BuildContext context, IncidentModel incident) async {
    final bloc = context.read<CitizenBloc>();
    final details = await AddDetailsSheet.show(context);
    if (details == null || details.isEmpty) return;

    bloc.add(
      CitizenSosDetailsUpdated(
        incident.id,
        description: details.description,
        photoPath: details.photoPath,
      ),
    );
    if (context.mounted) _showSnack(context, SosStrings.detailsSentSnack);
  }

  Future<void> _confirmCancel(
    BuildContext context,
    IncidentModel incident,
  ) async {
    final bloc = context.read<CitizenBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(SosStrings.cancelTitle),
            content: const Text(SosStrings.cancelBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  SosStrings.cancelKeep,
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  SosStrings.cancelConfirm,
                  style: TextStyle(color: AppColors.emergencyRed),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) bloc.add(CitizenCancelActiveSos(incident.id));
  }

  Future<void> _call105(BuildContext context) async {
    final ok = await PhoneLauncher.call(SosStrings.policeNumber);
    if (!ok && context.mounted) _showSnack(context, SosStrings.callUnavailable);
  }

  /// Un SOS inmediato recién creado (aún sin precisar) abre la pregunta de seguimiento
  static bool _isFreshImmediateSos(
    CitizenState previous,
    CitizenState current,
  ) {
    final sos = current.activeSosIncident;
    return sos != null &&
        sos.id != previous.activeSosIncident?.id &&
        sos.type == IncidentType.emergenciaGeneral &&
        sos.status == IncidentStatus.reportado;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CitizenBloc, CitizenState>(
          listenWhen:
              (prev, curr) =>
                  curr.errorMessage != null &&
                  curr.errorMessage != prev.errorMessage,
          listener:
              (context, state) => _showSnack(
                context,
                state.errorMessage!,
                color: AppColors.emergencyRed,
              ),
        ),
        BlocListener<CitizenBloc, CitizenState>(
          listenWhen: _isFreshImmediateSos,
          listener:
              (context, state) =>
                  _askSosFollowUp(context, state.activeSosIncident!),
        ),
      ],
      child: BlocBuilder<CitizenBloc, CitizenState>(
        builder: (context, state) {
          final incidents = state.filteredIncidents;
          final userLatLng = state.userLocation.toLatLng();
          final activeSos = state.activeSosIncident;

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
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
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

                // 2. Vista previa al tocar un marcador (arriba, no tapa el SOS)
                if (state.selectedPreviewIncident != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: SafeArea(
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
                  ),

                // 3. Zona del pulgar: recentrar + SOS o seguimiento de la alerta activa
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
                        child: FloatingActionButton.small(
                          heroTag: 'recenter_gps',
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primaryNavy,
                          elevation: 4,
                          onPressed: () => _recenterMap(userLatLng),
                          child: const Icon(
                            Icons.my_location_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                      if (activeSos != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: AlertStatusTracker(
                            incident: activeSos,
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => IncidentDetailView(
                                          incident: activeSos,
                                        ),
                                  ),
                                ),
                            onCall: () => _call105(context),
                            onAddDetails: () => _addDetails(context, activeSos),
                            onCancel: () => _confirmCancel(context, activeSos),
                          ),
                        )
                      else
                        SosActionPanel(
                          isSending: state.isReportingSos,
                          onSosTriggered:
                              () => context.read<CitizenBloc>().add(
                                CitizenImmediateSosRequested(
                                  state.userLocation,
                                ),
                              ),
                          onReport: () => _openReport(context, state),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
