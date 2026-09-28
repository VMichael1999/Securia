import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_core/securia_core.dart';
import 'package:securia_patrol/app/strings/shift_strings.dart';
import 'package:securia_patrol/features/shift/presentation/views/shift_view.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_bloc.dart';
import 'package:securia_patrol/features/tactical_map/presentation/bloc/patrol_event.dart';

import '../../helpers/fake_platform.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUpAll(mockPlatformPlugins);

  late InMemorySecuriaRepository repo;
  late PatrolBloc bloc;
  final start = DateTime(2026, 9, 27, 21, 0);

  Future<void> pumpShift(WidgetTester tester, {DateTime? now}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    repo = InMemorySecuriaRepository.fresh();
    final unit = repo.getCurrentPatrol();
    bloc = PatrolBloc(
      repository: repo,
      initialPatrol: unit,
      clock: () => start,
    );
    addTearDown(bloc.close);

    await pumpApp(
      tester,
      ShiftView(
        clock: () => now ?? start.add(const Duration(hours: 3, minutes: 40)),
      ),
      providers: [BlocProvider<PatrolBloc>.value(value: bloc)],
    );
    bloc.add(PatrolStarted(unit));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('Muestra la unidad en grande, el turno y lo que queda', (
    tester,
  ) async {
    await pumpShift(tester);

    expect(find.text('PL-402'), findsOneWidget);
    expect(find.text('21:00 – 09:00'), findsOneWidget);
    expect(find.text(ShiftStrings.remaining(8, 20)), findsOneWidget);
    // Sin llegadas todavía no se inventa un promedio
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('El interruptor explica su consecuencia y cambia el estado', (
    tester,
  ) async {
    await pumpShift(tester);

    expect(find.text(ShiftStrings.dutyOnBody('3.5 km')), findsOneWidget);
    await tester.tap(find.text(ShiftStrings.dutyOn));
    await tester.pump();
    await tester.pump();

    expect(bloc.state.currentPatrol.status, PatrolStatus.fueraServicio);
    expect(find.text(ShiftStrings.dutyOffBody), findsOneWidget);
  });

  testWidgets('Con una intervención en curso no se puede terminar la guardia', (
    tester,
  ) async {
    await pumpShift(tester);
    bloc.add(PatrolAcceptDispatch(bloc.state.proximityAlertIncident!));
    await tester.pump();
    await tester.pump();

    expect(find.text(ShiftStrings.endShiftLocked), findsOneWidget);
    expect(find.text(ShiftStrings.dutyLocked), findsOneWidget);
  });

  testWidgets('Terminar la guardia pide confirmación', (tester) async {
    await pumpShift(tester);

    await tester.tap(find.text(ShiftStrings.endShift));
    await tester.pumpAndSettle();
    expect(find.text(ShiftStrings.endShiftTitle), findsOneWidget);

    await tester.tap(find.text(ShiftStrings.endShiftKeep));
    await tester.pumpAndSettle();
    expect(find.text(ShiftStrings.endShiftTitle), findsNothing);
    expect(bloc.state.currentPatrol.status, PatrolStatus.disponible);
  });
}
