import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import 'citizen_event.dart';
import 'citizen_state.dart';

class CitizenBloc extends Bloc<CitizenEvent, CitizenState> {
  final ISecuriaRepository _repository;
  StreamSubscription<List<IncidentModel>>? _incidentsSubscription;

  CitizenBloc({required ISecuriaRepository repository})
      : _repository = repository,
        super(
          CitizenState(
            citizenProfile: repository.getCurrentCitizen(),
          ),
        ) {
    on<CitizenStarted>(_onStarted);
    on<CitizenIncidentsUpdated>(_onIncidentsUpdated);
    on<CitizenFilterChanged>(_onFilterChanged);
    on<CitizenReportSosRequested>(_onReportSosRequested);
    on<CitizenCancelActiveSos>(_onCancelActiveSos);
    on<CitizenSelectIncidentForPreview>(_onSelectIncidentForPreview);
  }

  void _onStarted(CitizenStarted event, Emitter<CitizenState> emit) {
    emit(state.copyWith(isLoading: true));

    _incidentsSubscription?.cancel();
    _incidentsSubscription = _repository.watchAllIncidents().listen((incidents) {
      add(CitizenIncidentsUpdated(incidents));
    });
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

    emit(state.copyWith(
      isLoading: false,
      allIncidents: event.incidents,
      activeSosIncident: myActiveSos,
      clearActiveSos: myActiveSos == null,
      selectedPreviewIncident: updatedPreview,
      clearPreviewIncident: updatedPreview == null,
    ));
  }

  void _onFilterChanged(
    CitizenFilterChanged event,
    Emitter<CitizenState> emit,
  ) {
    emit(state.copyWith(
      filterTodayOnly: event.filterTodayOnly ?? state.filterTodayOnly,
      selectedCategory: event.selectedCategory,
      clearCategory: event.clearCategory,
    ));
  }

  Future<void> _onReportSosRequested(
    CitizenReportSosRequested event,
    Emitter<CitizenState> emit,
  ) async {
    emit(state.copyWith(isReportingSos: true));
    try {
      final incident = await _repository.createIncident(
        type: event.type,
        title: '${event.type.title} en progreso',
        description: event.description,
        location: event.location,
        photoBase64: event.photoBase64,
        photoPath: event.photoPath,
        urgency: event.urgency,
        citizenId: state.citizenProfile.id,
      );

      emit(state.copyWith(
        isReportingSos: false,
        activeSosIncident: incident,
      ));
    } catch (e) {
      emit(state.copyWith(
        isReportingSos: false,
        errorMessage: 'Error al emitir alerta SOS: $e',
      ));
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
    emit(state.copyWith(
      selectedPreviewIncident: event.incident,
      clearPreviewIncident: event.incident == null,
    ));
  }

  @override
  Future<void> close() {
    _incidentsSubscription?.cancel();
    return super.close();
  }
}
