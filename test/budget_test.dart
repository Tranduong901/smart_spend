import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/models/budget.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/services/budget_notification.dart';

void main() {
  group('Budget Model', () {
    test('should create budget with correct values', () {
      final now = DateTime.now();
      final budget = Budget(
        id: '1',
        categoryName: 'Ăn uống',
        limitAmount: 1000000,
        month: 1,
        year: 2024,
        createdAt: now,
      );

      expect(budget.id, equals('1'));
      expect(budget.categoryName, equals('Ăn uống'));
      expect(budget.limitAmount, equals(1000000));
      expect(budget.month, equals(1));
      expect(budget.year, equals(2024));
      expect(budget.createdAt, equals(now));
    });

    test('should use copyWith for immutable updates', () {
      final now = DateTime.now();
      final budget = Budget(
        id: '1',
        categoryName: 'Ăn uống',
        limitAmount: 1000000,
        month: 1,
        year: 2024,
        createdAt: now,
      );

      final updated = budget.copyWith(limitAmount: 1500000);

      expect(budget.limitAmount, equals(1000000)); // Original unchanged
      expect(updated.limitAmount, equals(1500000)); // New value
      expect(updated.categoryName, equals('Ăn uống')); // Other fields preserved
    });

    test('should have proper toString representation', () {
      final budget = Budget(
        id: '1',
        categoryName: 'Ăn uống',
        limitAmount: 1000000,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      final str = budget.toString();
      expect(str, contains('Ăn uống'));
      expect(str, contains('1000000'));
    });
  });

  group('BudgetNotificationService - Budget Alerts', () {
    test('should not alert for income transactions', () {
      final budget = Budget(
        id: '1',
        categoryName: 'Lương',
        limitAmount: 10000000,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      final incomeTx = Transaction(
        id: '1',
        title: 'Salary',
        amount: 5000000,
        categoryName: 'Lương',
        date: DateTime.now(),
        note: '',
        isIncome: true,
      );

      final alert = BudgetNotificationService.checkBudgetExceeded(
        transaction: incomeTx,
        budget: budget,
        currentSpent: 0,
      );

      expect(alert, isNull);
    });

    test('should not alert if no budget set', () {
      final expenseTx = Transaction(
        id: '1',
        title: 'Lunch',
        amount: 100000,
        categoryName: 'Ăn uống',
        date: DateTime.now(),
        note: '',
        isIncome: false,
      );

      final alert = BudgetNotificationService.checkBudgetExceeded(
        transaction: expenseTx,
        budget: null,
        currentSpent: 0,
      );

      expect(alert, isNull);
    });

    test('should show warning at 80% of budget', () {
      final budget = Budget(
        id: '1',
        categoryName: 'Ăn uống',
        limitAmount: 1000000,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      final expenseTx = Transaction(
        id: '1',
        title: 'Lunch',
        amount: 200000, // 800000 + 200000 = 1000000 (80%)
        categoryName: 'Ăn uống',
        date: DateTime.now(),
        note: '',
        isIncome: false,
      );

      final alert = BudgetNotificationService.checkBudgetExceeded(
        transaction: expenseTx,
        budget: budget,
        currentSpent: 800000,
      );

      expect(alert, isNotNull);
      expect(alert!.type, equals(BudgetAlertType.warning));
      expect(alert.percentage, equals(100.0)); // 1000000 / 1000000 = 100%
    });

    test('should alert when budget exceeded', () {
      final budget = Budget(
        id: '1',
        categoryName: 'Ăn uống',
        limitAmount: 1000000,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      final expenseTx = Transaction(
        id: '1',
        title: 'Expensive meal',
        amount: 200000,
        categoryName: 'Ăn uống',
        date: DateTime.now(),
        note: '',
        isIncome: false,
      );

      final alert = BudgetNotificationService.checkBudgetExceeded(
        transaction: expenseTx,
        budget: budget,
        currentSpent: 900000, // 900000 + 200000 = 1100000 > 1000000
      );

      expect(alert, isNotNull);
      expect(alert!.type, equals(BudgetAlertType.exceeded));
      expect(alert.message, contains('vượt'));
      expect(alert.currentSpent, equals(1100000));
    });

    test('should calculate percentage correctly', () {
      final budget = Budget(
        id: '1',
        categoryName: 'Di chuyển',
        limitAmount: 500000,
        month: 1,
        year: 2024,
        createdAt: DateTime.now(),
      );

      final expenseTx = Transaction(
        id: '1',
        title: 'Taxi',
        amount: 150000,
        categoryName: 'Di chuyển',
        date: DateTime.now(),
        note: '',
        isIncome: false,
      );

      final alert = BudgetNotificationService.checkBudgetExceeded(
        transaction: expenseTx,
        budget: budget,
        currentSpent: 200000, // 200000 + 150000 = 350000 / 500000 = 70%
      );

      expect(alert, isNull); // No alert at 70%
    });
  });

  group('BudgetAlertType', () {
    test('should have warning and exceeded types', () {
      expect(BudgetAlertType.warning, isNotNull);
      expect(BudgetAlertType.exceeded, isNotNull);
    });
  });
}
