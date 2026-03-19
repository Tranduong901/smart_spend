// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quanlychitieu/main.dart';

void main() {
  testWidgets('DemoApp builds and shows main elements', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DemoApp());

    // Verify app bar title is present.
    expect(find.text('Demo Quản lý Chi tiêu'), findsOneWidget);

    // Verify FloatingActionButton exists and can be tapped.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
  });
}
