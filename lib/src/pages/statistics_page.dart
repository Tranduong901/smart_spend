import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/transaction_provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final stats = context.read<StatisticsProvider>();

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final monthItems = stats.filterByRange(
      txProvider.items,
      monthStart,
      monthEnd,
    );

    final categoryPercents = stats.getCategoryPercentages(
      monthItems,
      minPercent: 1.0,
    );
    final topCategories = categoryPercents.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final compare = stats.compareMonthExpense(txProvider.items, now);

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng chi tháng này',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${compare['current']} VND',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            compare['isIncrease']
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: compare['isIncrease']
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(compare['growthPercent'] as double).toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tỷ trọng theo hạng mục (Pie)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (topCategories.isEmpty)
                        const Text('Không có dữ liệu')
                      else
                        ...topCategories
                            .take(5)
                            .map(
                              (e) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(e.key),
                                trailing: Text(
                                  '${e.value.toStringAsFixed(1)}%',
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Bar Chart (Thu vs Chi)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Placeholder: implement monthly bar chart in UI'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Line Chart (Balance)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Placeholder: implement daily balance line chart in UI',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
