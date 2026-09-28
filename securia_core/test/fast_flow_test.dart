import 'package:test/test.dart';
import 'package:securia_core/securia_core.dart';

void main() {
  final repo = InMemorySecuriaRepository.fresh();
  const loc = GeoLocation(latitude: -12.0850, longitude: -77.0360);

  setUpAll(() => repo.signInCitizen(dni: '12345678', phone: '900000001'));

  test('Cada tipo de reporte define su urgencia por defecto', () {
    expect(IncidentType.emergenciaGeneral.defaultUrgency, UrgencyLevel.critica);
    expect(IncidentType.asalto.defaultUrgency, UrgencyLevel.critica);
    expect(IncidentType.sospechoso.defaultUrgency, UrgencyLevel.media);
    expect(
      IncidentType.reportTypes,
      isNot(contains(IncidentType.emergenciaGeneral)),
    );
  });

  test('SOS inmediato se puede precisar después de enviado', () async {
    final sos = await repo.createIncident(
      type: IncidentType.emergenciaGeneral,
      title: 'Emergencia SOS',
      description: '',
      location: loc,
      urgency: UrgencyLevel.critica,
    );

    await repo.updateIncidentDetails(sos.id, type: IncidentType.violencia);

    final updated = repo.getSnapshotIncidents().firstWhere(
      (i) => i.id == sos.id,
    );
    expect(updated.type, IncidentType.violencia);
    expect(updated.status, IncidentStatus.reportado);
  });

  test('Cancelar una alerta asignada libera a la patrulla', () async {
    final inc = await repo.createIncident(
      type: IncidentType.robo,
      title: 'Robo',
      description: '',
      location: loc,
      urgency: UrgencyLevel.alta,
    );
    await repo.updateIncidentStatus(
      inc.id,
      IncidentStatus.asignado,
      patrolId: 'patrol_03',
      patrolCode: 'SERENAZGO-14',
    );

    var patrol = repo.getSnapshotPatrols().firstWhere(
      (p) => p.id == 'patrol_03',
    );
    expect(patrol.status, PatrolStatus.enRespuesta);
    expect(patrol.activeIncidentId, inc.id);

    // El ciudadano cancela sin conocer la patrulla asignada
    await repo.updateIncidentStatus(inc.id, IncidentStatus.cancelado);

    patrol = repo.getSnapshotPatrols().firstWhere((p) => p.id == 'patrol_03');
    expect(patrol.status, PatrolStatus.disponible);
    expect(patrol.activeIncidentId, isNull);
  });

  test('Una segunda unidad no puede tomar un incidente ya asignado', () async {
    final inc = await repo.createIncident(
      type: IncidentType.asalto,
      title: 'Asalto',
      description: '',
      location: loc,
      urgency: UrgencyLevel.critica,
    );
    await repo.updateIncidentStatus(
      inc.id,
      IncidentStatus.asignado,
      patrolId: 'patrol_01',
      patrolCode: 'PL-402',
    );

    expect(
      () => repo.updateIncidentStatus(
        inc.id,
        IncidentStatus.asignado,
        patrolId: 'patrol_02',
        patrolCode: 'MOTO-08',
      ),
      throwsStateError,
    );
  });
}
