import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/widgets/category_selector.dart';
import 'package:smart_spend/widgets/receipt_capture_button.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  String? _receiptPath;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      helpText: 'Chọn ngày giao dịch',
      locale: const Locale('vi', 'VN'),
    );

    if (!mounted) {
      return;
    }

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày giao dịch.')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền không hợp lệ.')));
      return;
    }

    try {
      await context.read<ExpenseProvider>().addTransaction(
            Transaction(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              amount: amount,
              date: _selectedDate!,
              category: _selectedCategory,
              note: _noteController.text.trim().isEmpty
                  ? 'Không có ghi chú'
                  : _noteController.text.trim(),
              imagePath: _receiptPath,
              isIncome: false,
            ),
          );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu giao dịch thất bại. Vui lòng thử lại.'),
        ),
      );
      return;
    }

    _formKey.currentState!.reset();
    _amountController.clear();
    _noteController.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedDate = null;
      _selectedCategory = ExpenseCategory.food;
      _receiptPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm giao dịch thành công.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Chưa chọn ngày'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thêm giao dịch',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Số tiền (VND)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());
                  if (amount == null || amount <= 0) {
                    return 'Nhập số tiền hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Ngày giao dịch: $dateText'),
              ),
              const SizedBox(height: 16),
              CategorySelector(
                selected: _selectedCategory,
                onSelected: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ReceiptCaptureButton(
                hasReceipt: _receiptPath != null,
                onCapture: () {
                  setState(() {
                    _receiptPath = 'mock_receipt_path.jpg';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gắn ảnh hóa đơn mẫu.')),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu giao dịch'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
