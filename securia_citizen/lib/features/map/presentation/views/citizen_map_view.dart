import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/injection.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_map_style.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/utils/phone_launcher.dart';
import '../../../history/presentation/views/incident_detail_view.dart';
import '../../data/location_service.dart';
import '../bloc/citizen_bloc.dart';
import '../bloc/citizen_event.dart';
import '../bloc/citizen_state.dart';
import '../widgets/add_details_sheet.dart';
import '../widgets/alert_status_tracker.dart';
import '../widgets/incident_quick_preview_sheet.dart';
import '../widgets/incident_report_sheet.dart';
import '../widgets/incident_type_grid_sheet.dart';
import '../widgets/location_banner.dart';
import '../widgets/sos_action_panel.dart';

/// Mapa principal del ciudadano.
///
/// El SOS es lo único rojo de la pantalla y siempre está en el mismo lugar,
/// al alcance del pulgar. Arriba se ve dónde estás y con qué precisión.
class CitizenMapView extends StatefulWidget {
  const CitizenMapView({super.key});

  @override
  State<CitizenMapView> createState() => _CitizenMapViewState();
}

class _CitizenMapViewState extends State<CitizenMapView> {
  final _mapController = SecuriaMapController();
  final Map<IncidentType, BitmapDescriptor> _icons = {};
  BitmapDescriptor? _ownAlertIcon;
  BitmapDescriptor? _userIcon;
  double _holdProgress = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userIcon == null) _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final user = await MapMarkerIcons.circle(
      icon: Icons.person_rounded,
      fill: AppColors.ink,
      ring: AppColors.surface,
      size: 30,
      devicePixelRatio: ratio,
    );
    final own = await MapMarkerIcons.circle(
      icon: Icons.sos_rounded,
      fill: AppColors.sos,
      ring: AppColors.surface,
      size: 44,
      devicePixelRatio: ratio,
    );
    final byType = <IncidentType, BitmapDescriptor>{};
    for (final type in IncidentType.values) {
      byType[type] = await MapMarkerIcons.circle(
        icon: type.icon,
        fill: AppColors.incident,
        ring: AppColors.surface,
        size: 36,
        devicePixelRatio: ratio,
      );
    }
    if (!mounted) return;
    setState(() {
      _userIcon = user;
      _ownAlertIcon = own;
      _icons.addAll(byType);
    });
  }

  void _showSnack(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color ?? AppColors.ink,
          content: Text(message),
        ),
      );
  }

  String _locationCaption(CitizenState state) {
    final meters = state.locationAccuracyMeters;
    return state.hasLocationFix && meters != null
        ? SosStrings.reportSendsFrom(SosStrings.accuracy(meters.round()))
        : SosStrings.reportSendsWithoutFix;
  }

  Future<void> _openReport(BuildContext context, CitizenState state) async {
    final bloc = context.read<CitizenBloc>();
    final report = await IncidentReportSheet.show(
      context,
      locationCaption: _locationCaption(state),
    );
    if (report == null) return;

    bloc.add(
      CitizenIncidentReportRequested(
        type: report.type,
        location: bloc.state.userLocation,
        description: report.description,
        photoPath: report.photoPath,
      ),
    );
    if (context.mounted) {
      _showSnack(context, SosStrings.alertSentSnack, color: AppColors.help);
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
          backgroundColor: AppColors.helpSoft,
          child: Icon(Icons.check_rounded, color: AppColors.help, size: 28),
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
      builder: (ctx) => AlertDialog(
        title: const Text(SosStrings.cancelTitle),
        content: const Text(SosStrings.cancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.inkSecondary),
            child: const Text(SosStrings.cancelConfirm),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.onColor,
            ),
            child: const Text(SosStrings.cancelKeep),
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

  List<SecuriaMapMarker> _markers(BuildContext context, CitizenState state) {
    final activeSos = state.activeSosIncident;
    return [
      SecuriaMapMarker(
        id: 'me',
        position: state.userLocation,
        icon: _userIcon,
        semanticLabel: SosStrings.yourLocation,
        zIndex: 2,
      ),
      for (final incident in state.filteredIncidents)
        if (!incident.status.isClosed)
          SecuriaMapMarker(
            id: incident.id,
            position: incident.location,
            icon: incident.id == activeSos?.id
                ? _ownAlertIcon
                : _icons[incident.type],
            semanticLabel: SosStrings.incidentMarker(
              incident.type.title,
              DateFormat('HH:mm').format(incident.timestamp),
            ),
            zIndex: incident.id == activeSos?.id ? 3 : 1,
            onTap: () => context
                .read<CitizenBloc>()
                .add(CitizenSelectIncidentForPreview(incident)),
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CitizenBloc, CitizenState>(
          listenWhen: (prev, curr) =>
              curr.errorMessage != null && curr.errorMessage != prev.errorMessage,
          listener: (context, state) =>
              _showSnack(context, state.errorMessage!, color: AppColors.ink),
        ),
        BlocListener<CitizenBloc, CitizenState>(
          listenWhen: _isFreshImmediateSos,
          listener: (context, state) {
            SemanticsService.announce(
              SosStrings.sosSentAnnouncement,
              Directionality.of(context),
            );
            _askSosFollowUp(context, state.activeSosIncident!);
          },
        ),
        // El mapa sigue al usuario cuando llega la primera lectura del GPS
        BlocListener<CitizenBloc, CitizenState>(
          listenWhen: (prev, curr) => !prev.hasLocationFix && curr.hasLocationFix,
          listener: (context, state) => _mapController.moveTo(state.userLocation),
        ),
      ],
      child: BlocBuilder<CitizenBloc, CitizenState>(
        builder: (context, state) {
          final activeSos = state.activeSosIncident;
          final meters = state.locationAccuracyMeters;
          final dim = _holdProgress;

          return PopScope(
            // Con alerta activa, el gesto atrás no debe cerrar la app por accidente
            canPop: activeSos == null,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _showSnack(context, SosStrings.backBlocked);
            },
            child: Scaffold(
              body: Stack(
                children: [
                  // Cada capa lleva clave: la capa oscura aparece y desaparece
                  // durante el gesto del SOS y no debe desplazar a las demás
                  // 1. Mapa
                  Positioned.fill(
                    key: const ValueKey('map'),
                    child: SecuriaMap(
                      center: state.userLocation,
                      controller: _mapController,
                      style: AppMapStyle.calm,
                      markers: _markers(context, state),
                      circles: [
                        if (state.hasLocationFix && meters != null)
                          SecuriaMapCircle(
                            id: 'accuracy',
                            center: state.userLocation,
                            radiusMeters: meters,
                            fill: AppColors.ink.withValues(alpha: 0.08),
                            stroke: AppColors.ink.withValues(alpha: 0.25),
                          ),
                      ],
                      onTap: () => context
                          .read<CitizenBloc>()
                          .add(const CitizenSelectIncidentForPreview(null)),
                    ),
                  ),

                  // 2. Dónde estás y con qué precisión (o vista previa de un incidente)
                  Positioned(
                    key: const ValueKey('top'),
                    left: SecuriaSpace.md,
                    right: SecuriaSpace.md,
                    top: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: SecuriaSpace.xs),
                        child: state.selectedPreviewIncident != null
                            ? IncidentQuickPreviewSheet(
                                incident: state.selectedPreviewIncident!,
                                onClose: () => context.read<CitizenBloc>().add(
                                      const CitizenSelectIncidentForPreview(null),
                                    ),
                                onViewFullDetail: () {
                                  final inc = state.selectedPreviewIncident!;
                                  context.read<CitizenBloc>().add(
                                        const CitizenSelectIncidentForPreview(null),
                                      );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          IncidentDetailView(incident: inc),
                                    ),
                                  );
                                },
                              )
                            : LocationBanner(
                                status: state.locationStatus,
                                address: state.userLocation.address,
                                accuracyMeters: meters,
                                takenAt: state.locationTakenAt,
                                nearbyReports: state.nearbyRecentCount,
                                onFixLocation: () =>
                                    getIt<LocationService>().openSettings(),
                              ),
                      ),
                    ),
                  ),

                  // 3. Mientras se mantiene el SOS, todo lo demás se apaga
                  if (dim > 0)
                    Positioned.fill(
                      key: const ValueKey('scrim'),
                      child: IgnorePointer(
                        child: ColoredBox(
                          color: AppColors.scrim.withValues(
                            alpha: AppColors.scrim.a * dim,
                          ),
                          child: SafeArea(
                            child: Align(
                              alignment: const Alignment(0, -0.35),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SecuriaSpace.xxl,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      SosStrings.sosKeepHolding,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.headline.copyWith(
                                        color: AppColors.onColor,
                                      ),
                                    ),
                                    const SizedBox(height: SecuriaSpace.xs),
                                    Text(
                                      SosStrings.sosSendsIn(
                                        ((1 - dim) *
                                                SecuriaMotion.sosHold
                                                    .inMilliseconds /
                                                1000)
                                            .toStringAsFixed(1),
                                      ),
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyLarge.copyWith(
                                        color: AppColors.onColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 4. Zona del pulgar: SOS o seguimiento de la alerta activa
                  Positioned(
                    key: const ValueKey('thumb-zone'),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Se oculta sin salir del árbol: si cambiara la
                          // estructura, el SOS se reconstruiría a mitad del
                          // gesto y la alerta nunca se enviaría
                          IgnorePointer(
                            ignoring: dim > 0,
                            child: Opacity(
                              opacity: dim > 0 ? 0 : 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: SecuriaSpace.md,
                                  bottom: SecuriaSpace.sm,
                                ),
                                child: FloatingActionButton.small(
                                  heroTag: 'recenter_gps',
                                  tooltip: SosStrings.recenter,
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.ink,
                                  elevation: 3,
                                  onPressed: () =>
                                      _mapController.moveTo(state.userLocation),
                                  child: const Icon(Icons.my_location_rounded),
                                ),
                              ),
                            ),
                          ),
                          if (activeSos != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                SecuriaSpace.sm,
                                0,
                                SecuriaSpace.sm,
                                SecuriaSpace.sm,
                              ),
                              child: AlertStatusTracker(
                                incident: activeSos,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        IncidentDetailView(incident: activeSos),
                                  ),
                                ),
                                onCall: () => _call105(context),
                                onAddDetails: () =>
                                    _addDetails(context, activeSos),
                                onCancel: () =>
                                    _confirmCancel(context, activeSos),
                              ),
                            )
                          else
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: SecuriaSpace.md,
                                ),
                                child: SosActionPanel(
                                  isSending: state.isReportingSos,
                                  locationReliable: state.locationStatus ==
                                          LocationStatus.precise ||
                                      state.locationStatus ==
                                          LocationStatus.locating,
                                  onHoldProgress: (p) =>
                                      setState(() => _holdProgress = p),
                                  onSosTriggered: () {
                                    setState(() => _holdProgress = 0);
                                    context.read<CitizenBloc>().add(
                                          CitizenImmediateSosRequested(
                                            state.userLocation,
                                          ),
                                        );
                                  },
                                  onReport: () => _openReport(context, state),
                                  onCall: () => _call105(context),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
