import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service để tải và quản lý font Unicode cho PDF (hỗ trợ tiếng Việt)
class PdfFontLoader {
  static pw.Font? _robotoFont;
  static const List<String> _robotoCandidates = [
    'assets/fonts/static/Roboto-Regular.ttf',
    'assets/fonts/Roboto-VariableFont_wdth,wght.ttf',
    'assets/fonts/Roboto-Italic-VariableFont_wdth,wght.ttf',
  ];

  /// Load Roboto font từ assets (hỗ trợ tiếng Việt, U+20AB ₫, v.v.)
  /// Gọi hàm này TRƯỚC khi generate PDF
  static Future<pw.Font> loadRobotoFont() async {
    if (_robotoFont != null) return _robotoFont!;

    for (final assetPath in _robotoCandidates) {
      try {
        final fontData = await rootBundle.load(assetPath);
        _robotoFont = pw.Font.ttf(fontData);
        print('✅ Font loaded: $assetPath');
        return _robotoFont!;
      } catch (_) {}
    }

    throw Exception(
      'Không thể load font Unicode cho PDF. Đã thử các asset: '
      '${_robotoCandidates.join(', ')}. '
      'Hãy kiểm tra pubspec.yaml, chạy flutter clean && flutter pub get, rồi build lại.',
    );
  }

  /// Lấy font hiện tại (đã load)
  /// Nếu chưa load, sẽ trả về default font
  static pw.Font? getCurrentFont() => _robotoFont;

  /// Reset cache (dùng khi cần reload font)
  static void resetFontCache() {
    _robotoFont = null;
  }
}
