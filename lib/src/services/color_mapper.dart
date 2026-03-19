import 'package:flutter/material.dart';

class ColorMapper {
  static const Map<String, Color> _map = {
    'Ăn uống': Colors.orange,
    'Di chuyển': Colors.blue,
    'Giải trí': Colors.purple,
    'Thu nhập': Colors.green,
    'Khác': Colors.grey,
  };

  static Color colorFor(String category) {
    return _map[category] ?? Colors.teal;
  }
}
