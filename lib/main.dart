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
import 'package:smart_spend/screens/limits_screen.dart';

Future<void> _seedDemoTransactionsIfNeeded(
    LocalRepository localRepository) async {
  final existing = await localRepository.readTransactions();
  final existingIds = existing.map((tx) => tx.id).toSet();

  final now = DateTime.now();
  final demoTransactions = <Transaction>[
    Transaction(
      id: 'demo_01',
      title: 'Lương tháng',
      amount: 18000000,
      categoryName: 'Lương',
      date: DateTime(now.year, now.month, 1),
      note: 'Lương cố định',
      isIncome: true,
    ),
    Transaction(
      id: 'demo_02',
      title: 'Ăn trưa văn phòng',
      amount: 55000,
      categoryName: 'Ăn uống',
      date: DateTime(now.year, now.month, 2),
      note: 'Cơm trưa',
    ),
    Transaction(
      id: 'demo_03',
      title: 'Đổ xăng',
      amount: 120000,
      categoryName: 'Di chuyển',
      date: DateTime(now.year, now.month, 3),
      note: 'Xăng xe tuần 1',
    ),
    Transaction(
      id: 'demo_04',
      title: 'Cafe gặp khách hàng',
      amount: 90000,
      categoryName: 'Ăn uống',
      date: DateTime(now.year, now.month, 4),
      note: 'Tiếp khách',
    ),
    Transaction(
      id: 'demo_05',
      title: 'Mua sách chuyên môn',
      amount: 280000,
      categoryName: 'Giáo dục',
      date: DateTime(now.year, now.month, 6),
      note: 'Sách Flutter',
    ),
    Transaction(
      id: 'demo_06',
      title: 'Freelance UI',
      amount: 3500000,
      categoryName: 'Freelance',
      date: DateTime(now.year, now.month, 7),
      note: 'Dự án phụ',
      isIncome: true,
    ),
    Transaction(
      id: 'demo_07',
      title: 'Siêu thị cuối tuần',
      amount: 640000,
      categoryName: 'Mua sắm',
      date: DateTime(now.year, now.month, 8),
      note: 'Đồ gia dụng',
    ),
    Transaction(
      id: 'demo_08',
      title: 'Điện nước',
      amount: 780000,
      categoryName: 'Hóa đơn',
      date: DateTime(now.year, now.month, 10),
      note: 'Tháng hiện tại',
    ),
    Transaction(
      id: 'demo_09',
      title: 'Khám sức khỏe định kỳ',
      amount: 450000,
      categoryName: 'Y tế',
      date: DateTime(now.year, now.month, 11),
      note: 'Bệnh viện quận',
    ),
    Transaction(
      id: 'demo_10',
      title: 'Thưởng KPI',
      amount: 2200000,
      categoryName: 'Thưởng',
      date: DateTime(now.year, now.month, 12),
      note: 'Thưởng theo quý',
      isIncome: true,
    ),
    Transaction(
      id: 'demo_11',
      title: 'Lương tháng trước',
      amount: 18000000,
      categoryName: 'Lương',
      date: DateTime(now.year, now.month - 1, 1),
      note: 'Lương cố định',
      isIncome: true,
    ),
    Transaction(
      id: 'demo_12',
      title: 'Tiền nhà',
      amount: 6500000,
      categoryName: 'Nhà ở',
      date: DateTime(now.year, now.month - 1, 3),
      note: 'Thanh toán đầu tháng',
    ),
    Transaction(
      id: 'demo_13',
      title: 'Ăn tối',
      amount: 130000,
      categoryName: 'Ăn uống',
      date: DateTime(now.year, now.month - 1, 5),
      note: 'Đi ăn cùng gia đình',
    ),
    Transaction(
      id: 'demo_14',
      title: 'Mua quần áo',
      amount: 980000,
      categoryName: 'Mua sắm',
      date: DateTime(now.year, now.month - 1, 9),
      note: 'Khuyến mãi cuối mùa',
    ),
    Transaction(
      id: 'demo_15',
      title: 'Đăng ký gym',
      amount: 600000,
      categoryName: 'Sức khỏe',
      date: DateTime(now.year, now.month - 1, 14),
      note: 'Gói 1 tháng',
    ),
    Transaction(
      id: 'demo_16',
      title: 'Lương 2 tháng trước',
      amount: 17500000,
      categoryName: 'Lương',
      date: DateTime(now.year, now.month - 2, 1),
      note: 'Lương cố định',
      isIncome: true,
    ),
    Transaction(
      id: 'demo_17',
      title: 'Đi lại công tác',
      amount: 720000,
      categoryName: 'Di chuyển',
      date: DateTime(now.year, now.month - 2, 7),
      note: 'Taxi + gửi xe',
    ),
    Transaction(
      id: 'demo_18',
      title: 'Du lịch ngắn ngày',
      amount: 2600000,
      categoryName: 'Giải trí',
      date: DateTime(now.year, now.month - 3, 15),
      note: 'Đi Vũng Tàu',
    ),
    Transaction(
      id: 'demo_19',
      title: 'Bán đồ cũ',
      amount: 1200000,
      categoryName: 'Thu khác',
      date: DateTime(now.year, now.month - 4, 10),
      note: 'Thanh lý bàn làm việc',
      isIncome: true,
    ),
    Transaction(
      id: 'demo_20',
      title: 'Học online',
      amount: 499000,
      categoryName: 'Giáo dục',
      date: DateTime(now.year, now.month - 5, 20),
      note: 'Khóa học nâng cao',
    ),
  ];

  for (final transaction in demoTransactions) {
    if (existingIds.contains(transaction.id)) {
      continue;
    }
    await localRepository.createTransaction(transaction);
  }
}

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
  await _seedDemoTransactionsIfNeeded(localRepository);
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
          )
            ..loadCategories()
            ..loadLimits()
            ..loadMonthlyBudgetLimit(),
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _openAddTransactionPage() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: AddTransactionScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const LimitsScreen(),
      const AnalysisScreen(),
    ];

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker (Quản lý chi tiêu)',
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
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 244, 231, 246),
          leading: Icon(
            Icons.home,
            color: Colors.purple.shade800,
          ),
          centerTitle: true,
          title: Text(
            'Quản lý chi tiêu',
            style: TextStyle(
              color: Colors.purple.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: IndexedStack(index: _currentIndex, children: screens),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddTransactionPage,
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
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Hạn mức',
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
