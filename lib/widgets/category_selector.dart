import 'package:flutter/material.dart';
import 'package:smart_spend/models/transaction.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hạng mục', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExpenseCategory.values.map((category) {
            return ChoiceChip(
              avatar: Icon(category.icon, size: 18),
              label: Text(category.label),
              selected: selected == category,
              onSelected: (_) => onSelected(category),
            );
          }).toList(),
        ),
      ],
    );
  }
}
