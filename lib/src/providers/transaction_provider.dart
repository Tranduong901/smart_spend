import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

enum Timeframe { week, month, year, all }

enum BudgetAlertLevel { normal, warning, exceeded }

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository repository;
  final List<TransactionModel> _items = [];
  bool _loading = false;
  Timeframe timeframe = Timeframe.all;

  // Budgeting
  int? monthlyBudget; // in VND

  TransactionProvider({required this.repository});

  List<TransactionModel> get items => List.unmodifiable(_items);
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    final fetched = await repository.fetchAll();
    _items
      ..clear()
      ..addAll(fetched);
    _loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    await repository.add(t);
    _items.add(t);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await repository.update(t);
    final idx = _items.indexWhere((e) => e.id == t.id);
    if (idx >= 0) _items[idx] = t;
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await repository.delete(id);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Business logic
  int calculateTotalIncome({List<TransactionModel>? source}) {
    final list = source ?? _items;
    return list
        .where((t) => t.type == TransactionType.income)
        .fold(0, (p, c) => p + c.amount);
  }

  int calculateTotalExpense({List<TransactionModel>? source}) {
    final list = source ?? _items;
    return list
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (p, c) => p + c.amount);
  }

  int calculateBalance({List<TransactionModel>? source}) {
    return calculateTotalIncome(source: source) -
        calculateTotalExpense(source: source);
  }

  // Filtering and search
  List<TransactionModel> search(String keyword) {
    final k = keyword.toLowerCase();
    return _items
        .where(
          (t) =>
              t.title.toLowerCase().contains(k) ||
              (t.note ?? '').toLowerCase().contains(k),
        )
        .toList();
  }

  List<TransactionModel> filterByCategory(String category) {
    return _items.where((t) => t.category == category).toList();
  }

  List<TransactionModel> timeframeFilter(Timeframe tf, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    DateTime start;
    switch (tf) {
      case Timeframe.week:
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case Timeframe.month:
        start = DateTime(now.year, now.month, 1);
        break;
      case Timeframe.year:
        start = DateTime(now.year, 1, 1);
        break;
      case Timeframe.all:
        start = DateTime.fromMillisecondsSinceEpoch(0);
        break;
    }
    final end = now;
    return _items
        .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
        .toList();
  }

  // Grouping by human readable date label
  Map<String, List<TransactionModel>> groupByDate(
    List<TransactionModel> source,
  ) {
    final Map<String, List<TransactionModel>> map = {};
    for (final t in source) {
      final label = _humanDateLabel(t.date);
      map.putIfAbsent(label, () => []).add(t);
    }
    return map;
  }

  String _humanDateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    if (d.year == now.year) return '${d.day}/${d.month}/${d.year}';
    return '${d.month}/${d.year}';
  }

  // Budgeting logic
  void setMonthlyBudget(int? value) {
    monthlyBudget = value;
    notifyListeners();
  }

  int currentMonthExpense({DateTime? reference}) {
    final now = reference ?? DateTime.now();
    return _items
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0, (p, c) => p + c.amount);
  }

  int remainingBudget({DateTime? reference}) {
    if (monthlyBudget == null) return 0;
    return monthlyBudget! - currentMonthExpense(reference: reference);
  }

  BudgetAlertLevel budgetAlertLevel({DateTime? reference}) {
    if (monthlyBudget == null) return BudgetAlertLevel.normal;
    final spent = currentMonthExpense(reference: reference);
    final ratio = spent / monthlyBudget!;
    if (ratio >= 1.0) return BudgetAlertLevel.exceeded;
    if (ratio >= 0.8) return BudgetAlertLevel.warning;
    return BudgetAlertLevel.normal;
  }
}
