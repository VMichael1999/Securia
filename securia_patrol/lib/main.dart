import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/injection.dart';
import 'app/securia_patrol_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización para formatos de fecha y hora
  await initializeDateFormatting('es', null);

  // Inyección de dependencias y servicios tácticos
  setupPatrolDependencies();

  runApp(const SecuriaPatrolApp());
}
