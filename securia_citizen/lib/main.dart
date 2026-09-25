import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/injection.dart';
import 'app/securia_citizen_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización para formateo de fechas en español
  await initializeDateFormatting('es', null);

  // Inyección de dependencias y servicios
  setupCitizenDependencies();

  runApp(const SecuriaCitizenApp());
}
