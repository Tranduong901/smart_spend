import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/widgets/history_filter_bar.dart';
import 'package:smart_spend/widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  String _searchQuery = '';

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
              tx.date.month == _selectedMonth &&
              tx.date.year == effectiveYear &&
              (_searchQuery.isEmpty ||
                  tx.categoryName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  tx.note.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  tx.title.toLowerCase().contains(_searchQuery.toLowerCase())),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 12,
              children: [
                // Search field
                SearchBar(
                  hintText: 'Tìm theo danh mục, ghi chú, tiêu đề...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  leading: const Icon(Icons.search),
                  trailing: _searchQuery.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ),
                        ]
                      : null,
                ),
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
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Không có giao dịch trong tháng này.'
                          : 'Không tìm thấy giao dịch phù hợp.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemBuilder: (context, index) => TransactionTile(
                      transaction: filtered[index],
                      showDelete: true,
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: filtered.length,
                  ),
          ),
        ],
      ),
    );
  }
}
