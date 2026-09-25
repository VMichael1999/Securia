import 'package:securia_core/securia_core.dart';

class CitizenState {
  final bool isLoading;
  final List<IncidentModel> allIncidents;
  final CitizenProfileModel citizenProfile;
  final GeoLocation userLocation;
  final bool filterTodayOnly;
  final IncidentType? selectedCategory;
  final IncidentModel? activeSosIncident;
  final IncidentModel? selectedPreviewIncident;
  final bool isReportingSos;
  final String? errorMessage;

  const CitizenState({
    this.isLoading = true,
    this.allIncidents = const [],
    required this.citizenProfile,
    this.userLocation = const GeoLocation(
      latitude: -12.0864,
      longitude: -77.0345,
      address: 'San Borja, Lima',
    ),
    this.filterTodayOnly = true,
    this.selectedCategory,
    this.activeSosIncident,
    this.selectedPreviewIncident,
    this.isReportingSos = false,
    this.errorMessage,
  });

  /// Lista de incidentes visibles en el mapa tras aplicar filtros
  List<IncidentModel> get filteredIncidents {
    return allIncidents.where((incident) {
      if (filterTodayOnly && !incident.isToday) {
        return false;
      }
      if (selectedCategory != null && incident.type != selectedCategory) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Lista de todos los incidentes reportados por este ciudadano
  List<IncidentModel> get myReportedIncidents {
    return allIncidents
        .where((incident) => incident.citizenId == citizenProfile.id)
        .toList();
  }

  CitizenState copyWith({
    bool? isLoading,
    List<IncidentModel>? allIncidents,
    CitizenProfileModel? citizenProfile,
    GeoLocation? userLocation,
    bool? filterTodayOnly,
    IncidentType? selectedCategory,
    bool clearCategory = false,
    IncidentModel? activeSosIncident,
    bool clearActiveSos = false,
    IncidentModel? selectedPreviewIncident,
    bool clearPreviewIncident = false,
    bool? isReportingSos,
    String? errorMessage,
  }) {
    return CitizenState(
      isLoading: isLoading ?? this.isLoading,
      allIncidents: allIncidents ?? this.allIncidents,
      citizenProfile: citizenProfile ?? this.citizenProfile,
      userLocation: userLocation ?? this.userLocation,
      filterTodayOnly: filterTodayOnly ?? this.filterTodayOnly,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      activeSosIncident: clearActiveSos
          ? null
          : (activeSosIncident ?? this.activeSosIncident),
      selectedPreviewIncident: clearPreviewIncident
          ? null
          : (selectedPreviewIncident ?? this.selectedPreviewIncident),
      isReportingSos: isReportingSos ?? this.isReportingSos,
      errorMessage: errorMessage,
    );
  }
}
