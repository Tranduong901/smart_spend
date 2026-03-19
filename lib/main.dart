import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/adapters/transaction_adapter.dart';
import 'package:smart_spend/adapters/category_adapter.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/models/category.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/repositories/local_repository.dart';
import 'package:smart_spend/screens/add_transaction_screen.dart';
import 'package:smart_spend/screens/analysis_screen.dart';
import 'package:smart_spend/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(TransactionAdapter.adapterTypeId)) {
    Hive.registerAdapter(TransactionAdapter());
  }

  if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
    Hive.registerAdapter(CategoryAdapter());
  }

  await Hive.openBox<Transaction>(LocalRepository.transactionsBoxName);
  await Hive.openBox<Category>(LocalRepository.categoriesExpenseBoxName);
  await Hive.openBox<Category>(LocalRepository.categoriesIncomeBoxName);
  await Hive.openBox(LocalRepository.preferencesBoxName);

  final localRepository = LocalRepository();
  final initialTransactions = await localRepository.readTransactions();
  final initialStartingBalance = await localRepository.getStartingBalance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            localRepository: localRepository,
            initialTransactions: initialTransactions,
            initialStartingBalance: initialStartingBalance,
          )..loadCategories(),
        ),
      ],
      child: const SmartSpendApp(),
    ),
  );
}

class SmartSpendApp extends StatefulWidget {
  const SmartSpendApp({super.key});

  @override
  State<SmartSpendApp> createState() => _SmartSpendAppState();
}

class _SmartSpendAppState extends State<SmartSpendApp> {
  int _currentIndex = 0;

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: const Padding(
            padding: EdgeInsets.only(top: 16),
            child: AddTransactionScreen(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const AnalysisScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Spend',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: IndexedStack(index: _currentIndex, children: screens),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTransactionDialog,
          tooltip: 'Thêm giao dịch',
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Phân tích',
            ),
          ],
        ),
      ),
    );
  }
}
