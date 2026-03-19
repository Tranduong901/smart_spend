import '../models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> fetchAll();
  Future<void> add(TransactionModel t);
  Future<void> update(TransactionModel t);
  Future<void> delete(String id);
}

/// In-memory simple repository for demo and tests.
class InMemoryTransactionRepository implements TransactionRepository {
  final List<TransactionModel> _store = [];

  @override
  Future<void> add(TransactionModel t) async {
    _store.add(t);
  }

  @override
  Future<void> delete(String id) async {
    _store.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<TransactionModel>> fetchAll() async {
    // return copy
    return List<TransactionModel>.from(_store);
  }

  @override
  Future<void> update(TransactionModel t) async {
    final idx = _store.indexWhere((e) => e.id == t.id);
    if (idx >= 0) _store[idx] = t;
  }
}
