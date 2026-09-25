import 'package:flutter_test/flutter_test.dart';
import 'package:securia_citizen/app/injection.dart';
import 'package:securia_citizen/app/securia_citizen_app.dart';

void main() {
  setUp(() {
    setupCitizenDependencies();
  });

  testWidgets('Securia Citizen smoke test launches login view', (WidgetTester tester) async {
    await tester.pumpWidget(const SecuriaCitizenApp());
    await tester.pumpAndSettle();

    // Verifica que el login contenga el título Securia y los campos
    expect(find.text('Securia'), findsOneWidget);
    expect(find.text('Documento Nacional de Identidad (DNI)'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
