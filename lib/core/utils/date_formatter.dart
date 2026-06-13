import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  static String formatShort(DateTime date) => DateFormat('dd MMM').format(date);

  static String formatMonth(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String formatMonthKey(DateTime date) =>
      DateFormat('yyyy-MM').format(date);

  static String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);

  static String formatFull(DateTime date) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(date);

  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    return format(date);
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  static List<DateTime> last12Months() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final month = now.month - i;
      final year = now.year + (month <= 0 ? -1 : 0);
      final adjusted = month <= 0 ? month + 12 : month;
      return DateTime(year, adjusted, 1);
    }).reversed.toList();
  }
}
