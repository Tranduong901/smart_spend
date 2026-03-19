import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/widgets/category_breakdown.dart';
import 'package:smart_spend/widgets/expense_pie_chart.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<ExpenseProvider>().transactions;
    final now = DateTime.now();
    final currentMonthTransactions = transactions
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .toList();

    final previousMonthDate = DateTime(now.year, now.month - 1, 1);
    final previousMonthTransactions = transactions
        .where(
          (tx) =>
              tx.date.year == previousMonthDate.year &&
              tx.date.month == previousMonthDate.month,
        )
        .toList();

    final currentExpense = currentMonthTransactions
        .where((tx) => !tx.isIncome)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final previousExpense = previousMonthTransactions
        .where((tx) => !tx.isIncome)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final changePercent = _calculateChangePercent(
      currentValue: currentExpense,
      previousValue: previousExpense,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExpenseChangeCard(
            currentExpense: currentExpense,
            previousExpense: previousExpense,
            changePercent: changePercent,
          ),
          const SizedBox(height: 16),
          ExpensePieChart(transactions: currentMonthTransactions),
          const SizedBox(height: 16),
          CategoryBreakdown(transactions: currentMonthTransactions),
        ],
      ),
    );
  }

  double _calculateChangePercent({
    required double currentValue,
    required double previousValue,
  }) {
    if (previousValue == 0) {
      return currentValue > 0 ? 100 : 0;
    }
    return ((currentValue - previousValue) / previousValue) * 100;
  }
}

class _ExpenseChangeCard extends StatelessWidget {
  const _ExpenseChangeCard({
    required this.currentExpense,
    required this.previousExpense,
    required this.changePercent,
  });

  final double currentExpense;
  final double previousExpense;
  final double changePercent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncrease = changePercent > 0;
    final isStable = changePercent == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biến động chi tiêu tháng này',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Tháng này: ${_formatCurrency(currentExpense)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Tháng trước: ${_formatCurrency(previousExpense)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  isStable
                      ? Icons.remove
                      : (isIncrease
                          ? Icons.arrow_upward
                          : Icons.arrow_downward),
                  color: isStable
                      ? colorScheme.outline
                      : (isIncrease ? colorScheme.error : Colors.green),
                ),
                const SizedBox(width: 6),
                Text(
                  isStable
                      ? 'Không đổi so với tháng trước'
                      : '${isIncrease ? 'Tăng' : 'Giảm'} ${changePercent.abs().toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isStable
                            ? colorScheme.outline
                            : (isIncrease ? colorScheme.error : Colors.green),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    final text = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final indexFromEnd = text.length - i;
      buffer.write(text[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return '$buffer ₫';
  }
}
