import '../models/transaction_model.dart';

/// Map transactions into aggregated values per category suitable for charts.
Map<String, double> aggregateByCategory(List<TransactionModel> items) {
  final Map<String, double> result = {};
  for (final t in items) {
    final k = t.category;
    result[k] = (result[k] ?? 0) + (t.amount.abs().toDouble());
  }
  return result;
}

/// Filter transactions by date range
List<TransactionModel> filterByRange(
  List<TransactionModel> items,
  DateTime start,
  DateTime end,
) {
  return items
      .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
      .toList();
}
