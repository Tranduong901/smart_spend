import 'package:flutter/material.dart';

const _categories = ['Ăn uống', 'Di chuyển', 'Giải trí', 'Thu nhập', 'Khác'];

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _categories
            .map(
              (c) => ListTile(
                title: Text(c),
                onTap: () => Navigator.of(context).pop(c),
              ),
            )
            .toList(),
      ),
    );
  }
}
