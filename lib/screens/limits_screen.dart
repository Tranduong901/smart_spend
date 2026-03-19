import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/models/limit.dart';

class LimitsScreen extends StatelessWidget {
  const LimitsScreen({super.key});

  String _formatVnd(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r"\\B(?=(\\d{3})+(?!\\d))"), (m) => '.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final limits = provider.limits;
    final transactions = provider.transactions;

    final now = DateTime.now();
    final selectedMonth = now.month;
    final selectedYear = now.year;

    final monthExpenses = transactions
        .where((tx) =>
            tx.date.month == selectedMonth &&
            tx.date.year == selectedYear &&
            !tx.isIncome)
        .fold<double>(0, (s, tx) => s + tx.amount);

    final budgetLimit = provider.monthlyBudgetLimit;
    final monthlyProgress =
        (monthExpenses / (budgetLimit > 0 ? budgetLimit : 1)).clamp(0.0, 1.0);
    final monthlyRemaining =
        (budgetLimit - monthExpenses).clamp(0.0, double.infinity);
    final lastDayOfMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    final daysLeft = (lastDayOfMonth - now.day).clamp(0, lastDayOfMonth);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly budget card
            Card(
              color: const Color.fromARGB(255, 250, 244, 250),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child:
                              const Icon(Icons.payments, color: Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tổng chi tiêu tháng',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                  '01/${selectedMonth.toString().padLeft(2, '0')} - $lastDayOfMonth/${selectedMonth.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_formatVnd(budgetLimit),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(width: 6),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final amountCtrl = TextEditingController(
                                        text: budgetLimit.toStringAsFixed(0));
                                    final result = await showDialog<double?>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Đặt hạn mức tháng'),
                                        content: TextField(
                                          controller: amountCtrl,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                              labelText: 'Số tiền (VND)'),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              child: const Text('Huỷ')),
                                          FilledButton(
                                              onPressed: () {
                                                final v = double.tryParse(
                                                    amountCtrl.text.trim());
                                                Navigator.pop(dialogContext, v);
                                              },
                                              child: const Text('Lưu')),
                                        ],
                                      ),
                                    );
                                    if (result != null) {
                                      await provider
                                          .setMonthlyBudgetLimit(result);
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text('Hôm nay',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                        value: monthlyProgress,
                        minHeight: 6,
                        color: Colors.orange,
                        backgroundColor: Colors.orange.shade100),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Còn $daysLeft ngày',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(_formatVnd(monthlyRemaining),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Header with add button
            Row(
              children: [
                Expanded(
                    child: Text('Hạn mức chi tiêu',
                        style: Theme.of(context).textTheme.headlineSmall)),
                IconButton(
                  onPressed: () async {
                    final categories = provider.expenseCategories;
                    String? selectedTag;
                    final result = await showDialog<Map<String, dynamic>?>(
                      context: context,
                      builder: (dialogContext) {
                        final titleCtrl = TextEditingController();
                        final amountCtrl = TextEditingController();
                        return StatefulBuilder(builder: (sContext, setState) {
                          return AlertDialog(
                            title: const Text('Thêm hạn mức mới'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                    controller: titleCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Tiêu đề')),
                                const SizedBox(height: 8),
                                TextField(
                                    controller: amountCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                        labelText:
                                            'Số tiền (VND) - để trống nếu chưa đặt')),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String?>(
                                  initialValue: selectedTag,
                                  decoration:
                                      const InputDecoration(labelText: 'Tag'),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                        value: null, child: Text('Không chọn')),
                                    ...categories.map((c) => DropdownMenuItem(
                                        value: c.name, child: Text(c.name))),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => selectedTag = v),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Huỷ')),
                              FilledButton(
                                  onPressed: () {
                                    final title = titleCtrl.text.trim();
                                    final amount =
                                        double.tryParse(amountCtrl.text.trim());
                                    Navigator.pop(dialogContext, {
                                      'title': title,
                                      'amount': amount,
                                      'tag': selectedTag
                                    });
                                  },
                                  child: const Text('Lưu')),
                            ],
                          );
                        });
                      },
                    );

                    if (result != null &&
                        result['title'] != null &&
                        (result['title'] as String).isNotEmpty) {
                      await provider.addLimit(result['title'] as String,
                          amount: result['amount'] as double?,
                          tag: result['tag'] as String?);
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Limits list
            Expanded(
              child: limits.isEmpty
                  ? Center(
                      child: Text(
                          'Chưa có hạn mức. Thêm một hạn mức bằng nút +',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge))
                  : ListView.separated(
                      itemCount: limits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final Limit limit = limits[index];
                        final title = limit.title;
                        final amtText = limit.amount != null
                            ? _formatVnd(limit.amount!)
                            : 'Chưa đặt';

                        final spent = transactions
                            .where((tx) =>
                                !tx.isIncome &&
                                (limit.tag != null && limit.tag!.isNotEmpty
                                    ? tx.categoryName == limit.tag
                                    : tx.title == title) &&
                                tx.date.month == selectedMonth &&
                                tx.date.year == selectedYear)
                            .fold<double>(0, (s, tx) => s + tx.amount);

                        final limitAmount = limit.amount;
                        final progressValue =
                            (limitAmount != null && limitAmount > 0)
                                ? (spent / limitAmount).clamp(0.0, 1.0)
                                : 0.0;
                        final remainingForTag = (limitAmount != null)
                            ? (limitAmount - spent).clamp(0.0, double.infinity)
                            : null;

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                        child: Text(title.isNotEmpty
                                            ? title[0].toUpperCase()
                                            : '?')),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 6),
                                          Text('Giới hạn: $amtText',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final amountCtrl =
                                            TextEditingController(
                                                text: limit.amount
                                                        ?.toStringAsFixed(0) ??
                                                    '');
                                        final result =
                                            await showDialog<double?>(
                                          context: context,
                                          builder: (dialogContext) =>
                                              AlertDialog(
                                            title: Text(
                                                'Đặt hạn mức cho "${limit.title}"'),
                                            content: TextField(
                                                controller: amountCtrl,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Số tiền (VND)')),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          dialogContext),
                                                  child: const Text('Huỷ')),
                                              FilledButton(
                                                  onPressed: () {
                                                    final v = double.tryParse(
                                                        amountCtrl.text.trim());
                                                    Navigator.pop(
                                                        dialogContext, v);
                                                  },
                                                  child: const Text('Lưu')),
                                            ],
                                          ),
                                        );
                                        if (result != null) {
                                          await provider.updateLimitAmount(
                                              limit.title, result);
                                        }
                                      },
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (d) => AlertDialog(
                                            title: const Text('Xác nhận xóa'),
                                            content: Text(
                                                'Xóa hạn mức "${limit.title}"?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(d, false),
                                                  child: const Text('Huỷ')),
                                              FilledButton(
                                                  onPressed: () =>
                                                      Navigator.pop(d, true),
                                                  child: const Text('Xóa')),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await provider
                                              .deleteLimit(limit.title);
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                                if (limitAmount != null) ...[
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: progressValue,
                                    minHeight: 6,
                                    color: (spent > limitAmount)
                                        ? Colors.red
                                        : Colors.orange,
                                    backgroundColor: (spent > limitAmount)
                                        ? Colors.red.shade100
                                        : Colors.orange.shade100,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatVnd(spent),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                        Text(_formatVnd(limitAmount),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                      ]),
                                  const SizedBox(height: 6),
                                  Text('Còn ${_formatVnd(remainingForTag!)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  if (spent > limitAmount) ...[
                                    const SizedBox(height: 8),
                                    const Text('Đã vượt hạn mức!',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Text('Chưa đặt hạn mức cho tag này',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
