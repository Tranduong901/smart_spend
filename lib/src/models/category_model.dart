import 'dart:convert';
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? iconPath;
  final int colorValue;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconPath,
    required this.colorValue,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconPath: json['iconPath'],
      colorValue: json['colorValue'] ?? Colors.grey.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'colorValue': colorValue,
    };
  }

  Color get color => Color(colorValue);

  @override
  String toString() => jsonEncode(toJson());
}
