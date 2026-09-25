import 'package:latlong2/latlong.dart';
import 'package:securia_core/securia_core.dart';

class PatrolState {
  final bool isLoading;
  final PatrolUnitModel currentPatrol;
  final List<IncidentModel> allIncidents;
  final IncidentModel? selectedIncident;
  final IncidentModel? activeDispatchedIncident;
  final IncidentModel? proximityAlertIncident;
  final Set<String> dismissedAlertIds;
  final bool isSirenActive;
  final double radarRadiusKm;
  final List<LatLng> routePolyline;
  final double? distanceToTargetMeters;
  final int? etaMinutes;
  final String? statusMessage;

  const PatrolState({
    this.isLoading = false,
    required this.currentPatrol,
    this.allIncidents = const [],
    this.selectedIncident,
    this.activeDispatchedIncident,
    this.proximityAlertIncident,
    this.dismissedAlertIds = const {},
    this.isSirenActive = false,
    this.radarRadiusKm = 3.5,
    this.routePolyline = const [],
    this.distanceToTargetMeters,
    this.etaMinutes,
    this.statusMessage,
  });

  /// Incidentes activos que requieren atención o están siendo atendidos
  List<IncidentModel> get activeIncidents {
    return allIncidents
        .where((inc) =>
            inc.status != IncidentStatus.resuelto &&
            inc.status != IncidentStatus.cancelado)
        .toList();
  }

  /// Incidentes asignados o despachados a esta unidad policial
  List<IncidentModel> get myAssignedIncidents {
    return allIncidents
        .where((inc) => inc.assignedPatrolId == currentPatrol.id)
        .toList();
  }

  /// Incidentes concluidos / resueltos durante el turno
  List<IncidentModel> get resolvedIncidents {
    return allIncidents
        .where((inc) =>
            inc.assignedPatrolId == currentPatrol.id &&
            inc.status == IncidentStatus.resuelto)
        .toList();
  }

  /// Cantidad de incidentes de urgencia crítica reportados hoy
  int get criticalIncidentsCount {
    return activeIncidents
        .where((inc) => inc.urgency == UrgencyLevel.critica)
        .length;
  }

  PatrolState copyWith({
    bool? isLoading,
    PatrolUnitModel? currentPatrol,
    List<IncidentModel>? allIncidents,
    IncidentModel? selectedIncident,
    bool clearSelectedIncident = false,
    IncidentModel? activeDispatchedIncident,
    bool clearActiveDispatched = false,
    IncidentModel? proximityAlertIncident,
    bool clearProximityAlert = false,
    Set<String>? dismissedAlertIds,
    bool? isSirenActive,
    double? radarRadiusKm,
    List<LatLng>? routePolyline,
    double? distanceToTargetMeters,
    bool clearDistance = false,
    int? etaMinutes,
    bool clearEta = false,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return PatrolState(
      isLoading: isLoading ?? this.isLoading,
      currentPatrol: currentPatrol ?? this.currentPatrol,
      allIncidents: allIncidents ?? this.allIncidents,
      selectedIncident: clearSelectedIncident
          ? null
          : (selectedIncident ?? this.selectedIncident),
      activeDispatchedIncident: clearActiveDispatched
          ? null
          : (activeDispatchedIncident ?? this.activeDispatchedIncident),
      proximityAlertIncident: clearProximityAlert
          ? null
          : (proximityAlertIncident ?? this.proximityAlertIncident),
      dismissedAlertIds: dismissedAlertIds ?? this.dismissedAlertIds,
      isSirenActive: isSirenActive ?? this.isSirenActive,
      radarRadiusKm: radarRadiusKm ?? this.radarRadiusKm,
      routePolyline: routePolyline ?? this.routePolyline,
      distanceToTargetMeters: clearDistance
          ? null
          : (distanceToTargetMeters ?? this.distanceToTargetMeters),
      etaMinutes: clearEta ? null : (etaMinutes ?? this.etaMinutes),
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
    );
  }
}
