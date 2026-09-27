/// Textos del flujo de emergencia del ciudadano (SOS inmediato y reporte con detalle)
class SosStrings {
  SosStrings._();

  // Botón SOS
  static const String sosLabel = 'SOS';
  static const String sosHoldHint = 'Mantén presionado';
  static const String sosKeepHolding = 'Sigue presionando';
  static const String sosSending = 'ENVIANDO';
  static const String sosSemantics =
      'Botón SOS. Mantén presionado para enviar alerta de emergencia';

  // Reporte con detalle
  static const String reportButton = 'Reportar incidente';
  static const String reportTitle = 'Reportar incidente';
  static const String reportSubtitle =
      'Elige qué pasa. La foto y la observación son opcionales.';
  static const String reportStepType = '1. ¿Qué está pasando?';
  static const String reportStepPhoto = '2. Foto (opcional)';
  static const String reportStepObservation = '3. Observación (opcional)';
  static const String reportChooseType = 'Elige el tipo de incidente';
  static const String reportSend = 'Enviar reporte';

  // Seguimiento posterior al SOS inmediato
  static const String followUpTitle = 'Alerta enviada';
  static const String followUpSubtitle =
      'La policía ya tiene tu ubicación. Si puedes, dinos qué pasa:';
  static const String followUpSkip = 'Omitir';

  // Panel de seguimiento de la alerta
  static const String stepSent = 'Enviada';
  static const String stepAssigned = 'Asignada';
  static const String stepOnTheWay = 'En camino';
  static const String stepOnSite = 'En lugar';
  static const String trackerSearching = 'Buscando patrulla cercana…';
  static const String trackerAssigned = 'Patrulla asignada';
  static const String trackerOnTheWay = 'Patrulla en camino';
  static const String trackerOnSite = 'Oficial en el lugar';
  static const String trackerUnit = 'Unidad';
  static String trackerEta(int minutes) => 'Llega en ~$minutes min';
  static const String call105 = 'Llamar 105';
  static const String addDetails = 'Detalles';
  static const String cancelAlert = 'Cancelar';

  // Confirmación de cancelación
  static const String cancelTitle = '¿Cancelar la alerta?';
  static const String cancelBody =
      'La patrulla dejará de acudir. Hazlo solo si ya estás a salvo o fue un error.';
  static const String cancelConfirm = 'Sí, cancelar';
  static const String cancelKeep = 'Mantener alerta';

  // Agregar detalles
  static const String detailsTitle = 'Agregar detalles';
  static const String detailsSubtitle =
      'Opcional. Ayuda a la patrulla a identificar la situación.';
  static const String detailsHint =
      'Ej.: dos sujetos en moto negra, polo rojo…';
  static const String detailsCamera = 'Foto';
  static const String detailsGallery = 'Galería';
  static const String detailsPhotoAttached = 'Foto adjunta';
  static const String detailsSend = 'Enviar detalles';
  static const String simulatedPhoto = 'simulated_evidence_photo';

  // Mensajes
  static const String alertSentSnack =
      'Reporte enviado. Patrullas cercanas notificadas.';
  static const String detailsSentSnack = 'Detalles enviados a la patrulla.';
  static const String callUnavailable =
      'No se pudo iniciar la llamada desde este dispositivo.';

  // Llamadas
  static const String policeNumber = '105';
}
