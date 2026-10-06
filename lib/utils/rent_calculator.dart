import '../models/tenant.dart';

class RentInfo {
  final DateTime nextDate;   // the current/next due date on the fixed schedule
  final int daysLeft;        // 0 once the due date has passed
  final int daysOverdue;     // 0 until the due date has passed
  final bool overdue;
  final double amountPaid;      // paid so far toward the current cycle
  final double amountRemaining; // still owed for the current cycle

  RentInfo({
    required this.nextDate,
    required this.daysLeft,
    required this.daysOverdue,
    required this.overdue,
    required this.amountPaid,
    required this.amountRemaining,
  });
}

class RentCalculator {
  /// Adds [months] to [date], clamping the day to the last valid day of the
  /// target month (e.g. 31 Jan + 1 month -> 28/29 Feb, not 3 Mar).
  static DateTime addMonths(DateTime date, int months) {
    final totalMonth = date.month - 1 + months;
    final year = date.year + (totalMonth ~/ 12);
    final month = (totalMonth % 12) + 1;
    final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : date.day;
    return DateTime(year, month, day);
  }

  static DateTime parseDate(String yyyyMMdd) {
    final parts = yyyyMMdd.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static String formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// There is only ever ONE due date in play at a time: days-left counts
  /// down to it, and once it passes, days-overdue starts counting up from
  /// zero. The schedule only advances (see AppState.addPayment) once a
  /// cycle is fully paid off — so paying early doesn't move it forward,
  /// it just means daysLeft naturally includes the leftover days of the
  /// current cycle plus the following interval.
  static RentInfo compute(Tenant t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final interval = t.intervalMonths < 1 ? 1 : t.intervalMonths;

    final baseDate = t.lastPaidDueDate != null
        ? parseDate(t.lastPaidDueDate!)
        : parseDate(t.startDate);
    final currentDueDate = addMonths(baseDate, interval);

    final diffDays = currentDueDate.difference(today).inDays;
    int daysLeft = diffDays > 0 ? diffDays : 0;
    int daysOverdue = diffDays < 0 ? -diffDays : 0;
    bool overdue = daysOverdue > 0;

    // A payment logged against the current cycle (even partial) resets the
    // visible status to green / 0 days due, even if the due date itself
    // hasn't rolled forward yet (only full settlement advances the date).
    if (t.amountPaidThisCycle > 0 && overdue) {
      overdue = false;
      daysOverdue = 0;
    }

    final amountPaid = t.amountPaidThisCycle;
    final rawRemaining = t.rent - amountPaid;
    final amountRemaining = rawRemaining < 0 ? 0.0 : rawRemaining;

    return RentInfo(
      nextDate: currentDueDate,
      daysLeft: daysLeft,
      daysOverdue: daysOverdue,
      overdue: overdue,
      amountPaid: amountPaid,
      amountRemaining: amountRemaining,
    );
  }
}
