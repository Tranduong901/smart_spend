import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/widgets/history_filter_bar.dart';
import 'package:smart_spend/widgets/transaction_tile.dart';
import 'package:smart_spend/widgets/category_breakdown.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<ExpenseProvider>().transactions;

    final years = {
      ...transactions.map((tx) => tx.date.year),
      DateTime.now().year,
    }.toList()
      ..sort();

    final effectiveYear =
        years.contains(_selectedYear) ? _selectedYear : years.last;

    final filtered = transactions
        .where(
          (tx) =>
              tx.date.month == _selectedMonth && tx.date.year == effectiveYear,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            // Filter bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  HistoryFilterBar(
                    selectedMonth: _selectedMonth,
                    selectedYear: effectiveYear,
                    years: years,
                    onMonthChanged: (month) {
                      setState(() {
                        _selectedMonth = month;
                      });
                    },
                    onYearChanged: (year) {
                      setState(() {
                        _selectedYear = year;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.list),
                        text: 'Giao dịch',
                      ),
                      Tab(
                        icon: Icon(Icons.pie_chart),
                        text: 'Phân chia tiêu',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Transaction list
                  filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Không có giao dịch trong tháng này.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemBuilder: (context, index) => TransactionTile(
                            transaction: filtered[index],
                            showDelete: true,
                          ),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemCount: filtered.length,
                        ),
                  // Tab 2: Category breakdown
                  CategoryBreakdown(transactions: filtered),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
