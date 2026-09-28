/// Textos del inicio de guardia y de la pantalla de turno
class ShiftStrings {
  ShiftStrings._();

  // Navegación
  static const String navMap = 'Mapa';
  static const String navQueue = 'Cola';
  static const String navShift = 'Turno';
  static String queueBadge(int n) => '$n alertas pendientes';

  // Inicio de guardia
  static const String appName = 'Securia Patrulla';
  static const String loginSubtitle =
      'Inicia tu guardia para recibir las alertas de tu sector.';
  static const String unitLabel = 'Tu unidad';
  static const String cipLabel = 'CIP del efectivo';
  static const String cipHint = 'Número de CIP';
  static const String cipError =
      'Escribe tu CIP (solo números, de 6 a 9 dígitos)';
  static const String startShift = 'Iniciar guardia';
  static String coverage(String km) => 'Radio de $km';

  // Turno
  static const String dutyOn = 'Disponible';
  static String dutyOnBody(String km) => 'Recibes alertas en un radio de $km';
  static const String dutyOff = 'Fuera de servicio';
  static const String dutyOffBody = 'No recibes alertas nuevas';
  static const String dutyLocked =
      'Concluye tu intervención para cambiar de estado';
  static const String statInterventions = 'Intervenciones';
  static const String statAvgArrival = 'Llegada promedio';
  static const String statRadius = 'Radio';
  static const String statRemaining = 'Quedan de turno';
  static const String shiftLabel = 'Turno';
  static String remaining(int h, int m) =>
      '$h h ${m.toString().padLeft(2, '0')}';
  static const String location = 'Ubicación de la unidad';
  static const String endShift = 'Terminar guardia';
  static const String endShiftTitle = '¿Terminar la guardia?';
  static const String endShiftBody =
      'Tu unidad dejará de recibir alertas y volverás al inicio.';
  static const String endShiftKeep = 'Seguir de guardia';
  static const String endShiftLocked =
      'Concluye tu intervención antes de terminar la guardia';
  static const String catalog = 'Catálogo de componentes';
}
