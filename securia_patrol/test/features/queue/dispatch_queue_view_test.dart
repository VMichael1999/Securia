import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_core/securia_core.dart';
import 'package:securia_patrol/app/strings/dispatch_strings.dart';
import 'package:securia_patrol/app/strings/queue_strings.dart';
import 'package:securia_patrol/app/widgets/urgency_badge.dart';
import 'package:securia_patrol/features/queue/presentation/views/dispatch_queue_view.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_bloc.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_event.dart';

import '../../helpers/fake_platform.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUpAll(mockPlatformPlugins);

  late InMemorySecuriaRepository repo;
  late PatrolBloc bloc;

  Future<void> pumpQueue(WidgetTester tester, {VoidCallback? onOpenMap}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    repo = InMemorySecuriaRepository.fresh();
    final unit = repo.getCurrentPatrol();
    bloc = PatrolBloc(repository: repo, initialPatrol: unit);
    addTearDown(bloc.close);

    await pumpApp(
      tester,
      DispatchQueueView(onOpenMap: onOpenMap),
      providers: [BlocProvider<PatrolBloc>.value(value: bloc)],
    );
    bloc.add(PatrolStarted(unit));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('Lista los activos con su urgencia en palabra y forma', (
    tester,
  ) async {
    await pumpQueue(tester);

    expect(find.text(QueueStrings.title), findsOneWidget);
    final rows = find.byType(QueueRow);
    expect(rows, findsNWidgets(bloc.state.triageQueue.length));
    expect(
      find.byType(UrgencyBar),
      findsNWidgets(bloc.state.triageQueue.length),
    );
    // El primero es el más urgente
    final first = bloc.state.triageQueue.first;
    expect(
      find.descendant(of: rows.first, matching: find.text(first.type.title)),
      findsOneWidget,
    );
  });

  testWidgets('Lo que atiende otra unidad queda atenuado y no se puede tomar', (
    tester,
  ) async {
    await pumpQueue(tester);
    await repo.updateIncidentStatus(
      'inc_today_01',
      IncidentStatus.asignado,
      patrolId: 'patrol_99',
      patrolCode: 'PL-777',
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(DispatchStrings.takenBy('PL-777')), findsOneWidget);
    expect(find.text(QueueStrings.cannotTake), findsWidgets);
    final opacity = tester.widget<Opacity>(
      find.ancestor(
        of: find.text(DispatchStrings.takenBy('PL-777')),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets('Tocar una fila la selecciona y lleva al mapa', (tester) async {
    var opened = 0;
    await pumpQueue(tester, onOpenMap: () => opened++);

    await tester.tap(find.byType(QueueRow).first);
    await tester.pump();

    expect(opened, 1);
    expect(bloc.state.selectedIncident?.id, bloc.state.triageQueue.first.id);
  });

  testWidgets('Sin alertas activas muestra el estado vacío', (tester) async {
    await pumpQueue(tester);
    for (final i in repo.getSnapshotIncidents().where(
      (i) => !i.status.isClosed,
    )) {
      await repo.updateIncidentStatus(i.id, IncidentStatus.resuelto);
    }
    await tester.pump();
    await tester.pump();

    expect(find.text(QueueStrings.emptyTitle), findsOneWidget);
  });
}
