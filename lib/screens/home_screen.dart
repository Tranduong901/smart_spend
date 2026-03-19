import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/screens/add_transaction_screen.dart';
import 'package:smart_spend/widgets/balance_card.dart';
import 'package:smart_spend/widgets/history_filter_bar.dart';
import 'package:smart_spend/widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<void> _editStartingBalance(BuildContext context) async {
    final provider = context.read<ExpenseProvider>();
    final controller = TextEditingController(
      text: provider.startingBalance.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nhập số dư ban đầu'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Ví dụ: 15000000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (!mounted || result == null || result < 0) {
      return;
    }

    await provider.setStartingBalance(result);
  }

  void _openEditTransaction(Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: AddTransactionScreen(transaction: transaction),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final transactions = expenseProvider.transactions;

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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 0),
          BalanceCard(
            totalBalance: expenseProvider.calculateTotalBalance(),
            startingBalance: expenseProvider.startingBalance,
            onEditStartingBalance: () => _editStartingBalance(context),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'Không có giao dịch trong tháng này.'
                    : 'Không tìm thấy giao dịch phù hợp.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          else
            ...filtered.map(
              (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TransactionTile(
                  transaction: transaction,
                  showDelete: true,
                  onEdit: () => _openEditTransaction(transaction),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
