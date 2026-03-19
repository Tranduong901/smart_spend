import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/screens/home_screen.dart';
import 'package:smart_spend/models/transaction.dart';
import 'helpers/fake_local_repository.dart';

void main() {
  group('HomeScreen', () {
    late ExpenseProvider mockProvider;

    setUp(() async {
      mockProvider = ExpenseProvider(localRepository: FakeLocalRepository());
      await mockProvider.loadCategories();
      await mockProvider.setStartingBalance(1000000);
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: mockProvider),
          ],
          child: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );
    }

    group('Display', () {
      testWidgets(
        'should display balance card at the top',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // Look for balance display
          expect(find.text('Số dư tổng'), findsOneWidget);
        },
      );

      testWidgets(
        'should display empty state when no transactions',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // Verify list is empty or shows empty message
          // TODO: Check for empty state widget
        },
      );

      testWidgets(
        'should display transactions in list',
        (WidgetTester tester) async {
          // Add a test transaction
          await mockProvider.addTransaction(
            Transaction(
              id: '1',
              title: 'Test Transaction',
              amount: 100000,
              categoryName: 'Ăn uống',
              date: DateTime.now(),
              note: 'Test',
              isIncome: false,
            ),
          );

          await tester.pumpWidget(createWidgetUnderTest());

          expect(find.text('Test Transaction'), findsOneWidget);
        },
      );
    });

    group('Search Functionality', () {
      setUp(() async {
        // Add multiple transactions for search testing
        await mockProvider.addTransaction(
          Transaction(
            id: '1',
            title: 'Lunch at office',
            amount: 100000,
            categoryName: 'Ăn uống',
            date: DateTime.now(),
            note: 'Cơm trưa',
            isIncome: false,
          ),
        );
        await mockProvider.addTransaction(
          Transaction(
            id: '2',
            title: 'Bus fare',
            amount: 50000,
            categoryName: 'Di chuyển',
            date: DateTime.now(),
            note: 'Đi làm',
            isIncome: false,
          ),
        );
      });

      testWidgets(
        'should filter by transaction title',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Type in search box
          // tester.enterText(find.byType(TextField), 'Lunch');
          // await tester.pumpAndSettle();

          // Verify only matching transaction is shown
          // expect(find.text('Lunch at office'), findsOneWidget);
          // expect(find.text('Bus fare'), findsNothing);
        },
      );

      testWidgets(
        'should filter by category name',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Type in search box
          // tester.enterText(find.byType(TextField), 'Di chuyển');
          // await tester.pumpAndSettle();

          // Verify only matching category is shown
          // expect(find.text('Bus fare'), findsOneWidget);
          // expect(find.text('Lunch at office'), findsNothing);
        },
      );

      testWidgets(
        'should filter by note',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Type in search box
          // tester.enterText(find.byType(TextField), 'Cơm trưa');
          // await tester.pumpAndSettle();

          // Verify only matching transaction is shown
          // expect(find.text('Lunch at office'), findsOneWidget);
          // expect(find.text('Bus fare'), findsNothing);
        },
      );

      testWidgets(
        'should be case insensitive',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Type mixed case in search
          // Verify filtering still works
        },
      );
    });

    group('Filter Functionality', () {
      testWidgets(
        'should filter by month and year',
        (WidgetTester tester) async {
          // Add transactions for different months
          final now = DateTime.now();
          final lastMonth = DateTime(now.year, now.month - 1, 1);

          await mockProvider.addTransaction(
            Transaction(
              id: '1',
              title: 'This month',
              amount: 100000,
              categoryName: 'Ăn uống',
              date: now,
              note: '',
              isIncome: false,
            ),
          );
          await mockProvider.addTransaction(
            Transaction(
              id: '2',
              title: 'Last month',
              amount: 50000,
              categoryName: 'Di chuyển',
              date: lastMonth,
              note: '',
              isIncome: false,
            ),
          );

          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Change month filter
          // Verify transactions are filtered correctly
        },
      );

      testWidgets(
        'should default to current month',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Verify default month/year is set to now
        },
      );
    });

    group('Transaction Actions', () {
      setUp(() async {
        await mockProvider.addTransaction(
          Transaction(
            id: '1',
            title: 'Test Transaction',
            amount: 100000,
            categoryName: 'Ăn uống',
            date: DateTime.now(),
            note: 'Test',
            isIncome: false,
          ),
        );
      });

      testWidgets(
        'should show edit button on transaction tile',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Look for edit (pencil) icon
          expect(find.byIcon(Icons.edit_outlined), findsWidgets);
        },
      );

      testWidgets(
        'should show delete button on transaction tile',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Look for delete (trash) icon
          expect(find.byIcon(Icons.delete_outline), findsWidgets);
        },
      );

      testWidgets(
        'should delete transaction on delete button tap',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.tap(find.byIcon(Icons.delete_outline).first);
          await tester.pumpAndSettle();

          // TODO: Tap delete button
          // Confirm deletion
          // Verify transaction is removed

          expect(mockProvider.transactions.length, equals(0));
        },
      );

      testWidgets(
        'should open edit form on edit button tap',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Tap edit button
          // Verify form screen opens with pre-filled data
        },
      );
    });

    group('Balance Display', () {
      testWidgets(
        'should display correct total balance',
        (WidgetTester tester) async {
          await mockProvider.addTransaction(
            Transaction(
              id: '1',
              title: 'Income',
              amount: 500000,
              categoryName: 'Lương',
              date: DateTime.now(),
              note: '',
              isIncome: true,
            ),
          );
          await mockProvider.addTransaction(
            Transaction(
              id: '2',
              title: 'Expense',
              amount: 200000,
              categoryName: 'Ăn uống',
              date: DateTime.now(),
              note: '',
              isIncome: false,
            ),
          );

          await tester.pumpWidget(createWidgetUnderTest());

          // Starting balance: 1000000
          // Plus income: 500000
          // Minus expense: 200000
          // Total: 1300000

          // TODO: Verify balance display shows 1300000
        },
      );

      testWidgets(
        'should show edit button for starting balance',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Look for edit button on balance card
          // expect(find.byIcon(Icons.edit), findsOneWidget);
        },
      );

      testWidgets(
        'should allow editing starting balance',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Tap edit button on balance card
          // Enter new starting balance in dialog
          // Verify balance is updated
        },
      );
    });

    group('Empty State', () {
      testWidgets(
        'should display empty message when no transactions',
        (WidgetTester tester) async {
          // Don't add any transactions
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Verify empty state is shown
        },
      );
    });
  });
}
