import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/providers/expense_provider.dart';

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({
    required this.transactions,
    super.key,
  });

  final List<Transaction> transactions;

  Map<String, double> _calculateCategoryTotals(List<Transaction> expenses) {
    final totals = <String, double>{};
    final uniqueCategories = expenses
        .where((tx) => !tx.isIncome)
        .map((tx) => tx.categoryName)
        .toSet();

    for (final category in uniqueCategories) {
      totals[category] = expenses
          .where((tx) => tx.categoryName == category && !tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
    }
    return totals;
  }

  double _calculateTotalExpenses() {
    return transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = _calculateTotalExpenses();
    final colorScheme = Theme.of(context).colorScheme;

    if (totalExpenses == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Không có chi tiêu để hiển thị',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total spending overview
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng chi tiêu',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₫${totalExpenses.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Category breakdown list
          Text(
            'Chi tiêu theo danh mục',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Consumer<ExpenseProvider>(
            builder: (context, provider, _) {
              final categoryTotals = _calculateCategoryTotals(transactions);

              return Column(
                children: [
                  ...categoryTotals.entries.map((entry) {
                    final categoryName = entry.key;
                    final amount = entry.value;
                    final percentage =
                        totalExpenses > 0 ? (amount / totalExpenses) : 0.0;

                    // Get category object from provider
                    final category = provider.expenseCategories.firstWhere(
                      (c) => c.name == categoryName,
                      orElse: () => provider.expenseCategories.first,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: category.color
                                        .withAlpha((0.2 * 255).toInt()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        categoryName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(percentage * 100).toStringAsFixed(1)}% của tổng',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: colorScheme.outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₫${amount.toStringAsFixed(0)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: category.color,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentage,
                                minHeight: 6,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  category.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
