import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_spend/models/transaction.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final foodTotal = _sumByCategory(ExpenseCategory.food);
    final transportTotal = _sumByCategory(ExpenseCategory.transport);
    final shoppingTotal = _sumByCategory(ExpenseCategory.shopping);
    final total = foodTotal + transportTotal + shoppingTotal;

    final sections = [
      _buildSection(
        title: 'Ăn uống',
        value: foodTotal,
        color: colorScheme.primary,
      ),
      _buildSection(
        title: 'Di chuyển',
        value: transportTotal,
        color: colorScheme.tertiary,
      ),
      _buildSection(
        title: 'Shopping',
        value: shoppingTotal,
        color: colorScheme.secondary,
      ),
    ];

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
            _LegendRow(label: 'Ăn uống', color: colorScheme.primary),
            _LegendRow(label: 'Di chuyển', color: colorScheme.tertiary),
            _LegendRow(label: 'Shopping', color: colorScheme.secondary),
          ],
        ),
      ),
    );
  }

  double _sumByCategory(ExpenseCategory category) {
    return transactions
        .where((tx) => tx.category == category)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
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
