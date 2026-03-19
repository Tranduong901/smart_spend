import '../models/transaction_model.dart';
import '../local/local_service.dart';
import 'transaction_repository.dart';

class LocalTransactionRepository implements TransactionRepository {
  @override
  Future<void> add(TransactionModel t) async {
    await LocalService.addTransaction(t);
  }

  @override
  Future<void> delete(String id) async {
    await LocalService.deleteTransaction(id);
  }

  @override
  Future<List<TransactionModel>> fetchAll() async {
    return LocalService.fetchAllTransactions();
  }

  @override
  Future<void> update(TransactionModel t) async {
    await LocalService.updateTransaction(t);
  }

  Future<List<TransactionModel>> getByMonth(int month, int year) async {
    return LocalService.getTransactionsByMonth(month, year);
  }

  Future<List<TransactionModel>> getByCategory(String category) async {
    return LocalService.getTransactionsByCategory(category);
  }

  Future<List<TransactionModel>> getPaged({
    int offset = 0,
    int limit = 20,
  }) async {
    return LocalService.getPagedTransactions(offset: offset, limit: limit);
  }

  Future<List<TransactionModel>> getUnsynced() async {
    return LocalService.getUnsynced();
  }
}
