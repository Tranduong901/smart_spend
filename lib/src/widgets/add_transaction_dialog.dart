import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/validators.dart';
// formatters not currently used here
import 'category_picker.dart';

class AddTransactionDialog extends StatefulWidget {
  final TransactionType type;
  const AddTransactionDialog({super.key, required this.type});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _category;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  void _pickCategory() async {
    final sel = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const CategoryPicker(),
    );
    if (sel != null) setState(() => _category = sel);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final raw = _amountCtrl.text.replaceAll(RegExp(r'[^0-9-]'), '');
    final amount = int.tryParse(raw) ?? 0;
    final provider = context.read<TransactionProvider>();
    final t = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: _category ?? 'Khác',
      type: widget.type,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      imageUrl: null,
      isSynced: false,
    );
    await provider.addTransaction(t);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == TransactionType.income
        ? 'Thêm Thu nhập'
        : 'Thêm Chi tiêu';
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'Tiêu đề'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng nhập tiêu đề'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Số tiền'),
                      validator: Validators.validateAmount,
                      onChanged: (s) {
                        // optional: realtime formatting skipped for simplicity
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDate,
                          child: const Text('Chọn ngày'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(_category ?? 'Chưa chọn danh mục'),
                        ),
                        TextButton(
                          onPressed: _pickCategory,
                          child: const Text('Chọn danh mục'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú (tuỳ chọn)',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Huỷ'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Lưu'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
