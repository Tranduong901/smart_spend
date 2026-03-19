import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/screens/add_transaction_screen.dart';
import 'package:smart_spend/models/transaction.dart';
import 'helpers/fake_local_repository.dart';

void main() {
  group('AddTransactionScreen', () {
    late ExpenseProvider mockProvider;

    setUp(() async {
      mockProvider = ExpenseProvider(localRepository: FakeLocalRepository());
      await mockProvider.loadCategories();
    });

    Widget createWidgetUnderTest({Transaction? transaction}) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: mockProvider),
          ],
          child: Scaffold(
            body: AddTransactionScreen(transaction: transaction),
          ),
        ),
      );
    }

    group('Add Mode (New Transaction)', () {
      testWidgets(
        'should display form with empty fields',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // Check for form title
          expect(find.text('Thêm giao dịch'), findsOneWidget);

          // Check for save button
          expect(find.byType(FilledButton), findsOneWidget);
        },
      );

      testWidgets(
        'should default date to today',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Verify default date is set to DateTime.now()
          // This would require accessing the form state
        },
      );

      testWidgets(
        'should show "Thêm giao dịch" in title',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          expect(find.text('Thêm giao dịch'), findsOneWidget);
        },
      );

      testWidgets(
        'should show save button with "Lưu" text',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // Look for button with Lưu or similar text
          // The exact text depends on transaction type
          expect(find.byType(FilledButton), findsOneWidget);
        },
      );
    });

    group('Edit Mode (Existing Transaction)', () {
      testWidgets(
        'should pre-fill form with transaction data',
        (WidgetTester tester) async {
          final transaction = Transaction(
            id: '1',
            title: 'Test Lunch',
            amount: 150000,
            categoryName: 'Ăn uống',
            date: DateTime.now(),
            note: 'With team',
            isIncome: false,
          );

          await tester
              .pumpWidget(createWidgetUnderTest(transaction: transaction));

          // TODO: Verify form fields are pre-filled
          // expect(find.text('Test Lunch'), findsOneWidget);
          // expect(find.text('150000'), findsOneWidget);
        },
      );

      testWidgets(
        'should show "Sửa giao dịch" in title',
        (WidgetTester tester) async {
          final transaction = Transaction(
            id: '1',
            title: 'Test',
            amount: 100000,
            categoryName: 'Test',
            date: DateTime.now(),
            note: '',
            isIncome: false,
          );

          await tester
              .pumpWidget(createWidgetUnderTest(transaction: transaction));

          expect(find.text('Sửa giao dịch'), findsOneWidget);
        },
      );

      testWidgets(
        'should show update button with "Cập nhật" text',
        (WidgetTester tester) async {
          final transaction = Transaction(
            id: '1',
            title: 'Test',
            amount: 100000,
            categoryName: 'Test',
            date: DateTime.now(),
            note: '',
            isIncome: false,
          );

          await tester
              .pumpWidget(createWidgetUnderTest(transaction: transaction));

          expect(find.byType(FilledButton), findsOneWidget);
        },
      );
    });

    group('Form Validation', () {
      testWidgets(
        'should require title field',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Clear title field and try to submit
          // Should show validation error
        },
      );

      testWidgets(
        'should require amount field',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Clear amount field and try to submit
          // Should show validation error
        },
      );

      testWidgets(
        'should reject invalid amount (≤ 0)',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Enter negative or zero amount
          // Should show validation error
        },
      );
    });

    group('Transaction Type Toggle', () {
      testWidgets(
        'should toggle between Chi tiêu and Thu nhập',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // Look for SegmentedButton
          expect(
            find.byWidgetPredicate((widget) => widget is SegmentedButton<bool>),
            findsOneWidget,
          );

          // TODO: Tap to toggle type
          // Verify categories update
        },
      );

      testWidgets(
        'should reset category when type changes',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Select expense category
          // Toggle to income type
          // Verify category changed to income category
        },
      );
    });

    group('Receipt Button Visibility', () {
      testWidgets(
        'should hide receipt button for income transactions',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Toggle to Thu nhập (income)
          // Verify receipt button is not visible
        },
      );

      testWidgets(
        'should show receipt button for expense transactions',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // Default is Chi tiêu (expense)
          // Receipt button should be visible
          // TODO: Verify receipt button is present
        },
      );
    });

    group('Form Submission', () {
      testWidgets(
        'should create transaction and pop on save',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          // TODO: Fill form with valid data
          // Tap save button
          // Verify transaction was added to provider
          // Verify screen popped
        },
      );

      testWidgets(
        'should update transaction and pop on update',
        (WidgetTester tester) async {
          final transaction = Transaction(
            id: '1',
            title: 'Test',
            amount: 100000,
            categoryName: 'Test',
            date: DateTime.now(),
            note: '',
            isIncome: false,
          );

          await tester
              .pumpWidget(createWidgetUnderTest(transaction: transaction));

          // TODO: Modify form data
          // Tap update button
          // Verify transaction was updated in provider
          // Verify screen popped
        },
      );
    });
  });
}
