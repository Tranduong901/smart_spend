import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/repositories/exchange_rate_repository.dart';
import 'package:smart_spend/widgets/balance_card.dart';
import 'package:smart_spend/widgets/exchange_rate_card.dart';
import 'package:smart_spend/widgets/recent_transactions_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ExchangeRateRepository _exchangeRateRepository =
      ExchangeRateRepository();
  double? _usdToVndRate;
  String? _exchangeError;

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

  @override
  void initState() {
    super.initState();
    _loadExchangeRate();
  }

  Future<void> _loadExchangeRate() async {
    try {
      final rate = await _exchangeRateRepository.getUsdToVndRate();
      if (!mounted) {
        return;
      }

      setState(() {
        _usdToVndRate = rate;
        _exchangeError = null;
      });
    } on ExchangeRateException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _exchangeError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _exchangeError = 'Không thể tải tỷ giá lúc này. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final transactions = expenseProvider.transactions;

    final recentTransactions = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExchangeRateCard(
            rate: _usdToVndRate,
            errorMessage: _exchangeError,
            onRefresh: _loadExchangeRate,
          ),
          const SizedBox(height: 8),
          BalanceCard(
            totalBalance: expenseProvider.calculateTotalBalance(),
            startingBalance: expenseProvider.startingBalance,
            onEditStartingBalance: () => _editStartingBalance(context),
          ),
          const SizedBox(height: 16),
          RecentTransactionsList(
            transactions: recentTransactions.take(5).toList(),
          ),
        ],
      ),
    );
  }
}
