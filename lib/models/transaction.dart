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
    required this.category,
    required this.date,
    required this.note,
    this.imagePath,
    this.isIncome = false,
  });

  final String id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String note;
  final String? imagePath;
  final bool isIncome;

  Transaction copyWith({
    String? id,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    String? imagePath,
    bool? isIncome,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
