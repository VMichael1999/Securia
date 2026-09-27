import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta [child] dentro de MaterialApp + Scaffold con los providers dados.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<BlocProvider> providers = const [],
}) async {
  Widget app = MaterialApp(home: Scaffold(body: child));
  if (providers.isNotEmpty) {
    app = MultiBlocProvider(providers: providers, child: app);
  }
  await tester.pumpWidget(app);
}
