import 'package:flutter/material.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/widgets/transaction_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '5 giao dịch gần nhất',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Text('Chưa có giao dịch nào.')
            else
              ...transactions.map(
                (tx) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransactionTile(transaction: tx),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
