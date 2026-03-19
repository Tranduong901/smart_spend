import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.startingBalance,
    required this.onEditStartingBalance,
  });

  final double totalBalance;
  final double startingBalance;
  final VoidCallback onEditStartingBalance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Số dư tổng',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onEditStartingBalance,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Chỉnh số dư ban đầu',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Số dư ban đầu: ${_formatCurrency(startingBalance)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(totalBalance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
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
