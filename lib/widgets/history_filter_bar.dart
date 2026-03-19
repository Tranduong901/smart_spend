import 'package:flutter/material.dart';

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.years,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  final int selectedMonth;
  final int selectedYear;
  final List<int> years;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  @override
  Widget build(BuildContext context) {
    final uniqueYears = years.toSet().toList()..sort();
    final effectiveYear =
        uniqueYears.contains(selectedYear) ? selectedYear : uniqueYears.last;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: selectedMonth,
            decoration: const InputDecoration(labelText: 'Tháng'),
            items: List.generate(
              12,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text('Tháng ${index + 1}'),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                onMonthChanged(value);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: effectiveYear,
            decoration: const InputDecoration(labelText: 'Năm'),
            items: uniqueYears
                .map(
                  (year) =>
                      DropdownMenuItem(value: year, child: Text('Năm $year')),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onYearChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
