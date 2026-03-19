import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/providers/expense_provider.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        // Get all expense categories with their totals
        final categoryTotals = <String, double>{};
        final expenses = transactions.where((tx) => !tx.isIncome).toList();

        for (final expense in expenses) {
          categoryTotals[expense.categoryName] =
              (categoryTotals[expense.categoryName] ?? 0) + expense.amount;
        }

        final total = categoryTotals.values.fold(0.0, (sum, v) => sum + v);

        final colors = [
          colorScheme.primary,
          colorScheme.secondary,
          colorScheme.tertiary,
          colorScheme.error,
          colorScheme.outline,
        ];

        final sections =
            categoryTotals.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final categoryName = entry.value.key;
          final value = entry.value.value;
          final color = colors[index % colors.length];
          return _buildSection(
            title: categoryName,
            value: value,
            color: color,
          );
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân tích chi tiêu theo hạng mục',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: total == 0
                      ? const Center(child: Text('Chưa có dữ liệu chi tiêu'))
                      : PieChart(
                          PieChartData(
                            centerSpaceRadius: 36,
                            sectionsSpace: 2,
                            sections: sections,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                ...categoryTotals.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final categoryName = entry.value.key;
                  final color = colors[index % colors.length];
                  return _LegendRow(
                    label: categoryName,
                    color: color,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  PieChartSectionData _buildSection({
    required String title,
    required double value,
    required Color color,
  }) {
    return PieChartSectionData(
      value: value,
      title: value > 0 ? title : '',
      radius: 56,
      titleStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      color: color,
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
