import '../models/enums.dart';
import '../models/geo_location.dart';
import '../models/incident_model.dart';
import '../models/patrol_unit_model.dart';
import '../models/citizen_profile_model.dart';
import '../models/citizen_auth.dart';

/// Contrato principal de persistencia y comunicación reactiva para Securia
abstract class ISecuriaRepository {
  /// Flujo reactivo en tiempo real de todos los incidentes activos
  Stream<List<IncidentModel>> watchAllIncidents();

  /// Flujo reactivo filtrado por los incidentes reportados por un ciudadano específico
  Stream<List<IncidentModel>> watchIncidentsByCitizen(String citizenId);

  /// Flujo reactivo de incidentes ubicados dentro del radio de cobertura de una patrulla
  Stream<List<IncidentModel>> watchIncidentsNear(
    GeoLocation center,
    double radiusKm,
  );

  /// Flujo reactivo para observar cambios de estado en un incidente específico
  Stream<IncidentModel?> watchIncidentById(String incidentId);

  /// Flujo reactivo de las unidades policiales activas en patrullaje
  Stream<List<PatrolUnitModel>> watchPatrolUnits();

  /// Flujo reactivo de una unidad policial específica
  Stream<PatrolUnitModel?> watchPatrolUnitById(String patrolId);

  /// Crea y transmite un nuevo incidente SOS reportado por un ciudadano
  Future<IncidentModel> createIncident({
    required IncidentType type,
    required String title,
    required String description,
    required GeoLocation location,
    String? photoBase64,
    String? photoPath,
    required UrgencyLevel urgency,
    String? citizenId,
  });

  /// Completa los datos de un incidente ya emitido (tipo, detalle, evidencia).
  ///
  /// Permite enviar la alerta primero y precisarla después, sin retrasar el SOS.
  Future<void> updateIncidentDetails(
    String incidentId, {
    IncidentType? type,
    String? description,
    String? photoBase64,
    String? photoPath,
    UrgencyLevel? urgency,
  });

  /// Actualiza el estado de un incidente (despacho, en camino, en el lugar, resuelto)
  ///
  /// Lanza [StateError] si se intenta asignar un incidente que ya atiende otra patrulla.
  Future<void> updateIncidentStatus(
    String incidentId,
    IncidentStatus newStatus, {
    String? patrolId,
    String? patrolCode,
    String? officerName,
    GeoLocation? patrolLocation,
    String? resolutionNote,
  });

  /// Actualiza la posición geográfica en vivo de una patrulla policial
  Future<void> updatePatrolLocation(String patrolId, GeoLocation newLocation);

  /// Actualiza el estado de servicio de la patrulla
  Future<void> setPatrolStatus(String patrolId, PatrolStatus status);

  /// Perfil del ciudadano con sesión iniciada, o `null` si no hay sesión
  CitizenProfileModel? getCurrentCitizen();

  /// Inicia sesión con DNI y celular.
  ///
  /// Lanza [CitizenAuthException] si el DNI no está registrado o el celular
  /// no coincide.
  Future<CitizenProfileModel> signInCitizen({
    required String dni,
    required String phone,
  });

  /// Registra un nuevo ciudadano y deja su sesión iniciada.
  ///
  /// Requiere el consentimiento de tratamiento de datos ([dataConsentAt]);
  /// el de datos de salud es aparte y opcional.
  /// Lanza [CitizenAuthException] si el DNI ya tiene cuenta.
  Future<CitizenProfileModel> registerCitizen({
    required String fullName,
    required String dni,
    required String phone,
    required DateTime dataConsentAt,
    DateTime? healthDataConsentAt,
    String emergencyContactName,
    String emergencyContactPhone,
  });

  /// Cierra la sesión del ciudadano actual
  Future<void> signOutCitizen();

  /// Obtiene los datos de la patrulla policial activa
  PatrolUnitModel getCurrentPatrol();

  /// Obtiene la lista actual de incidentes en memoria
  List<IncidentModel> getSnapshotIncidents();

  /// Obtiene la lista actual de patrullas
  List<PatrolUnitModel> getSnapshotPatrols();
}
