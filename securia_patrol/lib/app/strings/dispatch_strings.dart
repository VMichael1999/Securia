/// Textos del flujo de despacho policial (alerta, intervención y cierre).
///
/// Verbos de acción en tipo oración, sin MAYÚSCULAS: se leen más rápido.
class DispatchStrings {
  DispatchStrings._();

  // Alerta entrante a pantalla completa
  static const String incomingTitle = 'Nueva alerta en tu sector';
  static const String incomingAccept = 'Aceptar';
  static const String incomingIgnore = 'Ignorar';
  static String incomingIgnoreQueued(int count) =>
      count == 1
          ? 'Ignorar · hay 1 más en cola'
          : 'Ignorar · hay $count más en cola';
  static String incomingAnnouncement(
    String urgency,
    String type,
    String distance,
  ) => 'Nueva alerta ${urgency.toLowerCase()}: $type, a $distance';
  static String reportedAt(String time) => 'Reportado a las $time';
  static String sosAt(String time) => 'SOS a las $time';

  static const String distanceLabel = 'Distancia';
  static const String etaLabel = 'Llegada';
  static const String arrivalTimeLabel = 'Hora est.';
  static String minutes(int value) => '$value min';
  static const String noValue = '—';

  /// Tiempo transcurrido corto: "hace 38 s", "hace 5 min", "hace 2 h"
  static String ago(Duration elapsed) {
    if (elapsed.inMinutes < 1) {
      return 'hace ${elapsed.inSeconds.clamp(0, 59)} s';
    }
    if (elapsed.inHours < 1) return 'hace ${elapsed.inMinutes} min';
    return 'hace ${elapsed.inHours} h';
  }

  // Pasos de la intervención
  static const List<String> flowSteps = [
    'Aceptado',
    'En camino',
    'Llegué',
    'Concluir',
  ];
  static String flowProgress(int step) => 'Paso $step de 4';

  // Acción principal según el estado del despacho
  static const String actionAccept = 'Aceptar';
  static const String actionOnTheWay = 'Voy en camino';
  static const String actionArrived = 'Llegué al lugar';
  static const String actionConclude = 'Concluir intervención';
  static const String actionHintAccept = 'Toma el incidente para tu unidad';
  static const String actionHintOnTheWay =
      'Enciende la sirena y avisa al ciudadano';
  static const String actionHintArrived = 'Avisa al ciudadano que llegaste';
  static const String actionHintConclude = 'Registra cómo terminó';
  static String takenBy(String unit) => 'Atendido por $unit';
  static const String callCitizen = 'Llamar';
  static const String callCitizenHint = 'Llamar al ciudadano';
  static const String closeCard = 'Cerrar ficha';

  // Barra superior del mapa
  static const String sirenOn = 'Sirena activa';
  static const String sirenOff = 'Sirena apagada';
  static const String sirenHint = 'Toca para encender o apagar la sirena';
  static const String centerOnMe = 'Centrar en mi unidad';
  static const String centerOnTarget = 'Centrar en el incidente';
  static String unitMarker(String unit) => 'Tu unidad $unit';
  static String incidentMarker(String urgency, String type, String distance) =>
      '$type, urgencia $urgency, a $distance';

  // Cierre rápido
  static const String resolveTitle = '¿Cómo terminó?';
  static const String resolveAccepted = 'Aceptado';
  static const String resolveArrived = 'Llegada';
  static const String resolveDuration = 'Duración';
  static const String resolveNoteHint = 'Nota (opcional)';
  static const String resolveConfirm = 'Concluir intervención';
  static const String resolveChooseFirst = 'Elige cómo terminó';

  // Mensajes de estado
  static String accepted(String unit) => 'Aceptaste la alerta · $unit';
  static const String onTheWay = 'Vas en camino. El ciudadano ya lo sabe.';
  static const String arrived = 'Llegaste. El ciudadano fue notificado.';
  static const String concluded = 'Intervención concluida';
  static const String citizenCancelled =
      'El ciudadano canceló la alerta. Tu unidad quedó libre.';
  static const String callUnavailable = 'No se pudo iniciar la llamada.';
  static String alreadyTaken(String reason) => 'No se pudo tomar: $reason';
}
