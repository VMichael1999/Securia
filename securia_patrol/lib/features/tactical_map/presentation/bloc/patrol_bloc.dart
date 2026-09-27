import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import 'patrol_event.dart';
import 'patrol_state.dart';

/// Ruta, distancia y tiempo de llegada desde la patrulla hasta un objetivo
class _RouteInfo {
  final List<LatLng> polyline;
  final double distanceMeters;
  final int etaMinutes;

  const _RouteInfo(this.polyline, this.distanceMeters, this.etaMinutes);

  factory _RouteInfo.between(GeoLocation from, GeoLocation to) {
    final distKm = GeoUtils.calculateDistanceKm(from, to);
    return _RouteInfo(
      GeoUtils.generateUrbanPolyline(
        from,
        to,
      ).map((g) => g.toLatLng()).toList(),
      distKm * 1000.0,
      GeoUtils.estimateEtaMinutes(
        distKm,
        averageSpeedKmh: GeoUtils.patrolResponseSpeedKmh,
      ),
    );
  }
}

class PatrolBloc extends Bloc<PatrolEvent, PatrolState> {
  final ISecuriaRepository _repository;
  StreamSubscription<List<IncidentModel>>? _incidentsSubscription;

  PatrolBloc({
    required ISecuriaRepository repository,
    required PatrolUnitModel initialPatrol,
  }) : _repository = repository,
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
    on<PatrolClearActiveDispatch>(_onClearActiveDispatch);
  }

  /// Copia vigente de un incidente en el repositorio (evita trabajar con snapshots viejos)
  IncidentModel? _latest(String incidentId) {
    for (final inc in _repository.getSnapshotIncidents()) {
      if (inc.id == incidentId) return inc;
    }
    return null;
  }

  /// Estado con la ruta hacia [target], o sin ruta si no hay objetivo
  PatrolState _withRouteTo(
    PatrolState base,
    IncidentModel? target, {
    GeoLocation? from,
  }) {
    if (target == null) {
      return base.copyWith(
        routePolyline: const [],
        clearDistance: true,
        clearEta: true,
      );
    }
    final route = _RouteInfo.between(
      from ?? base.currentPatrol.location,
      target.location,
    );
    return base.copyWith(
      routePolyline: route.polyline,
      distanceToTargetMeters: route.distanceMeters,
      etaMinutes: route.etaMinutes,
    );
  }

  void _onStarted(PatrolStarted event, Emitter<PatrolState> emit) {
    emit(state.copyWith(currentPatrol: event.unit, isLoading: true));

    _incidentsSubscription?.cancel();
    _incidentsSubscription = _repository.watchAllIncidents().listen((
      incidents,
    ) {
      add(PatrolIncidentsReceived(incidents));
    });
  }

  void _onIncidentsReceived(
    PatrolIncidentsReceived event,
    Emitter<PatrolState> emit,
  ) {
    final incidents = event.incidents;
    IncidentModel? findById(String? id) {
      if (id == null) return null;
      for (final inc in incidents) {
        if (inc.id == id) return inc;
      }
      return null;
    }

    // Un despacho cerrado desde fuera (p. ej. el ciudadano canceló) se libera
    var dispatched = findById(state.activeDispatchedIncident?.id);
    final closedStatus = dispatched?.status;
    final dispatchClosedExternally = closedStatus?.isClosed ?? false;
    if (dispatchClosedExternally) dispatched = null;

    final selected = findById(state.selectedIncident?.id);

    final target = dispatched ?? selected;
    final next = _withRouteTo(state, target).copyWith(
      isLoading: false,
      allIncidents: incidents,
      activeDispatchedIncident: dispatched,
      clearActiveDispatched: dispatched == null,
      selectedIncident: dispatchClosedExternally ? null : selected,
      clearSelectedIncident: dispatchClosedExternally || selected == null,
      isSirenActive: dispatchClosedExternally ? false : null,
    );

    final alert = _proximityAlertFor(next, incidents);
    emit(
      next.copyWith(
        proximityAlertIncident: alert,
        clearProximityAlert: alert == null,
        statusMessage:
            closedStatus == IncidentStatus.cancelado
                ? DispatchStrings.citizenCancelled
                : null,
      ),
    );
  }

  /// Incidente pendiente más urgente dentro del radar, si la unidad está libre
  IncidentModel? _proximityAlertFor(
    PatrolState s,
    List<IncidentModel> incidents,
  ) {
    final isFree =
        s.activeDispatchedIncident == null &&
        s.currentPatrol.status != PatrolStatus.fueraServicio;
    if (!isFree) return null;

    final candidates = incidents.where(
      (inc) =>
          inc.status == IncidentStatus.reportado &&
          !s.dismissedAlertIds.contains(inc.id) &&
          GeoUtils.isWithinRadius(
            s.currentPatrol.location,
            inc.location,
            s.radarRadiusKm,
          ),
    );
    if (candidates.isEmpty) return null;

    return candidates.reduce(
      (a, b) => b.urgency.index < a.urgency.index ? b : a,
    );
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
    emit(_withRouteTo(state.copyWith(currentPatrol: updatedPatrol), target));
  }

  void _onSelectIncident(
    PatrolSelectIncident event,
    Emitter<PatrolState> emit,
  ) {
    final incident = event.incident;
    emit(
      _withRouteTo(state, incident).copyWith(
        selectedIncident: incident,
        clearSelectedIncident: incident == null,
      ),
    );
  }

  Future<void> _onAcceptDispatch(
    PatrolAcceptDispatch event,
    Emitter<PatrolState> emit,
  ) async {
    final unit = state.currentPatrol;
    try {
      await _repository.updateIncidentStatus(
        event.incident.id,
        IncidentStatus.asignado,
        patrolId: unit.id,
        patrolCode: unit.unitCode,
        officerName: unit.officerName,
        patrolLocation: unit.location,
      );
    } on StateError catch (e) {
      emit(
        state.copyWith(
          clearProximityAlert: true,
          statusMessage: DispatchStrings.alreadyTaken(e.message),
        ),
      );
      return;
    }

    final accepted = _latest(event.incident.id) ?? event.incident;
    emit(
      _withRouteTo(state, accepted).copyWith(
        activeDispatchedIncident: accepted,
        selectedIncident: accepted,
        clearProximityAlert: true,
        statusMessage: DispatchStrings.accepted(unit.unitCode),
      ),
    );
  }

  Future<void> _onEnCamino(
    PatrolEnCamino event,
    Emitter<PatrolState> emit,
  ) async {
    final unit = state.currentPatrol;
    await _repository.updateIncidentStatus(
      event.incident.id,
      IncidentStatus.enCamino,
      patrolId: unit.id,
      patrolCode: unit.unitCode,
      officerName: unit.officerName,
      patrolLocation: unit.location,
    );

    emit(
      state.copyWith(
        isSirenActive: true,
        activeDispatchedIncident: _latest(event.incident.id),
        statusMessage: DispatchStrings.onTheWay(unit.unitCode),
      ),
    );
  }

  Future<void> _onEnLugar(
    PatrolEnLugar event,
    Emitter<PatrolState> emit,
  ) async {
    final unit = state.currentPatrol;
    await _repository.updateIncidentStatus(
      event.incident.id,
      IncidentStatus.enLugar,
      patrolId: unit.id,
      patrolCode: unit.unitCode,
      officerName: unit.officerName,
      patrolLocation: unit.location,
    );

    emit(
      state.copyWith(
        // En el lugar la sirena ya no ayuda: se apaga sola
        isSirenActive: false,
        activeDispatchedIncident: _latest(event.incident.id),
        statusMessage: DispatchStrings.arrived,
      ),
    );
  }

  Future<void> _onResolveIncident(
    PatrolResolveIncident event,
    Emitter<PatrolState> emit,
  ) async {
    final unit = state.currentPatrol;
    await _repository.updateIncidentStatus(
      event.incident.id,
      IncidentStatus.resuelto,
      patrolId: unit.id,
      patrolCode: unit.unitCode,
      officerName: unit.officerName,
      resolutionNote: event.resolutionNote,
    );

    emit(
      _withRouteTo(state, null).copyWith(
        clearActiveDispatched: true,
        clearSelectedIncident: true,
        isSirenActive: false,
        statusMessage: DispatchStrings.concluded,
      ),
    );
  }

  void _onToggleSiren(PatrolToggleSiren event, Emitter<PatrolState> emit) {
    emit(state.copyWith(isSirenActive: !state.isSirenActive));
  }

  void _onDismissProximityAlert(
    PatrolDismissProximityAlert event,
    Emitter<PatrolState> emit,
  ) {
    final updatedDismissed = Set<String>.from(state.dismissedAlertIds)
      ..add(event.incidentId);

    // Si hay otra alerta pendiente en el radar, se muestra a continuación
    final withDismissed = state.copyWith(dismissedAlertIds: updatedDismissed);
    final nextAlert = _proximityAlertFor(withDismissed, state.allIncidents);
    emit(
      withDismissed.copyWith(
        proximityAlertIncident: nextAlert,
        clearProximityAlert: nextAlert == null,
      ),
    );
  }

  Future<void> _onChangeDutyStatus(
    PatrolChangeDutyStatus event,
    Emitter<PatrolState> emit,
  ) async {
    await _repository.setPatrolStatus(state.currentPatrol.id, event.status);
    final updatedPatrol = state.currentPatrol.copyWith(status: event.status);
    final updated = state.copyWith(currentPatrol: updatedPatrol);
    final alert = _proximityAlertFor(updated, state.allIncidents);
    emit(
      updated.copyWith(
        proximityAlertIncident: alert,
        clearProximityAlert: alert == null,
      ),
    );
  }

  /// Cierra la ficha en pantalla. Un despacho propio en curso no se suelta:
  /// sigue asignado a la unidad y solo se oculta la selección.
  void _onClearActiveDispatch(
    PatrolClearActiveDispatch event,
    Emitter<PatrolState> emit,
  ) {
    final hasOngoingDispatch = state.activeDispatchedIncident != null;
    emit(
      _withRouteTo(
        state,
        hasOngoingDispatch ? state.activeDispatchedIncident : null,
      ).copyWith(clearSelectedIncident: true, clearProximityAlert: true),
    );
  }

  @override
  Future<void> close() {
    _incidentsSubscription?.cancel();
    return super.close();
  }
}
