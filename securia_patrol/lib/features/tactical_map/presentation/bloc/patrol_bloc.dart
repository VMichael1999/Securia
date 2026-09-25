import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:securia_core/securia_core.dart';
import 'patrol_event.dart';
import 'patrol_state.dart';

class PatrolBloc extends Bloc<PatrolEvent, PatrolState> {
  final ISecuriaRepository _repository;
  StreamSubscription<List<IncidentModel>>? _incidentsSubscription;

  PatrolBloc({
    required ISecuriaRepository repository,
    required PatrolUnitModel initialPatrol,
  })  : _repository = repository,
        super(PatrolState(currentPatrol: initialPatrol)) {
    on<PatrolStarted>(_onStarted);
    on<PatrolIncidentsReceived>(_onIncidentsReceived);
    on<PatrolLocationUpdated>(_onLocationUpdated);
    on<PatrolSelectIncident>(_onSelectIncident);
    on<PatrolAcceptDispatch>(_onAcceptDispatch);
    on<PatrolEnCamino>(_onEnCamino);
    on<PatrolEnLugar>(_onEnLugar);
    on<PatrolResolveIncident>(_onResolveIncident);
    on<PatrolToggleSiren>(_onToggleSiren);
    on<PatrolDismissProximityAlert>(_onDismissProximityAlert);
    on<PatrolChangeDutyStatus>(_onChangeDutyStatus);
  }

  void _onStarted(PatrolStarted event, Emitter<PatrolState> emit) {
    emit(state.copyWith(currentPatrol: event.unit, isLoading: true));

    _incidentsSubscription?.cancel();
    _incidentsSubscription = _repository.watchAllIncidents().listen((incidents) {
      add(PatrolIncidentsReceived(incidents));
    });
  }

  void _onIncidentsReceived(
    PatrolIncidentsReceived event,
    Emitter<PatrolState> emit,
  ) {
    final incidents = event.incidents;

    // Detectar si hay una alerta crítica o cercana para desplegar radar HUD
    IncidentModel? proximityAlert;
    for (final inc in incidents) {
      if (inc.status == IncidentStatus.reportado &&
          !state.dismissedAlertIds.contains(inc.id)) {
        if (GeoUtils.isWithinRadius(
          state.currentPatrol.location,
          inc.location,
          state.radarRadiusKm,
        )) {
          proximityAlert = inc;
          break;
        }
      }
    }

    // Actualizar referencia de incidente despachado si existe
    IncidentModel? updatedDispatched = state.activeDispatchedIncident;
    if (updatedDispatched != null) {
      try {
        updatedDispatched = incidents.firstWhere(
          (i) => i.id == updatedDispatched!.id,
        );
      } catch (_) {
        updatedDispatched = null;
      }
    }

    // Actualizar referencia de incidente seleccionado
    IncidentModel? updatedSelected = state.selectedIncident;
    if (updatedSelected != null) {
      try {
        updatedSelected = incidents.firstWhere(
          (i) => i.id == updatedSelected!.id,
        );
      } catch (_) {
        updatedSelected = null;
      }
    }

    // Calcular ruta hacia el objetivo
    final target = updatedDispatched ?? updatedSelected;
    List<LatLng> polyline = state.routePolyline;
    double? distMeters;
    int? eta;

    if (target != null) {
      polyline = GeoUtils.generateUrbanPolyline(
        state.currentPatrol.location,
        target.location,
      ).map((g) => g.toLatLng()).toList();

      final distKm = GeoUtils.calculateDistanceKm(
        state.currentPatrol.location,
        target.location,
      );
      distMeters = distKm * 1000.0;
      eta = GeoUtils.estimateEtaMinutes(distKm, averageSpeedKmh: 45);
    }

    emit(state.copyWith(
      isLoading: false,
      allIncidents: incidents,
      proximityAlertIncident: proximityAlert,
      activeDispatchedIncident: updatedDispatched,
      selectedIncident: updatedSelected,
      routePolyline: polyline,
      distanceToTargetMeters: distMeters,
      etaMinutes: eta,
    ));
  }

  void _onLocationUpdated(
    PatrolLocationUpdated event,
    Emitter<PatrolState> emit,
  ) {
    final updatedPatrol = state.currentPatrol.copyWith(
      location: event.newLocation,
    );

    _repository.updatePatrolLocation(updatedPatrol.id, event.newLocation);

    final target = state.activeDispatchedIncident ?? state.selectedIncident;
    List<LatLng> polyline = state.routePolyline;
    double? distMeters;
    int? eta;

    if (target != null) {
      polyline = GeoUtils.generateUrbanPolyline(
        event.newLocation,
        target.location,
      ).map((g) => g.toLatLng()).toList();

      final distKm = GeoUtils.calculateDistanceKm(
        event.newLocation,
        target.location,
      );
      distMeters = distKm * 1000.0;
      eta = GeoUtils.estimateEtaMinutes(distKm, averageSpeedKmh: 45);
    }

    emit(state.copyWith(
      currentPatrol: updatedPatrol,
      routePolyline: polyline,
      distanceToTargetMeters: distMeters,
      etaMinutes: eta,
    ));
  }

