import 'package:intl/intl.dart';
import '../../../../app/strings/history_strings.dart';

/// "Hoy 21:13", "Ayer 19:42" o "12 set · 21:13"
String formatReportDate(DateTime at, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final time = DateFormat('HH:mm').format(at);
  final sameDay =
      at.year == today.year && at.month == today.month && at.day == today.day;
  if (sameDay) return '${HistoryStrings.today} $time';
  final y = today.subtract(const Duration(days: 1));
  if (at.year == y.year && at.month == y.month && at.day == y.day) {
    return '${HistoryStrings.yesterday} $time';
  }
  return '${DateFormat('d MMM', 'es').format(at)} · $time';
}
