/// Textos de la cola de despacho
class QueueStrings {
  QueueStrings._();

  static const String title = 'Cola de despacho';
  static const String subtitle = 'Por urgencia y luego distancia';
  static const String emptyTitle = 'No hay alertas pendientes';
  static const String emptyBody =
      'Cuando un ciudadano pida ayuda en tu sector aparecerá aquí.';
  static const String mine = 'Tu intervención';
  static const String cannotTake = 'No se puede tomar';
  static String urgencyAgo(String urgency, String ago) => '$urgency · $ago';
  static String rowHint(String type) => 'Ver $type en el mapa';
}
