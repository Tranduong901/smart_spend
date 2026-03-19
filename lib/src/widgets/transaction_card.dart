import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';
import '../services/color_mapper.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onTapCategory;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onTapCategory,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorMapper.colorFor(transaction.category);
    final isExpense = transaction.type == TransactionType.expense;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(isExpense ? Icons.arrow_upward : Icons.arrow_downward),
      ),
      title: Text(transaction.title),
      subtitle: GestureDetector(
        onTap: onTapCategory,
        child: Text(transaction.category, style: TextStyle(color: color)),
      ),
      trailing: Text(
        formatCurrency(transaction.amount),
        style: TextStyle(color: isExpense ? Colors.red : Colors.green),
      ),
    );
  }
}
