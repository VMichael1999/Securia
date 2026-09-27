import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_core/securia_core.dart';
import 'package:securia_patrol/app/strings/dispatch_strings.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_bloc.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_event.dart';
import 'package:securia_patrol/features/tactical_map/presentation/models/resolution_outcome.dart';
import 'package:securia_patrol/features/tactical_map/presentation/views/tactical_map_view.dart';

import '../../helpers/fake_platform.dart';
import '../../helpers/pump_app.dart';

void main() {
  late InMemorySecuriaRepository repo;
  late PatrolBloc bloc;

  setUpAll(mockPlatformPlugins);

  /// Las balizas y la alerta pulsan siempre: pumpAndSettle nunca terminaría
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> pumpMap(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // La fuente de los tests es más ancha que la real: evita desbordes falsos
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    // Se crean dentro del test para que sus streams corran en el reloj simulado
    repo = InMemorySecuriaRepository.fresh();
    final unit = repo.getCurrentPatrol();
    bloc = PatrolBloc(repository: repo, initialPatrol: unit);
    addTearDown(bloc.close);

    await pumpApp(
      tester,
      const TacticalMapView(),
      providers: [BlocProvider<PatrolBloc>.value(value: bloc)],
    );
    bloc.add(PatrolStarted(unit));
    await settle(tester);
  }

  Future<void> tapAndSettle(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await settle(tester);
  }

  testWidgets('Una alerta cercana ocupa la pantalla y se acepta con un toque', (
    tester,
  ) async {
    await pumpMap(tester);

    expect(find.text(DispatchStrings.incomingTitle), findsOneWidget);
    await tapAndSettle(tester, DispatchStrings.incomingAccept);

    expect(find.text(DispatchStrings.incomingTitle), findsNothing);
    expect(find.text(DispatchStrings.actionOnTheWay), findsOneWidget);
    // El aviso aparece arriba y no tapa el botón principal
    final toast = tester.getRect(find.text(DispatchStrings.accepted('PL-402')));
    final action = tester.getRect(find.text(DispatchStrings.actionOnTheWay));
    expect(toast.bottom, lessThan(action.top));
  });

  testWidgets('Flujo completo con un solo botón hasta concluir', (
    tester,
  ) async {
    await pumpMap(tester);
    await tapAndSettle(tester, DispatchStrings.incomingAccept);

    await tapAndSettle(tester, DispatchStrings.actionOnTheWay);
    expect(find.text(DispatchStrings.actionArrived), findsOneWidget);

    await tapAndSettle(tester, DispatchStrings.actionArrived);
    expect(find.text(DispatchStrings.actionConclude), findsOneWidget);

    await tapAndSettle(tester, DispatchStrings.actionConclude);
    await tapAndSettle(tester, ResolutionOutcome.disuelto.label);
    await tapAndSettle(tester, DispatchStrings.resolveConfirm);

    final resolved = repo.getSnapshotIncidents().firstWhere(
      (i) => i.id == 'inc_today_01',
    );
    expect(resolved.status, IncidentStatus.resuelto);
    expect(resolved.notes.last, startsWith('[Disuelto]'));
    expect(find.text(DispatchStrings.actionConclude), findsNothing);
  });

  testWidgets('Un despacho propio en curso no muestra botón cerrar', (
    tester,
  ) async {
    await pumpMap(tester);
    await tapAndSettle(tester, DispatchStrings.incomingAccept);

    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('Ignorar la alerta vuelve al radar sin despachar', (
    tester,
  ) async {
    await pumpMap(tester);
    await tapAndSettle(tester, DispatchStrings.incomingIgnore);

    expect(find.text(DispatchStrings.incomingTitle), findsNothing);
    expect(
      repo
          .getSnapshotIncidents()
          .firstWhere((i) => i.id == 'inc_today_01')
          .status,
      IncidentStatus.reportado,
    );
  });
}
