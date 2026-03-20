import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import '../models/transaction.dart';
import 'pdf_font_loader.dart';

/// Service for generating financial reports in PDF and CSV formats
class ReportGenerator {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Generate a PDF report for transactions in a given month
  static Future<Uint8List> generatePdfReport({
    required List<Transaction> transactions,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required int month,
    required int year,
  }) async {
    // ⭐ QUAN TRỌNG: Load font Unicode TRƯỚC khi generate PDF
    final vietnamFont = await PdfFontLoader.loadRobotoFont();

    final pdf = pw.Document();

    // Title and summary section
    final title = 'Báo Cáo Tài Chính Tháng $month/$year';
    final summary = '''
Tổng Thu Nhập: ${_formatCurrency(totalIncome)}
Tổng Chi Tiêu: ${_formatCurrency(totalExpense)}
Số Dư: ${_formatCurrency(balance)}
''';

    /// Group transactions by category
    final Map<String, List<Transaction>> byCategory = {};
    for (var tx in transactions) {
      if (!byCategory.containsKey(tx.categoryName)) {
        byCategory[tx.categoryName] = [];
      }
      byCategory[tx.categoryName]!.add(tx);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: vietnamFont,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Paragraph(
            text: summary,
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(font: vietnamFont, fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.Header(
            level: 1,
            child: pw.Text(
              'Chi Tiết Giao Dịch',
              style: pw.TextStyle(
                font: vietnamFont,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          _buildTransactionTable(transactions, vietnamFont),
          pw.SizedBox(height: 20),
          pw.Header(
            level: 1,
            child: pw.Text(
              'Phân Tích Theo Danh Mục',
              style: pw.TextStyle(
                font: vietnamFont,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          _buildCategoryBreakdown(byCategory, vietnamFont),
        ],
      ),
    );

    return pdf.save();
  }

  /// Build a table for transaction details
  static pw.Widget _buildTransactionTable(
    List<Transaction> transactions,
    pw.Font vietnamFont,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Ngày',
                  style: pw.TextStyle(
                    font: vietnamFont,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Tiêu Đề',
                  style: pw.TextStyle(
                    font: vietnamFont,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Danh Mục',
                  style: pw.TextStyle(
                    font: vietnamFont,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Số Tiền',
                  style: pw.TextStyle(
                    font: vietnamFont,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
          ],
        ),
        // Data rows
        ...transactions.map((tx) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(_dateFormat.format(tx.date),
                      style: pw.TextStyle(font: vietnamFont, fontSize: 10)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(tx.title,
                      style: pw.TextStyle(font: vietnamFont, fontSize: 10)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(tx.categoryName,
                      style: pw.TextStyle(font: vietnamFont, fontSize: 10)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '${tx.isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}',
                    style: pw.TextStyle(font: vietnamFont, fontSize: 10),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  /// Build a breakdown widget by category
  static pw.Widget _buildCategoryBreakdown(
    Map<String, List<Transaction>> byCategory,
    pw.Font vietnamFont,
  ) {
    final rows = byCategory.entries.map((entry) {
      double total = entry.value.fold(0, (sum, tx) => sum + tx.amount);
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.all(8),
            child: pw.Text(entry.key,
                style: pw.TextStyle(font: vietnamFont, fontSize: 11)),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(8),
            child: pw.Text(
              _formatCurrency(total),
              style: pw.TextStyle(font: vietnamFont, fontSize: 11),
            ),
          ),
        ],
      );
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Danh Mục',
                  style: pw.TextStyle(
                    font: vietnamFont,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Tổng Tiền',
                  style: pw.TextStyle(
                    font: vietnamFont,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
          ],
        ),
        ...rows,
      ],
    );
  }

  /// Generate CSV data for transactions
  static String generateCsvReport(List<Transaction> transactions) {
    List<List<String>> csvData = [
      ['Ngày', 'Tiêu Đề', 'Danh Mục', 'Số Tiền', 'Loại', 'Ghi Chú'],
      ...transactions.map((tx) => [
            _dateFormat.format(tx.date),
            tx.title,
            tx.categoryName,
            tx.amount.toString(),
            tx.isIncome ? 'Thu nhập' : 'Chi tiêu',
            tx.note,
          ]),
    ];

    return csvData.map((row) => row.join(',')).join('\n');
  }

  /// Format currency in Vietnamese format
  /// Handles special Unicode character ₫ (U+20AB)
  static String _formatCurrency(double amount) {
    try {
      final formatted = _currencyFormat.format(amount);
      // Ensure the ₫ character is properly encoded (U+20AB)
      return formatted.replaceAll('₫', '₫');
    } catch (e) {
      // Fallback với explicit Unicode character
      return '${amount.toStringAsFixed(0)} ₫';
    }
  }

  /// Get summary statistics for a given month
  static Map<String, double> getSummaryStats(
    List<Transaction> transactions,
    int targetMonth,
    int targetYear,
  ) {
    double income = 0;
    double expense = 0;
    int transactionCount = 0;

    for (var tx in transactions) {
      if (tx.date.month == targetMonth && tx.date.year == targetYear) {
        if (tx.isIncome) {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
        transactionCount++;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
      'count': transactionCount.toDouble(),
      'avgPerDay': transactionCount > 0 ? (income + expense) / 30 : 0,
    };
  }
}
