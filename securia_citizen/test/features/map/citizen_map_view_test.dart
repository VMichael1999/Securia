import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_citizen/app/strings/sos_strings.dart';
import 'package:securia_citizen/features/map/presentation/bloc/citizen_bloc.dart';
import 'package:securia_citizen/features/map/presentation/bloc/citizen_event.dart';
import 'package:securia_citizen/features/map/presentation/views/citizen_map_view.dart';
import 'package:securia_core/securia_core.dart';

import '../../helpers/fake_platform.dart';
import '../../helpers/pump_app.dart';

void main() {
  late InMemorySecuriaRepository repo;
  late CitizenBloc bloc;

  setUpAll(mockPlatformPlugins);

  /// El pulso del SOS se repite siempre: pumpAndSettle nunca terminaría
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> pumpMap(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Se crean dentro del test para que sus streams corran en el reloj simulado
    repo = InMemorySecuriaRepository.fresh();
    bloc = CitizenBloc(repository: repo);
    addTearDown(bloc.close);

    await pumpApp(
      tester,
      const CitizenMapView(),
      providers: [BlocProvider<CitizenBloc>.value(value: bloc)],
    );
    bloc.add(const CitizenStarted());
    await tester.pump();
    await tester.pump();
  }

  Future<void> holdSos(WidgetTester tester) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(SosStrings.sosLabel)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await gesture.up();
    await tester.pump();
    await settle(tester);
  }

  testWidgets('Sin alerta activa muestra SOS y Reportar incidente flotando', (
    tester,
  ) async {
    await pumpMap(tester);

    expect(find.text(SosStrings.sosLabel), findsOneWidget);
    expect(find.text(SosStrings.reportButton), findsOneWidget);
  });

  testWidgets(
    'SOS inmediato: se envía, pregunta qué pasa y el panel lo refleja',
    (tester) async {
      await pumpMap(tester);
      await holdSos(tester);

      // La alerta ya salió antes de preguntar nada
      expect(
        repo.getSnapshotIncidents().first.type,
        IncidentType.emergenciaGeneral,
      );
      expect(find.text(SosStrings.followUpTitle), findsOneWidget);

      await tester.tap(find.text(IncidentType.violencia.shortLabel));
      await tester.pump();
      await settle(tester);

      expect(find.text(SosStrings.followUpTitle), findsNothing);
      expect(find.text(SosStrings.trackerSearching), findsOneWidget);
      expect(find.text(IncidentType.violencia.shortLabel), findsOneWidget);
      expect(find.text(SosStrings.sosLabel), findsNothing);
    },
  );

  testWidgets('Reportar incidente: elegir tipo, observar y enviar', (
    tester,
  ) async {
    await pumpMap(tester);

    await tester.tap(find.text(SosStrings.reportButton));
    await settle(tester);

    // Elegir un tipo no envía nada todavía: el botón pide el tipo primero
    expect(find.text(SosStrings.reportChooseType), findsOneWidget);
    await tester.tap(find.text(IncidentType.robo.shortLabel));
    await settle(tester);
    expect(find.text(SosStrings.reportSubtitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Se llevaron una mochila');
    await tester.ensureVisible(find.text(SosStrings.reportSend));
    await tester.tap(find.text(SosStrings.reportSend));
    await settle(tester);

    final sent = repo.getSnapshotIncidents().first;
    expect(sent.type, IncidentType.robo);
    expect(sent.urgency, UrgencyLevel.alta);
    expect(sent.description, 'Se llevaron una mochila');
    expect(find.text(SosStrings.trackerSearching), findsOneWidget);
    // El reporte con detalle no vuelve a preguntar el tipo
    expect(find.text(SosStrings.followUpTitle), findsNothing);
  });

  testWidgets('Cerrar el reporte sin enviar no crea alerta', (tester) async {
    await pumpMap(tester);
    final before = repo.getSnapshotIncidents().length;

    await tester.tap(find.text(SosStrings.reportButton));
    await settle(tester);
    await tester.tap(find.text(IncidentType.incendio.shortLabel));
    await tester.tapAt(const Offset(200, 40)); // fuera de la hoja
    await settle(tester);

    expect(repo.getSnapshotIncidents().length, before);
    expect(find.text(SosStrings.sosLabel), findsOneWidget);
  });

  testWidgets('Cancelar pide confirmación antes de retirar la alerta', (
    tester,
  ) async {
    await pumpMap(tester);
    await holdSos(tester);
    await tester.tap(find.text(SosStrings.followUpSkip));
    await settle(tester);

    await tester.tap(find.text(SosStrings.cancelAlert));
    await settle(tester);
    expect(find.text(SosStrings.cancelTitle), findsOneWidget);

    await tester.tap(find.text(SosStrings.cancelKeep));
    await settle(tester);
    expect(find.text(SosStrings.trackerSearching), findsOneWidget);

    await tester.tap(find.text(SosStrings.cancelAlert));
    await settle(tester);
    await tester.tap(find.text(SosStrings.cancelConfirm));
    await tester.pump();
    await settle(tester);

    expect(find.text(SosStrings.sosLabel), findsOneWidget);
    expect(repo.getSnapshotIncidents().first.status, IncidentStatus.cancelado);
  });
}
