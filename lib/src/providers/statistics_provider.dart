import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class StatisticsProvider extends ChangeNotifier {
  // Group transactions by category and sum amounts (expense only)
  Map<String, int> getCategoryTotals(List<TransactionModel> list) {
    final Map<String, int> data = {};
    for (final t in list) {
      if (t.type == TransactionType.expense) {
        data[t.category] = (data[t.category] ?? 0) + t.amount;
      }
    }
    return data;
  }

  // Compute percentages for each category. Small items below `minPercent`
  // are grouped into an "Khác" bucket.
  Map<String, double> getCategoryPercentages(
    List<TransactionModel> list, {
    double minPercent = 1.0,
  }) {
    final totals = getCategoryTotals(list);
    final int totalExpense = totals.values.fold(0, (p, c) => p + c);
    if (totalExpense == 0) return {};

    final Map<String, double> percents = {};
    double otherSum = 0;
    totals.forEach((cat, value) {
      final pct = (value / totalExpense) * 100.0;
      if (pct < minPercent) {
        otherSum += value;
      } else {
        percents[cat] = pct;
      }
    });

    if (otherSum > 0) {
      percents['Khác'] = (otherSum / totalExpense) * 100.0;
    }
    return percents;
  }

  // Group transactions by day between start and end (inclusive) and return
  // a sorted list of (DateTime,dateTotal) for use in line charts.
  List<MapEntry<DateTime, int>> getDailyExpenseSeries(
    List<TransactionModel> list,
    DateTime start,
    DateTime end,
  ) {
    final Map<DateTime, int> map = {};
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    for (final t in list) {
      if (t.type != TransactionType.expense) continue;
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (d.isBefore(s) || d.isAfter(e)) continue;
      map[d] = (map[d] ?? 0) + t.amount;
    }

    final List<MapEntry<DateTime, int>> entries = [];
    for (var day = s; !day.isAfter(e); day = day.add(Duration(days: 1))) {
      entries.add(MapEntry(day, map[day] ?? 0));
    }
    return entries;
  }

  // Produce a balance series: startingBalance + cumulative (income - expense)
  // per day between start and end.
  List<MapEntry<DateTime, int>> getDailyBalanceSeries(
    List<TransactionModel> list,
    DateTime start,
    DateTime end,
    int startingBalance,
  ) {
    final series = getDailyExpenseSeries(list, start, end);

    // compute daily net (income - expense)
    final Map<DateTime, int> dailyNet = {};
    for (final t in list) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (d.isBefore(DateTime(start.year, start.month, start.day)) ||
          d.isAfter(DateTime(end.year, end.month, end.day)))
        continue;
      dailyNet[d] =
          (dailyNet[d] ?? 0) +
          (t.type == TransactionType.income ? t.amount : -t.amount);
    }

    final List<MapEntry<DateTime, int>> balance = [];
    int running = startingBalance;
    for (final entry in series) {
      final d = entry.key;
      running += (dailyNet[d] ?? 0);
      balance.add(MapEntry(d, running));
    }
    return balance;
  }

  // Compare total expense of `month` vs previous month.
  // Returns a map with current, previous, diff and growthPercent.
  Map<String, dynamic> compareMonthExpense(
    List<TransactionModel> list,
    DateTime month,
  ) {
    final currentStart = DateTime(month.year, month.month, 1);
    final currentEnd = DateTime(month.year, month.month + 1, 0);

    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final prevStart = DateTime(prevMonth.year, prevMonth.month, 1);
    final prevEnd = DateTime(prevMonth.year, prevMonth.month + 1, 0);

    int sumInRange(DateTime s, DateTime e) => list
        .where((t) => t.type == TransactionType.expense)
        .where((t) => !t.date.isBefore(s) && !t.date.isAfter(e))
        .fold(0, (p, c) => p + c.amount);

    final current = sumInRange(currentStart, currentEnd);
    final previous = sumInRange(prevStart, prevEnd);
    final diff = current - previous;
    double growth = 0.0;
    if (previous != 0) {
      growth = (diff / previous) * 100.0;
    } else if (current != 0) {
      growth = 100.0;
    }

    return {
      'current': current,
      'previous': previous,
      'difference': diff,
      'growthPercent': growth,
      'isIncrease': diff > 0,
    };
  }

  // Filter transactions by inclusive date range.
  List<TransactionModel> filterByRange(
    List<TransactionModel> list,
    DateTime start,
    DateTime end,
  ) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return list
        .where((t) => !t.date.isBefore(s) && !t.date.isAfter(e))
        .toList();
  }

  // Top N expense transactions in a given list (by amount desc)
  List<TransactionModel> getTopNExpenses(List<TransactionModel> list, int n) {
    final expenses = list.where((t) => t.type == TransactionType.expense);
    final sorted = expenses.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(n).toList();
  }

  // Generic breakdown by a provided selector (e.g., wallet selector).
  Map<String, int> breakdownByField(
    List<TransactionModel> list,
    String Function(TransactionModel) selector,
  ) {
    final Map<String, int> map = {};
    for (final t in list) {
      final key = selector(t) ?? 'Khác';
      map[key] = (map[key] ?? 0) + t.amount;
    }
    return map;
  }
}
