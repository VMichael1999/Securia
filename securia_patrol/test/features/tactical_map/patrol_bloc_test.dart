import 'package:flutter_test/flutter_test.dart';
import 'package:securia_core/securia_core.dart';
import 'package:securia_patrol/app/strings/dispatch_strings.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_bloc.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_event.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_state.dart';

void main() {
  late InMemorySecuriaRepository repo;
  late PatrolBloc bloc;
  late PatrolUnitModel unit;
  late List<String?> messages;

  // Incidente semilla pendiente y crítico dentro del radar de PL-402
  const seededAlertId = 'inc_today_01';

  setUp(() {
    repo = InMemorySecuriaRepository.fresh();
    unit = repo.getCurrentPatrol();
    bloc = PatrolBloc(repository: repo, initialPatrol: unit)
      ..add(PatrolStarted(unit));
    // Los mensajes son de un solo uso: se leen de los estados emitidos
    messages = [];
    bloc.stream.listen((s) => messages.add(s.statusMessage));
  });

  tearDown(() => bloc.close());

  Future<PatrolState> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return bloc.state;
  }

  IncidentModel incident(String id) =>
      repo.getSnapshotIncidents().firstWhere((i) => i.id == id);

  test(
    'Una alerta pendiente dentro del radar se ofrece a la unidad libre',
    () async {
      final state = await settle();
      expect(state.proximityAlertIncident?.id, seededAlertId);
    },
  );

  test('La alerta desaparece cuando otra unidad toma el incidente', () async {
    await settle();
    await repo.updateIncidentStatus(
      seededAlertId,
      IncidentStatus.asignado,
      patrolId: 'patrol_03',
      patrolCode: 'SERENAZGO-14',
    );
    final state = await settle();

    expect(state.proximityAlertIncident, isNull);
  });

  test('Se ofrece primero la alerta más urgente del radar', () async {
    await settle();
    await repo.createIncident(
      type: IncidentType.sospechoso,
      title: 'Sospechoso',
      description: '',
      location: unit.location,
      citizenId: 'cit_001',
      urgency: UrgencyLevel.media,
    );
    final state = await settle();

    expect(state.proximityAlertIncident?.urgency, UrgencyLevel.critica);
  });

  test('Fuera de servicio no recibe alertas', () async {
    await settle();
    bloc.add(const PatrolChangeDutyStatus(PatrolStatus.fueraServicio));
    final state = await settle();

    expect(state.proximityAlertIncident, isNull);
  });

  test('Ignorar muestra la siguiente alerta pendiente', () async {
    await settle();
    final second = await repo.createIncident(
      type: IncidentType.robo,
      title: 'Robo',
      description: '',
      location: unit.location,
      citizenId: 'cit_001',
      urgency: UrgencyLevel.alta,
    );
    await settle();

    bloc.add(const PatrolDismissProximityAlert(seededAlertId));
    final state = await settle();

    expect(state.proximityAlertIncident?.id, second.id);
  });

  test('Flujo completo: aceptar, en camino, en el lugar y concluir', () async {
    await settle();

    bloc.add(PatrolAcceptDispatch(incident(seededAlertId)));
    var state = await settle();
    expect(state.activeDispatchedIncident?.status, IncidentStatus.asignado);
    expect(state.proximityAlertIncident, isNull);
    expect(state.routePolyline, isNotEmpty);
    expect(state.etaMinutes, isNotNull);

    bloc.add(PatrolEnCamino(incident(seededAlertId)));
    state = await settle();
    expect(state.activeDispatchedIncident?.status, IncidentStatus.enCamino);
    expect(state.isSirenActive, isTrue);

    bloc.add(PatrolEnLugar(incident(seededAlertId)));
    state = await settle();
    expect(state.activeDispatchedIncident?.status, IncidentStatus.enLugar);
    expect(state.isSirenActive, isFalse);

    bloc.add(
      PatrolResolveIncident(
        incident: incident(seededAlertId),
        resolutionNote: '[Disuelto] Zona despejada.',
      ),
    );
    state = await settle();
    expect(state.activeDispatchedIncident, isNull);
    expect(state.routePolyline, isEmpty);
    expect(state.distanceToTargetMeters, isNull);
    expect(incident(seededAlertId).status, IncidentStatus.resuelto);
    expect(incident(seededAlertId).notes.last, contains('Disuelto'));
  });

  test(
    'Tomar un incidente ya asignado a otra unidad avisa y no lo despacha',
    () async {
      await settle();
      final target = incident(seededAlertId);
      await repo.updateIncidentStatus(
        seededAlertId,
        IncidentStatus.asignado,
        patrolId: 'patrol_02',
        patrolCode: 'MOTO-08',
      );

      bloc.add(PatrolAcceptDispatch(target));
      final state = await settle();

      expect(state.activeDispatchedIncident, isNull);
      expect(messages.whereType<String>().last, startsWith('No se pudo tomar'));
      expect(incident(seededAlertId).assignedPatrolCode, 'MOTO-08');
    },
  );

  test(
    'Si el ciudadano cancela, la unidad queda libre y se le avisa',
    () async {
      await settle();
      bloc.add(PatrolAcceptDispatch(incident(seededAlertId)));
      await settle();
      bloc.add(PatrolEnCamino(incident(seededAlertId)));
      await settle();

      await repo.updateIncidentStatus(seededAlertId, IncidentStatus.cancelado);
      final state = await settle();

      expect(state.activeDispatchedIncident, isNull);
      expect(state.isSirenActive, isFalse);
      expect(messages, contains(DispatchStrings.citizenCancelled));
      expect(
        repo.getSnapshotPatrols().firstWhere((p) => p.id == unit.id).status,
        PatrolStatus.disponible,
      );
    },
  );

  test('El mensaje de estado no se repite en los estados siguientes', () async {
    await settle();
    bloc.add(PatrolAcceptDispatch(incident(seededAlertId)));
    await settle();
    bloc.add(const PatrolToggleSiren());
    await settle();

    final accepted = DispatchStrings.accepted(unit.unitCode);
    expect(messages.where((m) => m == accepted), hasLength(1));
    expect(messages.last, isNull);
  });

  test('Cerrar la ficha no suelta un despacho propio en curso', () async {
    await settle();
    bloc.add(PatrolAcceptDispatch(incident(seededAlertId)));
    await settle();

    bloc.add(const PatrolClearActiveDispatch());
    final state = await settle();

    expect(state.activeDispatchedIncident?.id, seededAlertId);
    expect(state.routePolyline, isNotEmpty);
  });

  test('La cola de triage ordena por urgencia y luego por distancia', () async {
    final state = await settle();
    final queue = state.triageQueue;

    for (var i = 1; i < queue.length; i++) {
      expect(
        queue[i - 1].urgency.index,
        lessThanOrEqualTo(queue[i].urgency.index),
      );
    }
  });

  group('Tiempos de la guardia y de la intervención', () {
    late DateTime now;
    late PatrolBloc timed;

    setUp(() {
      now = DateTime(2026, 9, 27, 21, 0);
      timed = PatrolBloc(
        repository: repo,
        initialPatrol: unit,
        clock: () => now,
      )..add(PatrolStarted(unit));
    });

    tearDown(() => timed.close());

    Future<PatrolState> settleTimed() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return timed.state;
    }

    test('La guardia registra su hora de inicio', () async {
      final state = await settleTimed();
      expect(state.shiftStartedAt, DateTime(2026, 9, 27, 21, 0));
      expect(state.averageArrival, isNull);
    });

    test('Registra aceptar y llegar, y calcula la llegada promedio', () async {
      await settleTimed();
      now = DateTime(2026, 9, 27, 21, 14);
      timed.add(PatrolAcceptDispatch(incident(seededAlertId)));
      await settleTimed();
      timed.add(PatrolEnCamino(incident(seededAlertId)));
      await settleTimed();
      now = DateTime(2026, 9, 27, 21, 19);
      timed.add(PatrolEnLugar(incident(seededAlertId)));
      var state = await settleTimed();

      expect(state.dispatchAcceptedAt, DateTime(2026, 9, 27, 21, 14));
      expect(state.dispatchArrivedAt, DateTime(2026, 9, 27, 21, 19));
      expect(state.averageArrival, const Duration(minutes: 5));

      timed.add(
        PatrolResolveIncident(
          incident: incident(seededAlertId),
          resolutionNote: '[Atendido]',
        ),
      );
      state = await settleTimed();

      // Al concluir se limpian las horas del despacho, pero el promedio queda
      expect(state.dispatchAcceptedAt, isNull);
      expect(state.dispatchArrivedAt, isNull);
      expect(state.averageArrival, const Duration(minutes: 5));
      // Solo cuenta lo concluido en esta guardia, no el historial de la unidad
      expect(state.shiftConcludedCount, 1);
    });

    test(
      'Una guardia nueva empieza sin despachos ni alertas descartadas',
      () async {
        await settleTimed();
        timed.add(const PatrolDismissProximityAlert(seededAlertId));
        await settleTimed();
        expect(timed.state.dismissedAlertIds, contains(seededAlertId));

        timed.add(PatrolStarted(unit));
        final state = await settleTimed();
        expect(state.dismissedAlertIds, isEmpty);
        expect(state.proximityAlertIncident?.id, seededAlertId);
      },
    );
  });
}
