import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class SummaryCard extends StatelessWidget {
  final int totalIncome;
  final int totalExpense;

  const SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpense;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('Tổng thu'),
                Text(
                  formatCurrency(totalIncome),
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            Column(
              children: [
                const Text('Tổng chi'),
                Text(
                  formatCurrency(totalExpense),
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            Column(
              children: [
                const Text('Số dư'),
                Text(
                  formatCurrency(balance),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
