import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../data/location_service.dart';
import 'citizen_event.dart';
import 'citizen_state.dart';

class CitizenBloc extends Bloc<CitizenEvent, CitizenState> {
  final ISecuriaRepository _repository;
  final LocationService? _locationService;
  StreamSubscription<List<IncidentModel>>? _incidentsSubscription;
  StreamSubscription<LocationReading>? _locationSubscription;

  CitizenBloc({
    required ISecuriaRepository repository,
    required CitizenProfileModel citizen,
    LocationService? locationService,
  }) : _repository = repository,
       _locationService = locationService,
       super(CitizenState(citizenProfile: citizen)) {
    on<CitizenStarted>(_onStarted);
    on<CitizenLocationChanged>(_onLocationChanged);
    on<CitizenIncidentsUpdated>(_onIncidentsUpdated);
    on<CitizenFilterChanged>(_onFilterChanged);
    on<CitizenImmediateSosRequested>(_onImmediateSosRequested);
    on<CitizenIncidentReportRequested>(_onIncidentReportRequested);
    on<CitizenSosDetailsUpdated>(_onSosDetailsUpdated);
    on<CitizenCancelActiveSos>(_onCancelActiveSos);
    on<CitizenSelectIncidentForPreview>(_onSelectIncidentForPreview);
  }

  void _onStarted(CitizenStarted event, Emitter<CitizenState> emit) {
    emit(state.copyWith(isLoading: true));

    _incidentsSubscription?.cancel();
    _incidentsSubscription = _repository.watchAllIncidents().listen((
      incidents,
    ) {
      add(CitizenIncidentsUpdated(incidents));
    });

    _locationSubscription?.cancel();
    _locationSubscription = _locationService?.watch().listen(
      (reading) => add(CitizenLocationChanged(reading)),
    );
  }

  void _onLocationChanged(
    CitizenLocationChanged event,
    Emitter<CitizenState> emit,
  ) {
    final reading = event.reading;
    emit(
      state.copyWith(
        locationStatus: reading.status,
        userLocation: reading.location,
        locationAccuracyMeters: reading.accuracyMeters,
        locationTakenAt: reading.takenAt,
      ),
    );
  }

  void _onIncidentsUpdated(
    CitizenIncidentsUpdated event,
    Emitter<CitizenState> emit,
  ) {
    // Buscar si el usuario actual tiene una alerta SOS activa en curso
    final myActiveSos = event.incidents.cast<IncidentModel?>().firstWhere(
      (inc) =>
          inc?.citizenId == state.citizenProfile.id &&
          inc?.status != IncidentStatus.resuelto &&
          inc?.status != IncidentStatus.cancelado,
      orElse: () => null,
    );

    // Actualizar preview si estaba seleccionado
    IncidentModel? updatedPreview;
    if (state.selectedPreviewIncident != null) {
      updatedPreview = event.incidents.cast<IncidentModel?>().firstWhere(
        (i) => i?.id == state.selectedPreviewIncident!.id,
        orElse: () => null,
      );
    }

    emit(
      state.copyWith(
        isLoading: false,
        allIncidents: event.incidents,
        activeSosIncident: myActiveSos,
        clearActiveSos: myActiveSos == null,
        selectedPreviewIncident: updatedPreview,
        clearPreviewIncident: updatedPreview == null,
      ),
    );
  }

  void _onFilterChanged(
    CitizenFilterChanged event,
    Emitter<CitizenState> emit,
  ) {
    emit(
      state.copyWith(
        filterTodayOnly: event.filterTodayOnly ?? state.filterTodayOnly,
        selectedCategory: event.selectedCategory,
        clearCategory: event.clearCategory,
      ),
    );
  }

  Future<void> _onImmediateSosRequested(
    CitizenImmediateSosRequested event,
    Emitter<CitizenState> emit,
  ) => _emitAlert(
    emit,
    type: IncidentType.emergenciaGeneral,
    description: 'Alerta SOS inmediata emitida por el ciudadano.',
    location: event.location,
  );

  Future<void> _onIncidentReportRequested(
    CitizenIncidentReportRequested event,
    Emitter<CitizenState> emit,
  ) => _emitAlert(
    emit,
    type: event.type,
    description:
        event.description ?? '${event.type.title} reportado por el ciudadano.',
    photoPath: event.photoPath,
    location: event.location,
  );

  Future<void> _emitAlert(
    Emitter<CitizenState> emit, {
    required IncidentType type,
    required String description,
    required GeoLocation location,
    String? photoPath,
  }) async {
    if (state.isReportingSos) return;
    emit(state.copyWith(isReportingSos: true));
    try {
      final incident = await _repository.createIncident(
        type: type,
        title: '${type.title} en progreso',
        description: description,
        location: location,
        photoPath: photoPath,
        urgency: type.defaultUrgency,
        citizenId: state.citizenProfile.id,
      );

      emit(state.copyWith(isReportingSos: false, activeSosIncident: incident));
    } catch (e) {
      emit(
        state.copyWith(
          isReportingSos: false,
          errorMessage: 'Error al emitir alerta SOS: $e',
        ),
      );
    }
  }

  Future<void> _onSosDetailsUpdated(
    CitizenSosDetailsUpdated event,
    Emitter<CitizenState> emit,
  ) async {
    try {
      await _repository.updateIncidentDetails(
        event.incidentId,
        type: event.type,
        urgency: event.type?.defaultUrgency,
        description: event.description,
        photoPath: event.photoPath,
      );
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'No se pudieron enviar los detalles: $e'),
      );
    }
  }

  Future<void> _onCancelActiveSos(
    CitizenCancelActiveSos event,
    Emitter<CitizenState> emit,
  ) async {
    try {
      await _repository.updateIncidentStatus(
        event.incidentId,
        IncidentStatus.cancelado,
        resolutionNote: 'Alerta cancelada por el usuario',
      );
      emit(state.copyWith(clearActiveSos: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'No se pudo cancelar la alerta: $e'));
    }
  }

  void _onSelectIncidentForPreview(
    CitizenSelectIncidentForPreview event,
    Emitter<CitizenState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPreviewIncident: event.incident,
        clearPreviewIncident: event.incident == null,
      ),
    );
  }

  @override
  Future<void> close() {
    _incidentsSubscription?.cancel();
    _locationSubscription?.cancel();
    return super.close();
  }
}
