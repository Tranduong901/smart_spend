import 'package:smart_spend/models/category.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/repositories/local_repository.dart';

class FakeLocalRepository extends LocalRepository {
  final List<Transaction> _transactions = [];
  final List<Category> _expenseCategories =
      List<Category>.from(expenseDefaultCategories);
  final List<Category> _incomeCategories =
      List<Category>.from(incomeDefaultCategories);
  double _startingBalance = 0;

  @override
  Future<List<Transaction>> readTransactions() async {
    final items = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    _transactions.removeWhere((t) => t.id == transaction.id);
    _transactions.add(transaction);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    _transactions.removeWhere((t) => t.id == transaction.id);
    _transactions.add(transaction);
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<Category>> getCategories({required bool isIncome}) async {
    return isIncome
        ? List<Category>.from(_incomeCategories)
        : List<Category>.from(_expenseCategories);
  }

  @override
  Future<void> saveCategories(
    List<Category> categories, {
    required bool isIncome,
  }) async {
    final target = isIncome ? _incomeCategories : _expenseCategories;
    target
      ..clear()
      ..addAll(categories);
  }

  @override
  Future<void> addCategory(Category category, {required bool isIncome}) async {
    final target = isIncome ? _incomeCategories : _expenseCategories;
    target.removeWhere((c) => c.id == category.id);
    target.add(category);
  }

  @override
  Future<double> getStartingBalance() async {
    return _startingBalance;
  }

  @override
  Future<void> saveStartingBalance(double balance) async {
    _startingBalance = balance;
  }
}
