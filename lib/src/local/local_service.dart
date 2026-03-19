import 'dart:io';
// flutter foundation not needed here
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import 'adapters/transaction_adapter.dart';
import 'adapters/category_adapter.dart';

class LocalService {
  static const String _txBox = 'transactions';
  static const String _catBox = 'categories';

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryAdapter());
    await Hive.openBox<TransactionModel>(_txBox);
    await Hive.openBox<CategoryModel>(_catBox);
  }

  static Box<TransactionModel> txBox() => Hive.box<TransactionModel>(_txBox);
  static Box<CategoryModel> catBox() => Hive.box<CategoryModel>(_catBox);

  // CRUD
  static Future<void> addTransaction(TransactionModel t) async {
    final box = txBox();
    // write-ahead: put immediately
    await box.put(t.id, t);
  }

  static Future<void> updateTransaction(TransactionModel t) async {
    final box = txBox();
    await box.put(t.id, t);
  }

  static Future<void> deleteTransaction(String id) async {
    final box = txBox();
    await box.delete(id);
  }

  static List<TransactionModel> fetchAllTransactions() {
    return txBox().values.toList();
  }

  static List<TransactionModel> getTransactionsByMonth(int month, int year) {
    return txBox().values
        .where((t) => t.date.month == month && t.date.year == year)
        .toList();
  }

  static List<TransactionModel> getTransactionsByCategory(String category) {
    return txBox().values.where((t) => t.category == category).toList();
  }

  // Pagination: returns next `limit` items after offset
  static List<TransactionModel> getPagedTransactions({
    int offset = 0,
    int limit = 20,
  }) {
    final all = txBox().values.toList();
    if (offset >= all.length) return [];
    final end = (offset + limit).clamp(0, all.length);
    return all.sublist(offset, end);
  }

  // Sync flags
  static List<TransactionModel> getUnsynced() {
    return txBox().values.where((t) => !t.isSynced).toList();
  }

  static Future<void> markSynced(String id, {bool synced = true}) async {
    final box = txBox();
    final t = box.get(id);
    if (t == null) return;
    final updated = TransactionModel(
      id: t.id,
      title: t.title,
      amount: t.amount,
      date: t.date,
      category: t.category,
      type: t.type,
      note: t.note,
      imageUrl: t.imageUrl,
      isSynced: synced,
    );
    await box.put(id, updated);
  }

  // Image persistence: save bytes to file and return path
  static Future<String> persistImageBytes(
    List<int> bytes,
    String filename,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final file = File('${imagesDir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // User preferences
  static Future<SharedPreferences> prefs() async =>
      await SharedPreferences.getInstance();

  static Future<void> setLocale(String code) async {
    final p = await prefs();
    await p.setString('locale', code);
  }

  static Future<String?> getLocale() async {
    final p = await prefs();
    return p.getString('locale');
  }

  static Future<void> setHideBalance(bool hide) async {
    final p = await prefs();
    await p.setBool('hide_balance', hide);
  }

  static Future<bool> getHideBalance() async {
    final p = await prefs();
    return p.getBool('hide_balance') ?? false;
  }

  // Migration helper (very small example)
  static Future<void> migrateIfNeeded(int currentVersion) async {
    final p = await prefs();
    final stored = p.getInt('db_version') ?? 0;
    if (stored < currentVersion) {
      // Example: if upgrading from v1 to v2, ensure imageUrl field exists
      if (stored < 2) {
        final box = txBox();
        for (final key in box.keys) {
          final t = box.get(key) as TransactionModel;
          final updated = TransactionModel(
            id: t.id,
            title: t.title,
            amount: t.amount,
            date: t.date,
            category: t.category,
            type: t.type,
            note: t.note,
            imageUrl: t.imageUrl,
            isSynced: t.isSynced,
          );
          await box.put(key, updated);
        }
      }
      await p.setInt('db_version', currentVersion);
    }
  }
}
