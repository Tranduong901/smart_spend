import 'package:smart_spend/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:smart_spend/models/category.dart' as category_model;
import 'package:smart_spend/repositories/local_repository.dart';
import 'package:smart_spend/models/limit.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({
    required LocalRepository localRepository,
    List<Transaction> initialTransactions = const [],
    double initialStartingBalance = 0,
  })  : _localRepository = localRepository,
        _transactions = List<Transaction>.from(initialTransactions),
        _startingBalance = initialStartingBalance,
        _expenseCategories = List<category_model.Category>.from(
            category_model.expenseDefaultCategories),
        _incomeCategories = List<category_model.Category>.from(
            category_model.incomeDefaultCategories) {
    _limits = <Limit>[];
    _monthlyBudgetLimit = 8000000.0;
  }

  final LocalRepository _localRepository;
  final List<Transaction> _transactions;
  double _startingBalance;
  late List<category_model.Category> _expenseCategories;
  late List<category_model.Category> _incomeCategories;
  late List<Limit> _limits;
  late double _monthlyBudgetLimit;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  double get startingBalance => _startingBalance;
  List<category_model.Category> get expenseCategories =>
      List.unmodifiable(_expenseCategories);
  List<category_model.Category> get incomeCategories =>
      List.unmodifiable(_incomeCategories);
  List<Limit> get limits => List.unmodifiable(_limits);
  double get monthlyBudgetLimit => _monthlyBudgetLimit;

  Future<void> addTransaction(Transaction transaction) async {
    final savedTransaction =
        await _localRepository.createTransaction(transaction);
    _transactions.insert(0, savedTransaction);
    if (savedTransaction.isIncome) {
      await addLimit(savedTransaction.title);
    }
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _localRepository.deleteTransaction(id);
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final updatedTransaction = await _localRepository.updateTransaction(
      transaction,
    );
    final index = _transactions.indexWhere((item) => item.id == transaction.id);

    if (index < 0) {
      return;
    }

    _transactions[index] = updatedTransaction;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    final loadedTransactions = await _localRepository.readTransactions();
    _transactions
      ..clear()
      ..addAll(loadedTransactions);
    notifyListeners();
  }

  double calculateTotalBalance() {
    final totalIncome = _transactions
        .where((transaction) => transaction.isIncome)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final totalExpense = _transactions
        .where((transaction) => !transaction.isIncome)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);

    return _startingBalance + totalIncome - totalExpense;
  }

  Future<void> setStartingBalance(double balance) async {
    _startingBalance = balance;
    await _localRepository.saveStartingBalance(balance);
    notifyListeners();
  }

  List<Transaction> filterByCategory(String categoryName) {
    return _transactions
        .where((transaction) => transaction.categoryName == categoryName)
        .toList();
  }

  Future<void> addExpenseCategory(category_model.Category category) async {
    if (!_expenseCategories.any((c) => c.id == category.id)) {
      _expenseCategories.add(category);
      await _localRepository.saveCategories(_expenseCategories,
          isIncome: false);
      notifyListeners();
    }
  }

  Future<void> addIncomeCategory(category_model.Category category) async {
    if (!_incomeCategories.any((c) => c.id == category.id)) {
      _incomeCategories.add(category);
      await _localRepository.saveCategories(_incomeCategories, isIncome: true);
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    final expense = await _localRepository.getCategories(isIncome: false);
    final income = await _localRepository.getCategories(isIncome: true);

    if (expense.isNotEmpty) _expenseCategories = expense;
    if (income.isNotEmpty) _incomeCategories = income;

    notifyListeners();
  }

  Future<void> loadLimits() async {
    final loaded = await _localRepository.getLimits();
    _limits = loaded.map((m) => Limit.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> loadMonthlyBudgetLimit() async {
    final value = await _localRepository.getMonthlyBudgetLimit();
    _monthlyBudgetLimit = value;
    notifyListeners();
  }

  Future<void> setMonthlyBudgetLimit(double value) async {
    _monthlyBudgetLimit = value;
    await _localRepository.saveMonthlyBudgetLimit(value);
    notifyListeners();
  }

  Future<void> addLimit(String title, {double? amount, String? tag}) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    // avoid duplicates by title (case-insensitive)
    if (_limits.any((l) => l.title.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }
    final selectedTag = tag?.trim();
    final limit = Limit(title: trimmed, tag: selectedTag, amount: amount);
    _limits.add(limit);
    await _localRepository.saveLimits(_limits.map((l) => l.toMap()).toList());

    // Also add as an expense category so it appears in the selector
    final existsByName = _expenseCategories
        .any((c) => c.name.toLowerCase() == trimmed.toLowerCase());
    if (!existsByName) {
      final id = trimmed.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '_');
      final category = category_model.Category(
        id: id,
        name: trimmed,
        isIncome: false,
        colorValue: 0xFF9C27B0,
        iconCodePoint: Icons.flag.codePoint,
      );
      await addExpenseCategory(category);
    }

    notifyListeners();
  }

  Future<void> deleteLimit(String title) async {
    _limits.removeWhere((l) => l.title == title);
    await _localRepository.saveLimits(_limits.map((l) => l.toMap()).toList());
    notifyListeners();
  }

  Future<void> updateLimitAmount(String title, double? amount) async {
    final index = _limits.indexWhere((l) => l.title == title);
    if (index < 0) return;
    _limits[index].amount = amount;
    await _localRepository.saveLimits(_limits.map((l) => l.toMap()).toList());
    notifyListeners();
  }

  Future<void> loadStartingBalance() async {
    final balance = await _localRepository.getStartingBalance();
    _startingBalance = balance;
    notifyListeners();
  }
}
