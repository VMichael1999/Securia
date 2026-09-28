import 'package:securia_core/securia_core.dart';
import '../../data/location_service.dart';

class CitizenState {
  final bool isLoading;
  final List<IncidentModel> allIncidents;
  final CitizenProfileModel citizenProfile;
  /// Última ubicación conocida; mientras no haya GPS es un punto de referencia
  final GeoLocation userLocation;
  final LocationStatus locationStatus;
  final double? locationAccuracyMeters;
  final DateTime? locationTakenAt;
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
    this.locationStatus = LocationStatus.locating,
    this.locationAccuracyMeters,
    this.locationTakenAt,
    this.filterTodayOnly = true,
    this.selectedCategory,
    this.activeSosIncident,
    this.selectedPreviewIncident,
    this.isReportingSos = false,
    this.errorMessage,
  });

  /// Hay una lectura real del GPS (precisa o no)
  bool get hasLocationFix =>
      locationStatus == LocationStatus.precise ||
      locationStatus == LocationStatus.imprecise;

  /// Incidentes de otros vecinos a menos de 1 km en las últimas 2 horas
  int get nearbyRecentCount {
    final since = DateTime.now().subtract(const Duration(hours: 2));
    return allIncidents
        .where((i) =>
            i.citizenId != citizenProfile.id &&
            i.timestamp.isAfter(since) &&
            GeoUtils.isWithinRadius(userLocation, i.location, 1))
        .length;
  }

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
    LocationStatus? locationStatus,
    double? locationAccuracyMeters,
    DateTime? locationTakenAt,
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
      locationStatus: locationStatus ?? this.locationStatus,
      locationAccuracyMeters:
          locationAccuracyMeters ?? this.locationAccuracyMeters,
      locationTakenAt: locationTakenAt ?? this.locationTakenAt,
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
