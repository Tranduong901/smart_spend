import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service để tải và quản lý font Unicode cho PDF (hỗ trợ tiếng Việt)
class PdfFontLoader {
  static pw.Font? _robotoFont;
  static pw.Font? _notoSansFont;

  /// Load Roboto font từ assets (hỗ trợ tiếng Việt, U+20AB ₫, v.v.)
  /// Gọi hàm này TRƯỚC khi generate PDF
  static Future<pw.Font> loadRobotoFont() async {
    if (_robotoFont != null) return _robotoFont!;

    try {
      // Tải Roboto Regular từ assets/fonts/static/
      final fontData =
          await rootBundle.load('assets/fonts/static/Roboto-Regular.ttf');
      _robotoFont = pw.Font.ttf(fontData);
      print('✅ Font loaded: Roboto-Regular');
      return _robotoFont!;
    } catch (e) {
      print('❌ Lỗi load Roboto font: $e');
      // Fallback: nếu không có file, sử dụng NotoSans (nếu có)
      return loadNotoSansFont();
    }
  }

  /// Load NotoSans font - Alternative font với hỗ trợ Unicode đầy đủ
  /// (Fallback nếu Roboto không có)
  static Future<pw.Font> loadNotoSansFont() async {
    if (_notoSansFont != null) return _notoSansFont!;

    try {
      // Thử tải một font khác từ thư mục static/ nếu có
      // Hiện tại chỉ có Roboto, nên fallback tới font mặc định
      print('⚠️ NotoSans font không có, sử dụng fallback...');
      return pw.Font.helvetica();
    } catch (e) {
      print('❌ Lỗi load NotoSans font: $e');
      // Fallback cuối cùng: Helvetica
      return pw.Font.helvetica();
    }
  }

  /// Lấy font hiện tại (đã load)
  /// Nếu chưa load, sẽ trả về default font
  static pw.Font? getCurrentFont() => _robotoFont ?? _notoSansFont;

  /// Reset cache (dùng khi cần reload font)
  static void resetFontCache() {
    _robotoFont = null;
    _notoSansFont = null;
  }
}
