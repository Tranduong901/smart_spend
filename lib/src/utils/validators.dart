import '../models/transaction_model.dart';

class Validators {
  static String? validateAmount(String? text) {
    if (text == null || text.trim().isEmpty) return 'Vui lòng nhập số tiền';
    final cleaned = text.replaceAll(RegExp(r'[^0-9-]'), '');
    final value = int.tryParse(cleaned);
    if (value == null) return 'Số tiền không hợp lệ';
    if (value == 0) return 'Số tiền không được bằng 0';
    return null;
  }

  static String? validateDate(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now)) return 'Ngày không được ở tương lai';
    return null;
  }

  static String? validateCategory(String? cat) {
    if (cat == null || cat.trim().isEmpty) return 'Vui lòng chọn phân loại';
    return null;
  }
}
