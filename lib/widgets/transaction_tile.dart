import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/providers/expense_provider.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.showDelete = false,
  });

  final Transaction transaction;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    final date = transaction.date;
    final dateText =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        // Get the category object from provider based on categoryName
        final categories = transaction.isIncome
            ? provider.incomeCategories
            : provider.expenseCategories;
        final category = categories.firstWhere(
          (c) => c.name == transaction.categoryName,
          orElse: () => categories.isNotEmpty
              ? categories.first
              : (transaction.isIncome
                  ? provider.incomeCategories.first
                  : provider.expenseCategories.first),
        );

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          leading: CircleAvatar(
            backgroundColor: category.color,
            child: Icon(category.icon, color: Colors.white),
          ),
          title: Text(transaction.title),
          subtitle: Text('${transaction.categoryName} • $dateText'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${transaction.isIncome ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: transaction.isIncome
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (showDelete)
                IconButton(
                  onPressed: () async {
                    try {
                      await context.read<ExpenseProvider>().deleteTransaction(
                            transaction.id,
                          );
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Xóa giao dịch thất bại. Vui lòng thử lại.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Xóa giao dịch',
                ),
            ],
          ),
        );
      },
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
