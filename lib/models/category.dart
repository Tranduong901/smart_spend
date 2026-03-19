import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isIncome; // true = thu nhập, false = chi tiêu

  @HiveField(3)
  final int colorValue; // Color ARGB encoded as int

  @HiveField(4)
  final int iconCodePoint; // Material icon code point

  Category({
    required this.id,
    required this.name,
    required this.isIncome,
    required this.colorValue,
    required this.iconCodePoint,
  });

  Color get color => Color(colorValue);

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
}

// Default categories - chi tiêu
final expenseDefaultCategories = [
  Category(
    id: 'food',
    name: 'Ăn uống',
    isIncome: false,
    colorValue: 0xFFFF9800, // Material Orange
    iconCodePoint: Icons.restaurant.codePoint,
  ),
  Category(
    id: 'transport',
    name: 'Di chuyển',
    isIncome: false,
    colorValue: 0xFF2196F3, // Material Blue
    iconCodePoint: Icons.directions_car_filled.codePoint,
  ),
  Category(
    id: 'shopping',
    name: 'Shopping',
    isIncome: false,
    colorValue: 0xFFE91E63, // Material Pink
    iconCodePoint: Icons.shopping_bag.codePoint,
  ),
  Category(
    id: 'utilities',
    name: 'Tiện ích',
    isIncome: false,
    colorValue: 0xFF9C27B0, // Material Purple
    iconCodePoint: Icons.lightbulb.codePoint,
  ),
];

// Default categories - thu nhập
final incomeDefaultCategories = [
  Category(
    id: 'salary',
    name: 'Lương',
    isIncome: true,
    colorValue: 0xFF4CAF50, // Material Green
    iconCodePoint: Icons.wallet.codePoint,
  ),
  Category(
    id: 'bonus',
    name: 'Thưởng',
    isIncome: true,
    colorValue: 0xFF8BC34A, // Material Light Green
    iconCodePoint: Icons.card_giftcard.codePoint,
  ),
  Category(
    id: 'other_income',
    name: 'Khác',
    isIncome: true,
    colorValue: 0xFF009688, // Material Teal
    iconCodePoint: Icons.trending_up.codePoint,
  ),
];
