import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/enums.dart';
import '../models/geo_location.dart';
import '../models/incident_model.dart';
import '../models/patrol_unit_model.dart';
import '../models/citizen_profile_model.dart';
import '../utils/geo_utils.dart';
import 'i_securia_repository.dart';

/// Implementación reactiva en memoria con soporte de Singleton y difusión en vivo
class InMemorySecuriaRepository implements ISecuriaRepository {
  static final InMemorySecuriaRepository _instance =
      InMemorySecuriaRepository._internal();

  factory InMemorySecuriaRepository() => _instance;

  /// Instancia aislada con los datos semilla, para que cada test parta limpio
  @visibleForTesting
  factory InMemorySecuriaRepository.fresh() =>
      InMemorySecuriaRepository._internal();

  final _uuid = const Uuid();

  final _incidentsStreamController =
      StreamController<List<IncidentModel>>.broadcast();
  final _patrolsStreamController =
      StreamController<List<PatrolUnitModel>>.broadcast();

  final List<IncidentModel> _incidents = [];
  final List<PatrolUnitModel> _patrols = [];

  late CitizenProfileModel _currentCitizen;
  late PatrolUnitModel _currentPatrol;

  InMemorySecuriaRepository._internal() {
    _seedInitialData();
  }

  void _seedInitialData() {
    final now = DateTime.now();

    // Perfil del ciudadano activo
    _currentCitizen = const CitizenProfileModel(
      id: 'cit_001',
      fullName: 'Michael Anthony Valdiviezo',
      dni: '74829104',
      phone: '984 512 893',
      email: 'mvaldiviezo@securia.pe',
      emergencyContactName: 'Elena Valdiviezo (Madre)',
      emergencyContactPhone: '951 842 109',
      bloodType: 'O+',
      homeAddress: 'Av. Javier Prado Este 2450, San Borja',
    );

    // Patrullas en servicio activo
    _patrols.addAll([
      const PatrolUnitModel(
        id: 'patrol_01',
        unitCode: 'PL-402',
        officerName: 'Suboficial R. Mendoza',
        phone: '993 102 481',
        location: GeoLocation(
          latitude: -12.0835,
          longitude: -77.0378,
          address: 'Av. Guardia Civil con Av. Javier Prado',
        ),
        coverageRadiusKm: 3.5,
        status: PatrolStatus.disponible,
      ),
      const PatrolUnitModel(
        id: 'patrol_02',
        unitCode: 'MOTO-08',
        officerName: 'Técnico C. Paredes',
        phone: '981 742 590',
        location: GeoLocation(
          latitude: -12.0912,
          longitude: -77.0315,
          address: 'Calle Las Begonias, San Isidro',
        ),
        coverageRadiusKm: 2.5,
        status: PatrolStatus.disponible,
      ),
      const PatrolUnitModel(
        id: 'patrol_03',
        unitCode: 'SERENAZGO-14',
        officerName: 'Agente M. Alarcón',
        phone: '974 610 289',
        location: GeoLocation(
          latitude: -12.0790,
          longitude: -77.0280,
          address: 'Parque de la Reserva, Lima',
        ),
        coverageRadiusKm: 3.0,
        status: PatrolStatus.disponible,
      ),
    ]);

    _currentPatrol = _patrols.first;

    // Incidentes precargados (hoy y días anteriores para demostrar filtrado)
    _incidents.addAll([
      // 1. Incidente reportado hoy en San Borja por otro vecino (pendiente de despacho)
      IncidentModel(
        id: 'inc_today_01',
        type: IncidentType.asalto,
        title: 'Asalto a mano armada en paradero',
        description:
            'Dos sujetos en motocicleta lineal negra intimidaron a transeúntes sustrayendo celulares y mochilas.',
        location: const GeoLocation(
          latitude: -12.0864,
          longitude: -77.0345,
          address: 'Av. Javier Prado Este cuadra 21, San Borja',
          reference: 'Frente a estación La Cultura',
        ),
        citizenId: 'cit_004',
        citizenName: 'Lucía Ramos',
        citizenPhone: '962 330 781',
        timestamp: now.subtract(const Duration(minutes: 18)),
        status: IncidentStatus.reportado,
        urgency: UrgencyLevel.critica,
      ),

      // 2. Incidente reportado hoy en San Isidro (en camino)
      IncidentModel(
        id: 'inc_today_02',
        type: IncidentType.robo,
        title: 'Hurto de autopartes y rotura de luna',
        description:
            'Forzaron la luna lateral de un auto estacionado y sustrajeron la computadora a bordo.',
        location: const GeoLocation(
          latitude: -12.0920,
          longitude: -77.0330,
          address: 'Calle Amador Merino Reyna 340, San Isidro',
        ),
        citizenId: 'cit_002',
        citizenName: 'Carlos Santillán',
        citizenPhone: '977 123 456',
        timestamp: now.subtract(const Duration(minutes: 42)),
        status: IncidentStatus.enCamino,
        urgency: UrgencyLevel.alta,
        assignedPatrolId: 'patrol_02',
        assignedPatrolCode: 'MOTO-08',
        assignedOfficerName: 'Técnico C. Paredes',
        assignedPatrolLocation: const GeoLocation(
          latitude: -12.0912,
          longitude: -77.0315,
          address: 'Calle Las Begonias, San Isidro',
        ),
        routeWaypoints: GeoUtils.generateUrbanPolyline(
          const GeoLocation(latitude: -12.0912, longitude: -77.0315),
          const GeoLocation(latitude: -12.0920, longitude: -77.0330),
        ),
      ),

      // 3. Incidente de ayer (Resuelto)
      IncidentModel(
        id: 'inc_yesterday_01',
        type: IncidentType.sospechoso,
        title: 'Sujetos merodeando viviendas sin placa',
        description:
            'Vehículo polarizado estacionado de forma sospechosa observando casas residenciales.',
        location: const GeoLocation(
          latitude: -12.0810,
          longitude: -77.0395,
          address: 'Calle Morelli cuadra 4, San Borja',
        ),
        citizenId: 'cit_001',
        citizenName: 'Michael Anthony Valdiviezo',
        citizenPhone: '984 512 893',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        status: IncidentStatus.resuelto,
        urgency: UrgencyLevel.media,
        assignedPatrolId: 'patrol_01',
        assignedPatrolCode: 'PL-402',
        assignedOfficerName: 'Suboficial R. Mendoza',
        notes: [
          'Patrulla verificó ocupantes; se realizó control de identidad y se dispersó la zona.'
        ],
      ),

      // 4. Incidente de hace 2 días (Resuelto)
      IncidentModel(
        id: 'inc_past_01',
        type: IncidentType.accidenteTransito,
        title: 'Colisión por alcance entre taxi y particular',
        description:
            'Impacto vehicular menor bloqueando carril derecho. Sin heridos graves.',
        location: const GeoLocation(
          latitude: -12.0785,
          longitude: -77.0350,
          address: 'Av. Canadá con Av. Aviación',
        ),
        citizenId: 'cit_003',
        citizenName: 'Andrea Torres',
        citizenPhone: '966 842 110',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        status: IncidentStatus.resuelto,
        urgency: UrgencyLevel.media,
        assignedPatrolId: 'patrol_03',
        assignedPatrolCode: 'SERENAZGO-14',
        assignedOfficerName: 'Agente M. Alarcón',
        notes: ['Tránsito fluido restablecido en 15 minutos.'],
      ),
    ]);
  }

