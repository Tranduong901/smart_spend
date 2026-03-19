import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/models/category.dart';
import 'package:smart_spend/providers/expense_provider.dart';

class DynamicCategorySelector extends StatefulWidget {
  const DynamicCategorySelector({
    super.key,
    required this.selectedCategoryName,
    required this.onSelected,
    required this.isIncome,
  });

  final String selectedCategoryName;
  final ValueChanged<String> onSelected;
  final bool isIncome;

  @override
  State<DynamicCategorySelector> createState() =>
      _DynamicCategorySelectorState();
}

class _DynamicCategorySelectorState extends State<DynamicCategorySelector> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final categories = widget.isIncome
            ? provider.incomeCategories
            : provider.expenseCategories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isIncome ? 'Hạng mục thu' : 'Hạng mục chi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...categories.map((category) {
                  final isSelected =
                      widget.selectedCategoryName == category.name;
                  return ChoiceChip(
                    avatar: Icon(
                      category.icon,
                      size: 18,
                      color: isSelected ? Colors.white : category.color,
                    ),
                    label: Text(category.name),
                    selected: isSelected,
                    selectedColor: category.color,
                    onSelected: (_) => widget.onSelected(category.name),
                  );
                }),
                if (categories.length < 10)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm mục'),
                    onPressed: () => _showAddCategoryDialog(context),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => _AddCategoryDialog(
        isIncome: widget.isIncome,
        nameController: nameController,
        onSaved: (category) {
          widget.onSelected(category.name);
        },
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog({
    required this.isIncome,
    required this.nameController,
    required this.onSaved,
  });

  final bool isIncome;
  final TextEditingController nameController;
  final ValueChanged<Category> onSaved;

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  late IconData selectedIcon;
  late Color selectedColor;

  static const iconOptions = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.home,
    Icons.health_and_safety,
    Icons.school,
    Icons.sports,
    Icons.pets,
    Icons.travel_explore,
    Icons.local_cafe,
    Icons.local_movies,
    Icons.videogame_asset,
  ];

  static const colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    selectedIcon = Icons.category;
    selectedColor = Colors.blue;
  }

  @override
  void dispose() {
    widget.nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isIncome ? 'Thêm hạng mục thu' : 'Thêm hạng mục chi',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.nameController,
              decoration: const InputDecoration(
                labelText: 'Tên hạng mục',
                hintText: 'Ví dụ: Ăn cơm',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn biểu tượng:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: iconOptions
                  .map(
                    (icon) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedIcon == icon
                                ? Colors.blue
                                : Colors.grey,
                            width: selectedIcon == icon ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn màu sắc:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colorOptions
                  .map(
                    (color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        TextButton(
          onPressed: () {
            if (widget.nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nhập tên hạng mục')),
              );
              return;
            }

            final provider = context.read<ExpenseProvider>();
            final newCategory = Category(
              id: DateTime.now().toString(),
              name: widget.nameController.text.trim(),
              isIncome: widget.isIncome,
              // ignore: deprecated_member_use
              colorValue: selectedColor.value,
              iconCodePoint: selectedIcon.codePoint,
            );

            if (widget.isIncome) {
              provider.addIncomeCategory(newCategory);
            } else {
              provider.addExpenseCategory(newCategory);
            }

            widget.onSaved(newCategory);
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
