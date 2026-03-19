import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/widgets/balance_card.dart';

void main() {
  testWidgets('BalanceCard hiển thị tiêu đề số dư',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BalanceCard(totalBalance: 15000000),
        ),
      ),
    );

    expect(find.text('Số dư tổng'), findsOneWidget);
  });
}
