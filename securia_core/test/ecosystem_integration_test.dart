import 'package:flutter_test/flutter_test.dart';
import 'package:securia_core/securia_core.dart';

void main() {
  late InMemorySecuriaRepository repository;

  setUp(() {
    repository = InMemorySecuriaRepository();
  });

  test(
    'Ecosistema Securia: Ciclo de vida completo desde SOS ciudadano hasta resolución policial',
    () async {
      // 1. El ciudadano inicia sesión con su DNI y celular
      final citizen = await repository.signInCitizen(
        dni: '74829104',
        phone: '984512893',
      );
      expect(citizen.fullName, contains('Michael Anthony'));

      // 2. Ciudadano emite alerta SOS en tiempo real
      final incident = await repository.createIncident(
        type: IncidentType.asalto,
        title: 'Asalto a mano armada',
        description:
            'Dos sujetos en moto lineal negra intentando asaltar transeúntes.',
        location: const GeoLocation(
          latitude: -12.0864,
          longitude: -77.0345,
          address: 'Av. Javier Prado Este con Av. San Luis, San Borja',
        ),
        photoPath: 'test_evidence_photo.jpg',
        urgency: UrgencyLevel.critica,
        citizenId: citizen.id,
      );

      expect(incident.status, IncidentStatus.reportado);
      expect(incident.urgency, UrgencyLevel.critica);
      expect(incident.isToday, isTrue);

      // 3. Verificar que la patrulla PL-402 calcula la ruta y la distancia
      const patrolLocation = GeoLocation(
        latitude: -12.0835,
        longitude: -77.0378,
        address: 'Av. Guardia Civil con Av. Javier Prado, San Borja',
      );

      final distanceKm = GeoUtils.calculateDistanceKm(
        patrolLocation,
        incident.location,
      );
      expect(distanceKm, lessThan(3.5)); // Dentro del radar táctico de 3.5 km

      final polyline = GeoUtils.generateUrbanPolyline(
        patrolLocation,
        incident.location,
      );
      expect(
        polyline.length,
        greaterThanOrEqualTo(2),
      ); // Trazo urbano con puntos intermedios

      final etaMinutes = GeoUtils.estimateEtaMinutes(
        distanceKm,
        averageSpeedKmh: 45,
      );
      expect(etaMinutes, greaterThan(0));

      // 4. Patrulla acepta despacho
      await repository.updateIncidentStatus(
        incident.id,
        IncidentStatus.asignado,
        patrolId: 'patrol_01',
        patrolCode: 'PL-402',
        officerName: 'Suboficial R. Mendoza',
        patrolLocation: patrolLocation,
      );

      var updated = repository.getSnapshotIncidents().firstWhere(
        (i) => i.id == incident.id,
      );
      expect(updated.status, IncidentStatus.asignado);
      expect(updated.assignedPatrolCode, 'PL-402');

      // 5. Patrulla en camino (Código Rojo / Sirena)
      await repository.updateIncidentStatus(
        incident.id,
        IncidentStatus.enCamino,
        patrolId: 'patrol_01',
        patrolCode: 'PL-402',
        officerName: 'Suboficial R. Mendoza',
      );

      updated = repository.getSnapshotIncidents().firstWhere(
        (i) => i.id == incident.id,
      );
      expect(updated.status, IncidentStatus.enCamino);
      expect(updated.hasActivePatrol, isTrue);

      // 6. Patrulla en el lugar
      await repository.updateIncidentStatus(
        incident.id,
        IncidentStatus.enLugar,
        patrolId: 'patrol_01',
        patrolCode: 'PL-402',
      );

      updated = repository.getSnapshotIncidents().firstWhere(
        (i) => i.id == incident.id,
      );
      expect(updated.status, IncidentStatus.enLugar);

      // 7. Intervención concluida y resuelta con acta policial
      await repository.updateIncidentStatus(
        incident.id,
        IncidentStatus.resuelto,
        patrolId: 'patrol_01',
        patrolCode: 'PL-402',
        resolutionNote:
            'Sospechosos intervenidos con arma incautada y trasladados a Comisaría San Borja.',
      );

      updated = repository.getSnapshotIncidents().firstWhere(
        (i) => i.id == incident.id,
      );
      expect(updated.status, IncidentStatus.resuelto);
      expect(updated.notes.last, contains('Comisaría San Borja'));
    },
  );
}
