import 'package:flutter_test/flutter_test.dart';
import 'package:securia_patrol/app/injection.dart';
import 'package:securia_patrol/app/securia_patrol_app.dart';

void main() {
  setUp(() {
    setupPatrolDependencies();
  });

  testWidgets('Securia Patrol smoke test launches shift check-in view', (WidgetTester tester) async {
    await tester.pumpWidget(const SecuriaPatrolApp());
    await tester.pumpAndSettle();

    // Verifica que la pantalla de inicio de guardia contenga el título y controles
    expect(find.text('SECURIA PATROL'), findsOneWidget);
    expect(find.text('Selección de Unidad de Patrullaje'), findsOneWidget);
    expect(find.text('INICIAR GUARDIA Y CONECTAR RADAR'), findsOneWidget);
  });
}