  void _onSelectIncident(
    PatrolSelectIncident event,
    Emitter<PatrolState> emit,
  ) {
    final incident = event.incident;
    if (incident == null) {
      emit(state.copyWith(
        clearSelectedIncident: true,
        routePolyline: const [],
        clearDistance: true,
        clearEta: true,
      ));
      return;
    }

    final polyline = GeoUtils.generateUrbanPolyline(
      state.currentPatrol.location,
      incident.location,
    ).map((g) => g.toLatLng()).toList();

    final distKm = GeoUtils.calculateDistanceKm(
      state.currentPatrol.location,
      incident.location,
    );
    final distMeters = distKm * 1000.0;

    emit(state.copyWith(
      selectedIncident: incident,
      routePolyline: polyline,
      distanceToTargetMeters: distMeters,
      etaMinutes: GeoUtils.estimateEtaMinutes(distKm, averageSpeedKmh: 45),
    ));
  }

  Future<void> _onAcceptDispatch(
    PatrolAcceptDispatch event,
    Emitter<PatrolState> emit,
  ) async {
    await _repository.updateIncidentStatus(
      event.incident.id,
      IncidentStatus.asignado,
      patrolId: state.currentPatrol.id,
      patrolCode: state.currentPatrol.unitCode,
      officerName: state.currentPatrol.officerName,
      patrolLocation: state.currentPatrol.location,
    );

    final polyline = GeoUtils.generateUrbanPolyline(
      state.currentPatrol.location,
      event.incident.location,
    ).map((g) => g.toLatLng()).toList();

    final distKm = GeoUtils.calculateDistanceKm(
      state.currentPatrol.location,
      event.incident.location,
    );
    final distMeters = distKm * 1000.0;

    emit(state.copyWith(
      activeDispatchedIncident: event.incident.copyWith(
        status: IncidentStatus.asignado,
        assignedPatrolId: state.currentPatrol.id,
        assignedPatrolCode: state.currentPatrol.unitCode,
      ),
      selectedIncident: event.incident,
      routePolyline: polyline,
      distanceToTargetMeters: distMeters,
      etaMinutes: GeoUtils.estimateEtaMinutes(distKm, averageSpeedKmh: 45),
      statusMessage: 'Despacho aceptado para la unidad ${state.currentPatrol.unitCode}',
    ));
  }

  Future<void> _onEnCamino(
    PatrolEnCamino event,
    Emitter<PatrolState> emit,
  ) async {
    await _repository.updateIncidentStatus(
      event.incident.id,
      IncidentStatus.enCamino,
      patrolId: state.currentPatrol.id,
      patrolCode: state.currentPatrol.unitCode,
      officerName: state.currentPatrol.officerName,
      patrolLocation: state.currentPatrol.location,
    );

    emit(state.copyWith(
      isSirenActive: true,
      activeDispatchedIncident: event.incident.copyWith(
        status: IncidentStatus.enCamino,
      ),
      statusMessage: 'Unidad ${state.currentPatrol.unitCode} en código rojo hacia el lugar.',
    ));
  }

  Future<void> _onEnLugar(
    PatrolEnLugar event,
    Emitter<PatrolState> emit,
  ) async {
    await _repository.updateIncidentStatus(
      event.incident.id,
      IncidentStatus.enLugar,
      patrolId: state.currentPatrol.id,
      patrolCode: state.currentPatrol.unitCode,
      officerName: state.currentPatrol.officerName,
      patrolLocation: state.currentPatrol.location,
    );

    emit(state.copyWith(
      activeDispatchedIncident: event.incident.copyWith(
        status: IncidentStatus.enLugar,
      ),
      statusMessage: 'Unidad en el lugar interviniendo la zona de la emergencia.',
    ));
  }

  Future<void> _onResolveIncident(
    PatrolResolveIncident event,
    Emitter<PatrolState> emit,
  ) async {
    await _repository.updateIncidentStatus(
      event.incident.id,
      IncidentStatus.resuelto,
      patrolId: state.currentPatrol.id,
      patrolCode: state.currentPatrol.unitCode,
      officerName: state.currentPatrol.officerName,
      resolutionNote: event.resolutionNote,
    );

    emit(state.copyWith(
      clearActiveDispatched: true,
      clearSelectedIncident: true,
      routePolyline: const [],
      clearDistance: true,
      clearEta: true,
      isSirenActive: false,
      statusMessage: 'Incidente concluido con reporte policial.',
    ));
  }

  void _onToggleSiren(
    PatrolToggleSiren event,
    Emitter<PatrolState> emit,
  ) {
    emit(state.copyWith(isSirenActive: !state.isSirenActive));
  }

  void _onDismissProximityAlert(
    PatrolDismissProximityAlert event,
    Emitter<PatrolState> emit,
  ) {
    final updatedDismissed = Set<String>.from(state.dismissedAlertIds)
      ..add(event.incidentId);

    emit(state.copyWith(
      clearProximityAlert: true,
      dismissedAlertIds: updatedDismissed,
    ));
  }

  Future<void> _onChangeDutyStatus(
    PatrolChangeDutyStatus event,
    Emitter<PatrolState> emit,
  ) async {
    await _repository.setPatrolStatus(state.currentPatrol.id, event.status);
    final updatedPatrol = state.currentPatrol.copyWith(status: event.status);
    emit(state.copyWith(currentPatrol: updatedPatrol));
  }

  @override
  Future<void> close() {
    _incidentsSubscription?.cancel();
    return super.close();
  }
}
