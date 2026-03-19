import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/models/category.dart';

class LocalRepository {
  static const String transactionsBoxName = 'transactions_box';
  static const String categoriesExpenseBoxName = 'categories_expense_box';
  static const String categoriesIncomeBoxName = 'categories_income_box';
  static const String preferencesBoxName = 'preferences_box';
  static const String startingBalanceKey = 'starting_balance';

  Box<Transaction> get _transactionsBox =>
      Hive.box<Transaction>(transactionsBoxName);

  Box<Category> get _expenseCategoriesBox =>
      Hive.box<Category>(categoriesExpenseBoxName);

  Box<Category> get _incomeCategoriesBox =>
      Hive.box<Category>(categoriesIncomeBoxName);

  Box<dynamic> get _preferencesBox => Hive.box<dynamic>(preferencesBoxName);

  Future<List<Transaction>> readTransactions() async {
    final transactions = _transactionsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    final transactionToSave = await _normalizeReceiptPath(transaction);
    await _transactionsBox.put(transactionToSave.id, transactionToSave);
    return transactionToSave;
  }

  Future<Transaction> updateTransaction(Transaction transaction) async {
    final transactionToSave = await _normalizeReceiptPath(transaction);
    await _transactionsBox.put(transactionToSave.id, transactionToSave);
    return transactionToSave;
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  Future<Transaction> _normalizeReceiptPath(Transaction transaction) async {
    final sourcePath = transaction.imagePath;

    if (sourcePath == null || sourcePath.trim().isEmpty) {
      return transaction;
    }

    final storedPath = await _persistReceiptImage(sourcePath);
    return transaction.copyWith(imagePath: storedPath ?? sourcePath);
  }

  Future<String?> _persistReceiptImage(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      return sourcePath;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final receiptDirectory = Directory(path.join(appDir.path, 'receipts'));
    if (!receiptDirectory.existsSync()) {
      await receiptDirectory.create(recursive: true);
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourcePath)}';
    final destinationFile = File(path.join(receiptDirectory.path, fileName));
    final copiedFile = await sourceFile.copy(destinationFile.path);
    return copiedFile.path;
  }

  // Categories management
  Future<List<Category>> getCategories({required bool isIncome}) async {
    final box = isIncome ? _incomeCategoriesBox : _expenseCategoriesBox;
    final categories = box.values.toList();

    // If no categories saved, use defaults
    if (categories.isEmpty) {
      final defaults =
          isIncome ? incomeDefaultCategories : expenseDefaultCategories;
      await saveCategories(defaults, isIncome: isIncome);
      return defaults;
    }

    return categories;
  }

  Future<void> saveCategories(List<Category> categories,
      {required bool isIncome}) async {
    final box = isIncome ? _incomeCategoriesBox : _expenseCategoriesBox;
    await box.clear();
    for (final category in categories) {
      await box.put(category.id, category);
    }
  }

  Future<void> addCategory(Category category, {required bool isIncome}) async {
    final box = isIncome ? _incomeCategoriesBox : _expenseCategoriesBox;
    await box.put(category.id, category);
  }

  // Starting balance management
  Future<double> getStartingBalance() async {
    return _preferencesBox.get(startingBalanceKey, defaultValue: 0.0) as double;
  }

  Future<void> saveStartingBalance(double balance) async {
    await _preferencesBox.put(startingBalanceKey, balance);
  }
}
