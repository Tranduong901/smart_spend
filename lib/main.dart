import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/adapters/transaction_adapter.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/providers/auth_provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/repositories/auth_repository.dart';
import 'package:smart_spend/repositories/cloud_sync_repository.dart';
import 'package:smart_spend/repositories/local_repository.dart';
import 'package:smart_spend/screens/add_transaction_screen.dart';
import 'package:smart_spend/screens/dashboard_screen.dart';
import 'package:smart_spend/screens/history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(TransactionAdapter.adapterTypeId)) {
    Hive.registerAdapter(TransactionAdapter());
  }

  await Hive.openBox<Transaction>(LocalRepository.transactionsBoxName);

  final localRepository = LocalRepository();
  final initialTransactions = await localRepository.readTransactions();
  var isFirebaseEnabled = true;

  try {
    await Firebase.initializeApp();
  } catch (_) {
    isFirebaseEnabled = false;
  }

  final authRepository = AuthRepository(isFirebaseEnabled: isFirebaseEnabled);
  final cloudSyncRepository = CloudSyncRepository(
    localRepository: localRepository,
    isFirebaseEnabled: isFirebaseEnabled,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            localRepository: localRepository,
            cloudSyncRepository: cloudSyncRepository,
            initialTransactions: initialTransactions,
          )..syncHiveToCloud(),
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

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const AddTransactionScreen(),
      const HistoryScreen(),
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
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Thêm giao dịch',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'Lịch sử',
            ),
          ],
        ),
      ),
    );
  }
}
