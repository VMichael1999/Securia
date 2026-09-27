import 'package:flutter_test/flutter_test.dart';
import 'package:securia_core/securia_core.dart';
import 'package:securia_patrol/features/tactical_map/presentation/models/dispatch_step.dart';
import 'package:securia_patrol/features/tactical_map/presentation/models/resolution_outcome.dart';

void main() {
  final base = IncidentModel(
    id: 'inc',
    type: IncidentType.asalto,
    title: 'Asalto',
    description: '',
    location: const GeoLocation(latitude: 0, longitude: 0),
    citizenId: 'c',
    citizenName: 'C',
    citizenPhone: '1',
    timestamp: DateTime(2026),
  );

  group('DispatchStep', () {
    DispatchStep stepFor(IncidentStatus status, {String? owner}) =>
        DispatchStep.of(
          base.copyWith(status: status, assignedPatrolId: owner),
          patrolId: 'me',
        );

    test(
      'Avanza ACEPTAR → EN CAMINO → LLEGUÉ → CONCLUIR para la unidad asignada',
      () {
        expect(stepFor(IncidentStatus.reportado), DispatchStep.accept);
        expect(
          stepFor(IncidentStatus.asignado, owner: 'me'),
          DispatchStep.onTheWay,
        );
        expect(
          stepFor(IncidentStatus.enCamino, owner: 'me'),
          DispatchStep.arrived,
        );
        expect(
          stepFor(IncidentStatus.enLugar, owner: 'me'),
          DispatchStep.conclude,
        );
      },
    );

    test('Sin acción si lo atiende otra unidad o ya está cerrado', () {
      expect(
        stepFor(IncidentStatus.asignado, owner: 'other'),
        DispatchStep.none,
      );
      expect(
        stepFor(IncidentStatus.enLugar, owner: 'other'),
        DispatchStep.none,
      );
      expect(stepFor(IncidentStatus.resuelto, owner: 'me'), DispatchStep.none);
      expect(stepFor(IncidentStatus.cancelado), DispatchStep.none);
    });
  });

  group('ResolutionOutcome', () {
    test('La nota incluye el resultado y el detalle opcional', () {
      expect(
        ResolutionOutcome.detenido.buildNote('  Placa ABC-123 '),
        '[Detenido] ${ResolutionOutcome.detenido.note} Placa ABC-123',
      );
    });

    test('Sin detalle la nota queda solo con el resultado', () {
      expect(
        ResolutionOutcome.falsaAlarma.buildNote(''),
        '[Falsa alarma] ${ResolutionOutcome.falsaAlarma.note}',
      );
      expect(
        ResolutionOutcome.disuelto.buildNote(null),
        startsWith('[Disuelto]'),
      );
    });
  });
}
