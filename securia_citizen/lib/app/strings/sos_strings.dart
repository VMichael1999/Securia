/// Textos del flujo de emergencia del ciudadano (SOS inmediato y reporte con detalle).
///
/// Frases cortas, en segunda persona y sin jerga: se leen con miedo y de reojo.
class SosStrings {
  SosStrings._();

  // Botón SOS
  static const String sosLabel = 'SOS';
  static const String sosHoldHint = 'Mantén presionado';
  static const String sosKeepHolding = 'Sigue presionando';
  static const String sosSending = 'Enviando…';
  static String sosSendsIn(String seconds) =>
      'Se envía en $seconds s con tu ubicación. Suelta para cancelar.';
  static const String sosSemantics =
      'Botón SOS. Mantén presionado un segundo y medio para pedir ayuda';
  static const String sosSentAnnouncement =
      'Alerta enviada. La policía tiene tu ubicación.';

  // Ubicación
  static const String locating = 'Buscando tu ubicación…';
  static String accuracy(int meters) => '±$meters m';
  static String nearbyReports(int count) => count == 1
      ? '1 reporte cerca en las últimas 2 h'
      : '$count reportes cerca en las últimas 2 h';
  static const String noNearbyReports = 'Sin reportes cerca en las últimas 2 h';
  static const String impreciseTitle = 'Tu ubicación es imprecisa';
  static String impreciseBody(String age, int meters) =>
      'La última es de $age, con un margen de ±$meters m. El SOS igual funciona.';
  static const String impreciseAction = 'Activar ubicación precisa';
  static const String deniedTitle = 'Sin permiso de ubicación';
  static const String deniedBody =
      'El SOS igual funciona, pero la patrulla no sabrá dónde estás. Llama al 105 y di tu dirección.';
  static const String deniedAction = 'Dar permiso';
  static const String disabledTitle = 'El GPS está apagado';
  static const String disabledBody =
      'El SOS igual funciona, pero sin tu ubicación exacta. Llama al 105 y di tu dirección.';
  static const String disabledAction = 'Encender GPS';
  static String agoMinutes(int minutes) =>
      minutes <= 1 ? 'hace 1 min' : 'hace $minutes min';
  static const String recenter = 'Centrar en mi ubicación';

  // Reporte con detalle
  static const String reportButton = 'Reportar incidente';
  static const String reportTitle = 'Reportar incidente';
  static const String reportSubtitle =
      'Elige qué pasa. La foto y lo que viste son opcionales.';
  static const String reportStepType = '¿Qué está pasando?';
  static const String reportStepPhoto = 'Foto (opcional)';
  static const String reportStepObservation = 'Qué viste (opcional)';
  static const String reportChooseType = 'Elige qué está pasando';
  static String reportSendType(String type) =>
      'Enviar reporte de ${type.toLowerCase()}';
  static String reportSendsFrom(String accuracy) =>
      'Sale con tu ubicación actual · $accuracy';
  static const String reportSendsWithoutFix =
      'Sale con tu última ubicación conocida';

  // Seguimiento posterior al SOS inmediato
  static const String followUpTitle = 'Alerta enviada';
  static const String followUpSubtitle =
      'La policía ya tiene tu ubicación. Si puedes, dinos qué pasa:';
  static const String followUpSkip = 'Ahora no';

  // Panel de seguimiento de la alerta
  static const String stepSent = 'Enviada';
  static const String stepAssigned = 'Asignada';
  static const String stepOnTheWay = 'En camino';
  static const String stepOnSite = 'En lugar';
  static String activeSince(String time) => 'Tu alerta está activa desde $time';
  static const String trackerSearching = 'Buscando la patrulla más cercana';
  static const String trackerAssigned = 'Una patrulla tomó tu alerta';
  static String trackerArrivesIn(int minutes) =>
      'La patrulla llega en $minutes min';
  static const String trackerOnSite = 'La patrulla llegó';
  static String trackerUnit(String unit, String officer, String distance) =>
      '$unit · $officer · a $distance';
  static String trackerUnitNoDistance(String unit, String officer) =>
      '$unit · $officer';
  static const String call105 = 'Llamar 105';
  static const String addDetails = 'Detalles';
  static const String cancelAlert = 'Cancelar alerta';

  // Confirmación de cancelación
  static const String cancelTitle = '¿Cancelar la alerta?';
  static const String cancelBody =
      'La patrulla dejará de venir. Hazlo solo si ya estás a salvo o fue un error.';
  static const String cancelConfirm = 'Sí, cancelar';
  static const String cancelKeep = 'Mantener alerta';
  static const String backBlocked =
      'Tu alerta sigue activa. Para cancelarla usa “Cancelar alerta”.';

  // Agregar detalles
  static const String detailsTitle = 'Agregar detalles';
  static const String detailsSubtitle =
      'Opcional. Ayuda a la patrulla a reconocer la situación.';
  static const String detailsHint =
      'Ej.: dos sujetos en moto negra, polo rojo…';
  static const String detailsCamera = 'Cámara';
  static const String detailsGallery = 'Galería';
  static const String detailsPhotoAttached = 'Foto adjunta';
  static const String detailsRemovePhoto = 'Quitar foto';
  static const String detailsSend = 'Enviar detalles';
  static const String simulatedPhoto = 'simulated_evidence_photo';

  // Mensajes
  static const String alertSentSnack =
      'Reporte enviado. Las patrullas cercanas ya lo ven.';
  static const String detailsSentSnack = 'La patrulla ya tiene tus detalles.';
  static const String callUnavailable =
      'Este teléfono no puede llamar. Marca 105 desde otro.';

  // Marcadores
  static String incidentMarker(String type, String time) =>
      '$type, reportado a las $time';
  static const String yourLocation = 'Tu ubicación';

  // Llamadas
  static const String policeNumber = '105';
}
