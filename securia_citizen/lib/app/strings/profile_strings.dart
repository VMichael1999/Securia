/// Textos del perfil del ciudadano
class ProfileStrings {
  ProfileStrings._();

  static const String title = 'Perfil';
  static String idLine(String dni, String phone) => 'DNI $dni · $phone';
  static const String medicalTitle = 'Ficha médica';
  static const String bloodType = 'Grupo sanguíneo';
  static const String allergies = 'Alergias';
  static const String noAllergies = 'Ninguna registrada';
  static const String medicalLocked =
      'No autorizaste guardar datos de salud. Tu ficha médica está vacía.';
  static const String addressTitle = 'Dirección registrada';
  static const String contactTitle = 'Contacto de emergencia';
  static const String call = 'Llamar';
  static const String linesTitle = 'Líneas de emergencia';
  static const String linesNote = 'Llamadas gratuitas, las 24 horas.';

  /// Centrales nacionales (el número de Serenazgo depende del distrito y
  /// queda pendiente de confirmar, por eso no se muestra)
  static const List<(String, String)> lines = [
    ('Policía Nacional', '105'),
    ('Bomberos', '116'),
    ('SAMU · ambulancia', '106'),
  ];
}
