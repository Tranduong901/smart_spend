import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/repositories/exchange_rate_repository.dart';
import 'package:smart_spend/widgets/balance_card.dart';
import 'package:smart_spend/widgets/exchange_rate_card.dart';
import 'package:smart_spend/widgets/expense_pie_chart.dart';
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
          if (expenseProvider.syncErrorMessage != null) ...[
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        expenseProvider.syncErrorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: expenseProvider.syncHiveToCloud,
                      icon: Icon(
                        Icons.sync,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          BalanceCard(totalBalance: expenseProvider.calculateTotalBalance()),
          const SizedBox(height: 16),
          ExpensePieChart(transactions: transactions),
          const SizedBox(height: 16),
          RecentTransactionsList(
            transactions: recentTransactions.take(5).toList(),
          ),
        ],
      ),
    );
  }
}
