/// Textos del flujo de despacho policial (alerta, intervención y cierre)
class DispatchStrings {
  DispatchStrings._();

  // Alerta entrante a pantalla completa
  static const String incomingTitle = 'NUEVA ALERTA EN TU SECTOR';
  static const String incomingAccept = 'ACEPTAR';
  static const String incomingIgnore = 'Ignorar';
  static const String distanceLabel = 'DISTANCIA';
  static const String etaLabel = 'LLEGADA';
  static String urgency(String label) => 'URGENCIA ${label.toUpperCase()}';
  static String minutes(int value) => '$value min';
  static const String noValue = '--';

  // Acción principal según el estado del despacho
  static const String actionAccept = 'ACEPTAR DESPACHO';
  static const String actionOnTheWay = 'EN CAMINO';
  static const String actionArrived = 'LLEGUÉ AL LUGAR';
  static const String actionConclude = 'CONCLUIR';
  static const String actionHintAccept = 'Toma el incidente para tu unidad';
  static const String actionHintOnTheWay =
      'Activa sirena y ruta de intercepción';
  static const String actionHintArrived = 'Avisa al ciudadano que llegaste';
  static const String actionHintConclude = 'Registra el resultado en un toque';
  static String takenBy(String unit) => 'Atendido por $unit';
  static const String callCitizen = 'Llamar';

  // Cierre rápido
  static const String resolveTitle = '¿Cómo terminó?';
  static const String resolveNoteHint = 'Nota adicional (opcional)';
  static const String resolveConfirm = 'CONCLUIR INTERVENCIÓN';

  // Mensajes de estado
  static String accepted(String unit) => 'Despacho aceptado · $unit';
  static String onTheWay(String unit) => '$unit en código rojo hacia el lugar';
  static const String arrived = 'En el lugar. El ciudadano fue notificado.';
  static const String concluded = 'Intervención concluida';
  static const String citizenCancelled =
      'El ciudadano canceló la alerta. Unidad liberada.';
  static const String callUnavailable = 'No se pudo iniciar la llamada.';
  static String alreadyTaken(String reason) => 'No se pudo tomar: $reason';
}
