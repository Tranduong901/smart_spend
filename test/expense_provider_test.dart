import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/models/category.dart' as category_model;
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/providers/expense_provider.dart';

import 'helpers/fake_local_repository.dart';

void main() {
  group('ExpenseProvider', () {
    late ExpenseProvider provider;

    setUp(() {
      provider = ExpenseProvider(localRepository: FakeLocalRepository());
    });

    test('initial state is empty with zero starting balance', () {
      expect(provider.transactions, isEmpty);
      expect(provider.startingBalance, 0);
    });

    test('add/update/delete transaction works', () async {
      final tx = Transaction(
        id: '1',
        title: 'Lunch',
        amount: 100000,
        categoryName: 'Ăn uống',
        date: DateTime.now(),
        note: 'Lunch with team',
        isIncome: false,
      );

      await provider.addTransaction(tx);
      expect(provider.transactions.length, 1);
      expect(provider.transactions.first.title, 'Lunch');

      final updated = tx.copyWith(title: 'Dinner', amount: 200000);
      await provider.updateTransaction(updated);
      expect(provider.transactions.first.title, 'Dinner');
      expect(provider.transactions.first.amount, 200000);

      await provider.deleteTransaction('1');
      expect(provider.transactions, isEmpty);
    });

    test('calculateTotalBalance uses starting + income - expense', () async {
      await provider.setStartingBalance(1000000);

      await provider.addTransaction(
        Transaction(
          id: 'income-1',
          title: 'Salary',
          amount: 500000,
          categoryName: 'Lương',
          date: DateTime.now(),
          note: '',
          isIncome: true,
        ),
      );

      await provider.addTransaction(
        Transaction(
          id: 'expense-1',
          title: 'Food',
          amount: 200000,
          categoryName: 'Ăn uống',
          date: DateTime.now(),
          note: '',
          isIncome: false,
        ),
      );

      expect(provider.calculateTotalBalance(), 1300000);
    });

    test('filterByCategory returns matching transactions', () async {
      await provider.addTransaction(
        Transaction(
          id: '1',
          title: 'Lunch',
          amount: 100000,
          categoryName: 'Ăn uống',
          date: DateTime.now(),
          note: '',
          isIncome: false,
        ),
      );

      await provider.addTransaction(
        Transaction(
          id: '2',
          title: 'Bus',
          amount: 50000,
          categoryName: 'Di chuyển',
          date: DateTime.now(),
          note: '',
          isIncome: false,
        ),
      );

      final food = provider.filterByCategory('Ăn uống');
      expect(food.length, 1);
      expect(food.first.title, 'Lunch');
    });

    test('load and add categories work for expense and income', () async {
      await provider.loadCategories();
      expect(provider.expenseCategories, isNotEmpty);
      expect(provider.incomeCategories, isNotEmpty);

      final newExpenseCategory = category_model.Category(
        id: 'custom-expense-1',
        name: 'Giải trí',
        isIncome: false,
        colorValue: 0xFF9C27B0,
        iconCodePoint: 0xe3f2,
      );

      final newIncomeCategory = category_model.Category(
        id: 'custom-income-1',
        name: 'Freelance',
        isIncome: true,
        colorValue: 0xFF4CAF50,
        iconCodePoint: 0xe227,
      );

      await provider.addExpenseCategory(newExpenseCategory);
      await provider.addIncomeCategory(newIncomeCategory);

      expect(
        provider.expenseCategories.any((c) => c.id == 'custom-expense-1'),
        isTrue,
      );
      expect(
        provider.incomeCategories.any((c) => c.id == 'custom-income-1'),
        isTrue,
      );
    });
  });
}
