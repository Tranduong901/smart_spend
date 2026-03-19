import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/providers/expense_provider.dart';
import 'package:smart_spend/widgets/dynamic_category_selector.dart';
import 'package:smart_spend/widgets/receipt_capture_button.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedCategoryName = 'Ăn uống';
  bool _isIncome = false;
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final provider = context.read<ExpenseProvider>();
      final defaultCategory = _defaultCategoryName(provider, _isIncome);
      setState(() {
        _selectedCategoryName = defaultCategory;
      });
    });
  }

  String _defaultCategoryName(ExpenseProvider provider, bool isIncome) {
    final categories =
        isIncome ? provider.incomeCategories : provider.expenseCategories;
    if (categories.isNotEmpty) {
      return categories.first.name;
    }
    return isIncome ? 'Lương' : 'Ăn uống';
  }

  @override
  void dispose() {
    _titleController.dispose();
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
              title: _titleController.text.trim().isEmpty
                  ? _selectedCategoryName
                  : _titleController.text.trim(),
              amount: amount,
              date: _selectedDate!,
              categoryName: _selectedCategoryName,
              note: _noteController.text.trim().isEmpty
                  ? 'Không có ghi chú'
                  : _noteController.text.trim(),
              imagePath: _receiptPath,
              isIncome: _isIncome,
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
    _titleController.clear();
    _noteController.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedDate = null;
      _isIncome = false;
      _selectedCategoryName = _defaultCategoryName(
        context.read<ExpenseProvider>(),
        _isIncome,
      );
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
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề giao dịch',
                  prefixIcon: Icon(Icons.subject_outlined),
                  hintText: 'Ví dụ: Ăn cơm trưa',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nhập tiêu đề giao dịch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
              Text(
                'Loại giao dịch',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Chi tiêu'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Thu nhập'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {_isIncome},
                onSelectionChanged: (values) {
                  final value = values.first;
                  final provider = context.read<ExpenseProvider>();
                  setState(() {
                    _isIncome = value;
                    _selectedCategoryName =
                        _defaultCategoryName(provider, value);
                  });
                },
              ),
              const SizedBox(height: 16),
              DynamicCategorySelector(
                selectedCategoryName: _selectedCategoryName,
                onSelected: (value) {
                  setState(() {
                    _selectedCategoryName = value;
                  });
                },
                isIncome: _isIncome,
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
                  label: Text(_isIncome ? 'Lưu thu nhập' : 'Lưu chi tiêu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
