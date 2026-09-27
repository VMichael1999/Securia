import 'package:test/test.dart';
import 'package:securia_core/securia_core.dart';

void main() {
  group('SecuriaCore Tests', () {
    test('GeoUtils calculates distance and ETA accurately', () {
      const p1 = GeoLocation(latitude: -12.0864, longitude: -77.0345);
      const p2 = GeoLocation(latitude: -12.0920, longitude: -77.0330);

      final distance = GeoUtils.calculateDistanceKm(p1, p2);
      expect(distance, greaterThan(0.5));
      expect(distance, lessThan(1.5));

      final eta = GeoUtils.estimateEtaMinutes(distance);
      expect(eta, greaterThanOrEqualTo(1));

      final polyline = GeoUtils.generateUrbanPolyline(p1, p2);
      expect(polyline.length, greaterThanOrEqualTo(4));
    });

    test(
      'InMemorySecuriaRepository handles incident creation and status changes',
      () async {
        final repo = InMemorySecuriaRepository();
      await repo.signInCitizen(dni: '74829104', phone: '984512893');
        final initialIncidents = repo.getSnapshotIncidents();
        expect(initialIncidents, isNotEmpty);

        // Create new incident
        const loc = GeoLocation(latitude: -12.0850, longitude: -77.0320);
        final newIncident = await repo.createIncident(
          type: IncidentType.asalto,
          title: 'Prueba de alerta SOS',
          description: 'Detalle de emergencia de prueba',
          location: loc,
          urgency: UrgencyLevel.critica,
        );

        expect(newIncident.status, IncidentStatus.reportado);
        expect(repo.getSnapshotIncidents().first.id, newIncident.id);

        // Patrol responds and changes status to enCamino
        await repo.updateIncidentStatus(
          newIncident.id,
          IncidentStatus.enCamino,
          patrolId: 'patrol_01',
          patrolCode: 'PL-402',
          officerName: 'Suboficial R. Mendoza',
          patrolLocation: const GeoLocation(
            latitude: -12.0835,
            longitude: -77.0378,
          ),
        );

        final updated = repo.getSnapshotIncidents().firstWhere(
          (i) => i.id == newIncident.id,
        );
        expect(updated.status, IncidentStatus.enCamino);
        expect(updated.assignedPatrolCode, 'PL-402');
        expect(updated.routeWaypoints, isNotEmpty);
      },
    );
  });
}
