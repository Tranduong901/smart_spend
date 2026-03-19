import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/transaction_model.dart';
import 'widgets/summary_card.dart';
import 'widgets/transaction_card.dart';
import 'widgets/category_picker.dart';
import 'widgets/add_transaction_dialog.dart';
import 'utils/theme_manager.dart';
import 'providers/transaction_provider.dart';
import 'repositories/transaction_repository.dart';
import 'providers/statistics_provider.dart';
import 'pages/statistics_page.dart';

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(repository: InMemoryTransactionRepository())
                ..loadAll(),
        ),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeManager.modeNotifier,
        builder: (context, mode, _) {
          return MaterialApp(
            title: 'Quản lý Chi tiêu - Demo',
            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: mode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TransactionType activeType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {},
          tooltip: 'Trang chủ',
        ),
        title: const Text('Quản lý chi tiêu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const StatisticsPage())),
            tooltip: 'Thống kê',
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: ThemeManager.toggleMode,
          ),
        ],
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SummaryCard(
                  totalIncome: provider.calculateTotalIncome(),
                  totalExpense: provider.calculateTotalExpense(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeType == TransactionType.income
                              ? Colors.green
                              : null,
                        ),
                        onPressed: () =>
                            setState(() => activeType = TransactionType.income),
                        child: const Text('Thu nhập'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeType == TransactionType.expense
                              ? Colors.red
                              : null,
                        ),
                        onPressed: () => setState(
                          () => activeType = TransactionType.expense,
                        ),
                        child: const Text('Chi tiêu'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (provider.loading)
                        return const Center(child: CircularProgressIndicator());
                      final items = provider.items
                          .where((t) => t.type == activeType)
                          .toList();
                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Chưa có giao dịch nào'),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = items[index];
                          return TransactionCard(
                            transaction: t,
                            onTapCategory: () async {
                              final sel = await showModalBottomSheet<String>(
                                context: context,
                                builder: (_) => const CategoryPicker(),
                              );
                              if (sel != null) {
                                final updated = TransactionModel(
                                  id: t.id,
                                  title: t.title,
                                  category: sel,
                                  amount: t.amount,
                                  date: t.date,
                                  type: t.type,
                                  note: t.note,
                                  imageUrl: t.imageUrl,
                                );
                                provider.updateTransaction(updated);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bottom-left add button
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  backgroundColor: activeType == TransactionType.income
                      ? Colors.green
                      : Colors.red,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AddTransactionDialog(type: activeType),
                  ),
                  child: Icon(
                    activeType == TransactionType.income
                        ? Icons.add
                        : Icons.add,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
