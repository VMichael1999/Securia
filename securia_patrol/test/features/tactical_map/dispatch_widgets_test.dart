import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securia_core/securia_core.dart';
import 'package:securia_patrol/app/strings/dispatch_strings.dart';
import 'package:securia_patrol/features/tactical_map/presentation/models/dispatch_step.dart';
import 'package:securia_patrol/features/tactical_map/presentation/models/resolution_outcome.dart';
import 'package:securia_patrol/features/tactical_map/presentation/widgets/dispatch_action_button.dart';
import 'package:securia_patrol/features/tactical_map/presentation/widgets/incoming_alert_overlay.dart';
import 'package:securia_patrol/features/tactical_map/presentation/widgets/resolution_sheet.dart';
import 'package:securia_patrol/features/tactical_map/presentation/widgets/tactical_hud_sheet.dart';

import '../../helpers/pump_app.dart';

void main() {
  final incident = IncidentModel(
    id: 'inc_1',
    type: IncidentType.asalto,
    title: 'Asalto',
    description: 'Dos sujetos en moto negra',
    location: const GeoLocation(
      latitude: -12.0864,
      longitude: -77.0345,
      address: 'Av. Javier Prado Este 2100',
    ),
    citizenId: 'cit',
    citizenName: 'Vecino',
    citizenPhone: '999 111 222',
    timestamp: DateTime(2026, 9, 25),
    urgency: UrgencyLevel.critica,
  );

  group('DispatchActionButton', () {
    const labels = {
      DispatchStep.accept: DispatchStrings.actionAccept,
      DispatchStep.onTheWay: DispatchStrings.actionOnTheWay,
      DispatchStep.arrived: DispatchStrings.actionArrived,
      DispatchStep.conclude: DispatchStrings.actionConclude,
    };

    for (final entry in labels.entries) {
      testWidgets(
        '${entry.key.name} muestra "${entry.value}" y responde al toque',
        (tester) async {
          var taps = 0;
          await pumpApp(
            tester,
            DispatchActionButton(step: entry.key, onPressed: () => taps++),
          );

          await tester.tap(find.text(entry.value));
          expect(taps, 1);
        },
      );
    }

    testWidgets('Sin acción no muestra botón', (tester) async {
      await pumpApp(
        tester,
        DispatchActionButton(step: DispatchStep.none, onPressed: () {}),
      );
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('TacticalHudSheet', () {
    Future<List<Object>> pumpHud(
      WidgetTester tester,
      IncidentModel inc, {
      bool closable = true,
    }) async {
      final calls = <Object>[];
      await pumpApp(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: TacticalHudSheet(
            incident: inc,
            patrolId: 'patrol_01',
            distanceMeters: 850,
            etaMinutes: 2,
            onAction: calls.add,
            onCallCitizen: () => calls.add('call'),
            onClose: closable ? () => calls.add('close') : null,
          ),
        ),
      );
      return calls;
    }

    testWidgets('Muestra qué, dónde, lo que dijo el ciudadano y a cuánto', (
      tester,
    ) async {
      await pumpHud(tester, incident);

      expect(find.text(IncidentType.asalto.title), findsOneWidget);
      expect(find.text('Av. Javier Prado Este 2100'), findsOneWidget);
      expect(find.text('“Dos sujetos en moto negra”'), findsOneWidget);
      expect(find.text('850 m'), findsOneWidget);
      expect(find.text(DispatchStrings.minutes(2)), findsOneWidget);
    });

    testWidgets('El botón principal envía el paso actual', (tester) async {
      final calls = await pumpHud(
        tester,
        incident.copyWith(
          status: IncidentStatus.enCamino,
          assignedPatrolId: 'patrol_01',
        ),
      );

      await tester.tap(find.text(DispatchStrings.actionArrived));
      expect(calls, [DispatchStep.arrived]);
    });

    testWidgets('Llamar al ciudadano está siempre a un toque', (tester) async {
      final calls = await pumpHud(tester, incident);
      await tester.tap(find.byIcon(Icons.phone_rounded));
      expect(calls, ['call']);
    });

    testWidgets('Si lo atiende otra unidad lo indica y no ofrece acción', (
      tester,
    ) async {
      await pumpHud(
        tester,
        incident.copyWith(
          status: IncidentStatus.enCamino,
          assignedPatrolId: 'patrol_02',
          assignedPatrolCode: 'MOTO-08',
        ),
      );

      expect(find.text(DispatchStrings.takenBy('MOTO-08')), findsOneWidget);
      expect(find.byType(DispatchActionButton), findsNothing);
    });

    testWidgets('Sin onClose no hay botón cerrar', (tester) async {
      await pumpHud(tester, incident, closable: false);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });

  group('IncomingAlertOverlay', () {
    testWidgets('Muestra la alerta y responde a aceptar e ignorar', (
      tester,
    ) async {
      final calls = <String>[];
      await pumpApp(
        tester,
        IncomingAlertOverlay(
          incident: incident,
          distanceMeters: 420,
          etaMinutes: 1,
          onAccept: () => calls.add('accept'),
          onIgnore: () => calls.add('ignore'),
        ),
      );

      expect(find.text(DispatchStrings.incomingTitle), findsOneWidget);
      expect(find.text(IncidentType.asalto.title), findsOneWidget);
      // La urgencia se lee como palabra, no solo por el color
      expect(find.text('Crítica'), findsOneWidget);
      expect(find.text('420 m'), findsOneWidget);

      // Deja terminar la animación de entrada
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text(DispatchStrings.incomingAccept));
      await tester.tap(find.text(DispatchStrings.incomingIgnore));
      expect(calls, ['accept', 'ignore']);
    });
  });

  group('ResolutionSheet', () {
    testWidgets('Concluir exige elegir un resultado y devuelve la nota', (
      tester,
    ) async {
      String? note;
      var closed = false;
      await pumpApp(
        tester,
        Builder(
          builder:
              (context) => TextButton(
                onPressed: () async {
                  note = await ResolutionSheet.show(context);
                  closed = true;
                },
                child: const Text('abrir'),
              ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      // Sin resultado el botón no hace nada
      await tester.tap(find.text(DispatchStrings.resolveConfirm));
      await tester.pumpAndSettle();
      expect(closed, isFalse);

      await tester.tap(find.text(ResolutionOutcome.detenido.label));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Placa ABC-123');
      await tester.tap(find.text(DispatchStrings.resolveConfirm));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(note, ResolutionOutcome.detenido.buildNote('Placa ABC-123'));
    });
  });
}
