import 'dart:convert';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final int amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final String? note;
  final String? imageUrl;
  final bool isSynced;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.note,
    this.imageUrl,
    this.isSynced = true,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0) as int,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? 'Khác',
      type: (json['type'] == 'income')
          ? TransactionType.income
          : TransactionType.expense,
      note: json['note'],
      imageUrl: json['imageUrl'],
      isSynced: json['isSynced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'note': note,
      'imageUrl': imageUrl,
      'isSynced': isSynced,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
