import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:smart_spend/models/transaction.dart';

class LocalRepository {
  static const String transactionsBoxName = 'transactions_box';

  Box<Transaction> get _transactionsBox =>
      Hive.box<Transaction>(transactionsBoxName);

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
}
