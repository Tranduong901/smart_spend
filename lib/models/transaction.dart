import 'package:flutter/material.dart';

enum ExpenseCategory { food, transport, shopping }

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Ăn uống';
      case ExpenseCategory.transport:
        return 'Di chuyển';
      case ExpenseCategory.shopping:
        return 'Shopping';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_car_filled;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
    }
  }
}

class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryName,
    required this.date,
    required this.note,
    required this.title,
    this.imagePath,
    this.isIncome = false,
  });

  final String id;
  final String title;
  final double amount;
  final String categoryName;
  final DateTime date;
  final String note;
  final String? imagePath;
  final bool isIncome;

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryName,
    DateTime? date,
    String? note,
    String? imagePath,
    bool? isIncome,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryName: categoryName ?? this.categoryName,
      date: date ?? this.date,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