  void _notifyIncidents() {
    _incidentsStreamController.add(List.unmodifiable(_incidents));
  }

  void _notifyPatrols() {
    _patrolsStreamController.add(List.unmodifiable(_patrols));
  }

  @override
  Stream<List<IncidentModel>> watchAllIncidents() {
    Future.microtask(_notifyIncidents);
    return _incidentsStreamController.stream;
  }

  @override
  Stream<List<IncidentModel>> watchIncidentsByCitizen(String citizenId) {
    Future.microtask(_notifyIncidents);
    return _incidentsStreamController.stream.map(
      (list) => list.where((inc) => inc.citizenId == citizenId).toList(),
    );
  }

  @override
  Stream<List<IncidentModel>> watchIncidentsNear(
    GeoLocation center,
    double radiusKm,
  ) {
    Future.microtask(_notifyIncidents);
    return _incidentsStreamController.stream.map(
      (list) => list
          .where((inc) => GeoUtils.isWithinRadius(center, inc.location, radiusKm))
          .toList(),
    );
  }

  @override
  Stream<IncidentModel?> watchIncidentById(String incidentId) {
    Future.microtask(_notifyIncidents);
    return _incidentsStreamController.stream.map(
      (list) => list.cast<IncidentModel?>().firstWhere(
            (inc) => inc?.id == incidentId,
            orElse: () => null,
          ),
    );
  }

  @override
  Stream<List<PatrolUnitModel>> watchPatrolUnits() {
    Future.microtask(_notifyPatrols);
    return _patrolsStreamController.stream;
  }

  @override
  Stream<PatrolUnitModel?> watchPatrolUnitById(String patrolId) {
    Future.microtask(_notifyPatrols);
    return _patrolsStreamController.stream.map(
      (list) => list.cast<PatrolUnitModel?>().firstWhere(
            (p) => p?.id == patrolId,
            orElse: () => null,
          ),
    );
  }

