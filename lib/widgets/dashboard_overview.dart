import 'package:flutter/material.dart';
import '../models/transaction.dart';

/// Dashboard overview widget showing key financial statistics
class DashboardOverviewWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final int month;
  final int year;

  const DashboardOverviewWidget({
    Key? key,
    required this.transactions,
    required this.month,
    required this.year,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final topCategories = _calculateTopCategories();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Tổng Thu Nhập',
                    amount: stats['income']!,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Tổng Chi Tiêu',
                    amount: stats['expense']!,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Balance card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Số Dư Thực',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatCurrency(stats['balance']!),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: stats['balance']! >= 0 ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Additional stats
            Text(
              'Thống Kê Chi Tiết',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            _StatRow(
              label: 'Chi tiêu trung bình/ngày',
              value: _formatCurrency(stats['avgPerDay']!),
            ),
            SizedBox(height: 12),

            _StatRow(
              label: 'Số giao dịch tháng này',
              value: '${stats['count']!.toInt()} giao dịch',
            ),
            SizedBox(height: 16),

            // Top categories
            if (topCategories.isNotEmpty) ..._buildTopCategories(topCategories),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateStats() {
    double income = 0;
    double expense = 0;
    int count = 0;

    for (var tx in transactions) {
      if (tx.date.month == month && tx.date.year == year) {
        if (tx.isIncome) {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
        count++;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
      'count': count.toDouble(),
      'avgPerDay': count > 0 ? (income + expense) / 30 : 0,
    };
  }

  Map<String, double> _calculateTopCategories() {
    final categoryTotals = <String, double>{};

    for (var tx in transactions) {
      if (tx.date.month == month && tx.date.year == year && !tx.isIncome) {
        categoryTotals[tx.categoryName] =
            (categoryTotals[tx.categoryName] ?? 0) + tx.amount;
      }
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = <String, double>{};
    for (var i = 0;
        i < (sortedCategories.length > 3 ? 3 : sortedCategories.length);
        i++) {
      topCategories[sortedCategories[i].key] = sortedCategories[i].value;
    }
    return topCategories;
  }

  List<Widget> _buildTopCategories(Map<String, double> categories) {
    if (categories.isEmpty) {
      return [Text('Không có dữ liệu', style: TextStyle(color: Colors.grey))];
    }

    return [
      Text(
        'Top Danh Mục Chi Tiêu',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 12),
      ...categories.entries.map((e) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _StatRow(
              label: e.key,
              value: _formatCurrency(e.value),
            ),
          )),
    ];
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final withDots = intPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$withDots ₫';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final withDots = intPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$withDots ₫';
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
