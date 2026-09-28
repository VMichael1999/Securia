import 'package:securia_core/securia_core.dart';

/// Textos de Mis reportes y del detalle de un reporte
class HistoryStrings {
  HistoryStrings._();

  static const String title = 'Mis reportes';
  static const String emptyTitle = 'Aún no has enviado reportes';
  static const String emptyBody =
      'Cuando pidas ayuda, aquí verás cómo terminó cada caso.';
  static const String privacy =
      'Solo tú y la unidad que te atendió ven estos reportes.';
  static const String today = 'Hoy';
  static const String yesterday = 'Ayer';
  static String resolvedBy(String unit) => 'Resuelto · $unit';
  static const String resolved = 'Resuelto';
  static const String cancelledByYou = 'Lo cancelaste tú';
  static String inProgress(String status) => 'En curso · $status';

  // Detalle
  static const String detailTitle = 'Detalle del reporte';
  static const String whatYouReported = 'Lo que reportaste';
  static const String photo = 'Foto enviada';
  static const String outcome = 'Cómo terminó';
  static const String where = 'Dónde';
  static String unitLine(String unit, String officer) => '$unit · $officer';

  /// Estado cerrado o en curso, en palabras del ciudadano
  static String outcomeOf(IncidentModel incident) => switch (incident.status) {
        IncidentStatus.resuelto => incident.assignedPatrolCode == null
            ? resolved
            : resolvedBy(incident.assignedPatrolCode!),
        IncidentStatus.cancelado => cancelledByYou,
        _ => inProgress(incident.status.label),
      };
}
