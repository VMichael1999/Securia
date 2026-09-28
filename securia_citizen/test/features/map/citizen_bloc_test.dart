import 'package:flutter_test/flutter_test.dart';
import 'package:securia_citizen/features/map/presentation/bloc/citizen_bloc.dart';
import 'package:securia_citizen/features/map/presentation/bloc/citizen_event.dart';
import 'package:securia_citizen/features/map/presentation/bloc/citizen_state.dart';
import 'package:securia_core/securia_core.dart';

void main() {
  late InMemorySecuriaRepository repo;
  late CitizenBloc bloc;
  const location = GeoLocation(latitude: -12.0864, longitude: -77.0345);

  setUp(() async {
    repo = InMemorySecuriaRepository.fresh();
    final citizen = await repo.signInCitizen(
      dni: '12345678',
      phone: '900000001',
    );
    bloc = CitizenBloc(repository: repo, citizen: citizen)
      ..add(const CitizenStarted());
  });

  tearDown(() => bloc.close());

  Future<CitizenState> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return bloc.state;
  }

  test(
    'Al iniciar, el ciudadano de prueba no tiene una alerta activa',
    () async {
      final state = await settle();
      expect(state.activeSosIncident, isNull);
    },
  );

  test(
    'SOS inmediato se emite como emergencia general crítica, sin formulario',
    () async {
      await settle();
      bloc.add(const CitizenImmediateSosRequested(location));
      final state = await settle();

      final sos = state.activeSosIncident;
      expect(sos, isNotNull);
      expect(sos!.type, IncidentType.emergenciaGeneral);
      expect(sos.urgency, UrgencyLevel.critica);
      expect(sos.status, IncidentStatus.reportado);
      expect(state.isReportingSos, isFalse);
    },
  );

  test('El reporte con detalle envía tipo, observación y foto', () async {
    await settle();
    bloc.add(
      const CitizenIncidentReportRequested(
        type: IncidentType.sospechoso,
        location: location,
        description: 'Auto sin placa rondando',
        photoPath: 'evidencia.jpg',
      ),
    );
    final sent = (await settle()).activeSosIncident!;

    expect(sent.type, IncidentType.sospechoso);
    expect(sent.urgency, UrgencyLevel.media);
    expect(sent.description, 'Auto sin placa rondando');
    expect(sent.photoPath, 'evidencia.jpg');
  });

  test('Sin observación el reporte usa una descripción por defecto', () async {
    await settle();
    bloc.add(
      const CitizenIncidentReportRequested(
        type: IncidentType.robo,
        location: location,
      ),
    );
    final sent = (await settle()).activeSosIncident!;

    expect(sent.description, contains(IncidentType.robo.title));
    expect(sent.photoPath, isNull);
  });

  test(
    'Precisar el SOS actualiza tipo y urgencia de la misma alerta',
    () async {
      await settle();
      bloc.add(const CitizenImmediateSosRequested(location));
      final sent = (await settle()).activeSosIncident!;

      bloc.add(
        CitizenSosDetailsUpdated(
          sent.id,
          type: IncidentType.robo,
          description: 'Moto negra',
        ),
      );
      final updated = (await settle()).activeSosIncident!;

      expect(updated.id, sent.id);
      expect(updated.type, IncidentType.robo);
      expect(updated.urgency, UrgencyLevel.alta);
      expect(updated.description, 'Moto negra');
    },
  );

  test('Cancelar quita la alerta activa del ciudadano', () async {
    await settle();
    bloc.add(const CitizenImmediateSosRequested(location));
    final sent = (await settle()).activeSosIncident!;

    bloc.add(CitizenCancelActiveSos(sent.id));
    final state = await settle();

    expect(state.activeSosIncident, isNull);
    expect(
      repo.getSnapshotIncidents().firstWhere((i) => i.id == sent.id).status,
      IncidentStatus.cancelado,
    );
  });
}