  @override
  Future<IncidentModel> createIncident({
    required IncidentType type,
    required String title,
    required String description,
    required GeoLocation location,
    String? photoBase64,
    String? photoPath,
    required UrgencyLevel urgency,
    String? citizenId,
  }) async {
    final incident = IncidentModel(
      id: 'inc_${_uuid.v4().substring(0, 8)}',
      type: type,
      title: title,
      description: description,
      location: location,
      photoBase64: photoBase64,
      photoPath: photoPath,
      citizenId: citizenId ?? _currentCitizen.id,
      citizenName: _currentCitizen.fullName,
      citizenPhone: _currentCitizen.phone,
      timestamp: DateTime.now(),
      status: IncidentStatus.reportado,
      urgency: urgency,
    );

    _incidents.insert(0, incident);
    _notifyIncidents();
    return incident;
  }

  @override
  Future<void> updateIncidentDetails(
    String incidentId, {
    IncidentType? type,
    String? description,
    String? photoBase64,
    String? photoPath,
    UrgencyLevel? urgency,
  }) async {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final current = _incidents[index];
    _incidents[index] = current.copyWith(
      type: type,
      title: type != null ? '${type.title} en progreso' : null,
      description: description,
      photoBase64: photoBase64,
      photoPath: photoPath,
      urgency: urgency,
    );
    _notifyIncidents();
  }

  @override
  Future<void> updateIncidentStatus(
    String incidentId,
    IncidentStatus newStatus, {
    String? patrolId,
    String? patrolCode,
    String? officerName,
    GeoLocation? patrolLocation,
    String? resolutionNote,
  }) async {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final current = _incidents[index];

    // Evita que dos unidades tomen el mismo incidente
    if (newStatus == IncidentStatus.asignado &&
        current.status != IncidentStatus.reportado &&
        current.assignedPatrolId != patrolId) {
      throw StateError(
        'El incidente ya es atendido por ${current.assignedPatrolCode ?? 'otra unidad'}',
      );
    }

    final updatedNotes = List<String>.from(current.notes);
    if (resolutionNote != null && resolutionNote.isNotEmpty) {
      updatedNotes.add(resolutionNote);
    }

    // Si la patrulla entra en camino, generamos la polilínea de ruta
    List<GeoLocation> waypoints = current.routeWaypoints;
    if (newStatus == IncidentStatus.enCamino && patrolLocation != null) {
      waypoints = GeoUtils.generateUrbanPolyline(patrolLocation, current.location);
    } else if (newStatus.isClosed) {
      waypoints = [];
    }

    _incidents[index] = current.copyWith(
      status: newStatus,
      assignedPatrolId: patrolId ?? current.assignedPatrolId,
      assignedPatrolCode: patrolCode ?? current.assignedPatrolCode,
      assignedOfficerName: officerName ?? current.assignedOfficerName,
      assignedPatrolLocation: patrolLocation ?? current.assignedPatrolLocation,
      routeWaypoints: waypoints,
      notes: updatedNotes,
    );

    // Actualizar la patrulla involucrada, aunque quien llama no la indique
    // (p. ej. el ciudadano cancela una alerta ya asignada)
    final involvedPatrolId = patrolId ?? current.assignedPatrolId;
    if (involvedPatrolId != null) {
      final pIndex = _patrols.indexWhere((p) => p.id == involvedPatrolId);
      if (pIndex != -1) {
        _patrols[pIndex] = _patrols[pIndex].copyWith(
          status: newStatus.isClosed
              ? PatrolStatus.disponible
              : PatrolStatus.enRespuesta,
          activeIncidentId: newStatus.isClosed ? null : incidentId,
          clearActiveIncident: newStatus.isClosed,
        );
        _notifyPatrols();
      }
    }

    _notifyIncidents();
  }

  @override
  Future<void> updatePatrolLocation(String patrolId, GeoLocation newLocation) async {
    final index = _patrols.indexWhere((p) => p.id == patrolId);
    if (index != -1) {
      _patrols[index] = _patrols[index].copyWith(location: newLocation);
      _notifyPatrols();
    }
  }

  @override
  Future<void> setPatrolStatus(String patrolId, PatrolStatus status) async {
    final index = _patrols.indexWhere((p) => p.id == patrolId);
    if (index != -1) {
      _patrols[index] = _patrols[index].copyWith(status: status);
      _notifyPatrols();
    }
  }

  @override
  CitizenProfileModel getCurrentCitizen() => _currentCitizen;

  @override
  PatrolUnitModel getCurrentPatrol() => _currentPatrol;

  @override
  List<IncidentModel> getSnapshotIncidents() => List.unmodifiable(_incidents);

  @override
  List<PatrolUnitModel> getSnapshotPatrols() => List.unmodifiable(_patrols);
}
