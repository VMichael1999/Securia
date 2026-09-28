import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_patrol/app/injection.dart';
import 'package:securia_patrol/app/securia_patrol_app.dart';
import 'package:securia_patrol/app/strings/shift_strings.dart';
import 'package:securia_patrol/features/queue/presentation/views/dispatch_queue_view.dart';

import 'helpers/fake_platform.dart';

void main() {
  setUpAll(mockPlatformPlugins);
  setUp(setupPatrolDependencies);

  Future<void> pumpPatrolApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SecuriaPatrolApp());
    await tester.pump();
  }

  testWidgets(
    'El inicio de guardia muestra las unidades y el botón en tipo oración',
    (tester) async {
      await pumpPatrolApp(tester);

      expect(find.text(ShiftStrings.appName), findsOneWidget);
      expect(find.text('PL-402'), findsOneWidget);
      expect(find.text('MOTO-08'), findsOneWidget);
      expect(find.text(ShiftStrings.startShift), findsOneWidget);
    },
  );

  testWidgets('Sin un CIP válido no inicia la guardia', (tester) async {
    await pumpPatrolApp(tester);

    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.text(ShiftStrings.startShift));
    await tester.pump();

    expect(find.text(ShiftStrings.cipError), findsOneWidget);
    expect(find.text(ShiftStrings.navQueue), findsNothing);
  });

  testWidgets('Con CIP inicia la guardia y navega entre Mapa, Cola y Turno', (
    tester,
  ) async {
    await pumpPatrolApp(tester);

    await tester.enterText(find.byType(TextField), '30000001');
    await tester.tap(find.text(ShiftStrings.startShift));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // La alerta entrante cubre el mapa: se ignoran todas para navegar
    while (find.textContaining('Ignorar').evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.textContaining('Ignorar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    await tester.tap(find.text(ShiftStrings.navQueue));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(QueueRow), findsWidgets);

    await tester.tap(find.text(ShiftStrings.navShift));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(ShiftStrings.dutyOn), findsOneWidget);
    expect(find.text(ShiftStrings.endShift), findsOneWidget);
  });
}
