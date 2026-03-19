import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

/// Service for handling budget notifications and alerts
class BudgetNotificationService {
  /// Check if transaction exceeds any budget limit
  static BudgetAlert? checkBudgetExceeded({
    required Transaction transaction,
    required Budget? budget,
    required double currentSpent,
  }) {
    // Only check for expense transactions
    if (transaction.isIncome) {
      return null;
    }

    // No budget set for this category
    if (budget == null) {
      return null;
    }

    final newTotal = currentSpent + transaction.amount;
    final percentage = (newTotal / budget.limitAmount) * 100;

    // Check if exceeds limit
    if (newTotal > budget.limitAmount) {
      return BudgetAlert(
        type: BudgetAlertType.exceeded,
        categoryName: budget.categoryName,
        limitAmount: budget.limitAmount,
        currentSpent: newTotal,
        percentage: percentage,
        message:
            'Bạn đã vượt quá ngân sách cho danh mục "${budget.categoryName}"!'
            '\nNgân sách: ${_formatCurrency(budget.limitAmount)}'
            '\nĐã dùng: ${_formatCurrency(newTotal)}',
      );
    }

    // Check if approaching limit (80%)
    if (percentage >= 80) {
      return BudgetAlert(
        type: BudgetAlertType.warning,
        categoryName: budget.categoryName,
        limitAmount: budget.limitAmount,
        currentSpent: newTotal,
        percentage: percentage,
        message:
            'Bạn đang tiếp cận ngân sách cho danh mục "${budget.categoryName}"!'
            '\nNgân sách: ${_formatCurrency(budget.limitAmount)}'
            '\nĐã dùng: ${_formatCurrency(newTotal)} (${percentage.toStringAsFixed(1)}%)',
      );
    }

    return null;
  }

  /// Get all budget-related alerts for current month
  static List<BudgetAlert> getAllBudgetAlerts({
    required Map<String, Budget> budgets,
    required Map<String, double> categorySpending,
  }) {
    List<BudgetAlert> alerts = [];

    for (var entry in budgets.entries) {
      final budget = entry.value;
      final spent = categorySpending[budget.categoryName] ?? 0;
      final percentage = (spent / budget.limitAmount) * 100;

      if (spent > budget.limitAmount) {
        alerts.add(BudgetAlert(
          type: BudgetAlertType.exceeded,
          categoryName: budget.categoryName,
          limitAmount: budget.limitAmount,
          currentSpent: spent,
          percentage: percentage,
          message: 'Vượt quá ngân sách: ${budget.categoryName}',
        ));
      } else if (percentage >= 80) {
        alerts.add(BudgetAlert(
          type: BudgetAlertType.warning,
          categoryName: budget.categoryName,
          limitAmount: budget.limitAmount,
          currentSpent: spent,
          percentage: percentage,
          message: 'Gần hết ngân sách: ${budget.categoryName}',
        ));
      }
    }

    return alerts;
  }

  /// Show a snackbar notification for budget alert
  static void showBudgetNotification({
    required BuildContext context,
    required BudgetAlert alert,
  }) {
    final color =
        alert.type == BudgetAlertType.exceeded ? Colors.red : Colors.orange;
    final icon = alert.type == BudgetAlertType.exceeded ? '⚠️' : '⚡';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.message.split('\n').first,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (alert.message.contains('\n'))
                    Text(
                      alert.message.split('\n').sublist(1).join('\n'),
                      style: TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 5),
      ),
    );
  }

  static String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} ₫';
  }
}

/// Model for budget alerts
class BudgetAlert {
  final BudgetAlertType type;
  final String categoryName;
  final double limitAmount;
  final double currentSpent;
  final double percentage;
  final String message;

  BudgetAlert({
    required this.type,
    required this.categoryName,
    required this.limitAmount,
    required this.currentSpent,
    required this.percentage,
    required this.message,
  });

  @override
  String toString() => 'BudgetAlert($categoryName, $type)';
}

enum BudgetAlertType {
  warning, // >= 80%
  exceeded, // > 100%
}
