import 'package:flutter/foundation.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/models/category.dart' as category_model;
import 'package:smart_spend/repositories/local_repository.dart';

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
            category_model.incomeDefaultCategories);

  final LocalRepository _localRepository;
  final List<Transaction> _transactions;
  double _startingBalance;
  late List<category_model.Category> _expenseCategories;
  late List<category_model.Category> _incomeCategories;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  double get startingBalance => _startingBalance;
  List<category_model.Category> get expenseCategories =>
      List.unmodifiable(_expenseCategories);
  List<category_model.Category> get incomeCategories =>
      List.unmodifiable(_incomeCategories);

  Future<void> addTransaction(Transaction transaction) async {
    final savedTransaction =
        await _localRepository.createTransaction(transaction);
    _transactions.insert(0, savedTransaction);
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

  Future<void> loadStartingBalance() async {
    final balance = await _localRepository.getStartingBalance();
    _startingBalance = balance;
    notifyListeners();
  }
}
