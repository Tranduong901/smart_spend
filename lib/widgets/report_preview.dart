import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import '../models/transaction.dart';
import '../services/report_generator.dart';

/// Widget for previewing and exporting reports
class ReportPreviewWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const ReportPreviewWidget({
    Key? key,
    required this.transactions,
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  }) : super(key: key);

  @override
  State<ReportPreviewWidget> createState() => _ReportPreviewWidgetState();
}

class _ReportPreviewWidgetState extends State<ReportPreviewWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Báo Cáo Tài Chính',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tháng ${widget.month}/${widget.year}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),

            // Summary section
            _SummaryCard(
              month: widget.month,
              year: widget.year,
              totalIncome: widget.totalIncome,
              totalExpense: widget.totalExpense,
              balance: widget.balance,
            ),
            SizedBox(height: 24),

            // Export buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Xuất Dữ Liệu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _exportPdf,
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Xuất PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.red.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _exportCsv,
                  icon: Icon(Icons.table_chart),
                  label: Text('Xuất CSV'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Recent transactions preview
            if (widget.transactions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Các Giao Dịch Gần Đây',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _buildTransactionList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final txList = widget.transactions.take(5).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: txList.length,
      itemBuilder: (context, index) {
        final tx = txList[index];
        return ListTile(
          leading: Icon(
            tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: tx.isIncome ? Colors.green : Colors.red,
          ),
          title: Text(tx.title),
          subtitle: Text(tx.categoryName),
          trailing: Text(
            '${tx.isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: tx.isIncome ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _isLoading = true);
    try {
      final pdfData = await ReportGenerator.generatePdfReport(
        transactions: widget.transactions,
        totalIncome: widget.totalIncome,
        totalExpense: widget.totalExpense,
        balance: widget.balance,
        month: widget.month,
        year: widget.year,
      );

      _downloadFile(pdfData, 'bao_cao_${widget.month}_${widget.year}.pdf');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF đã được tải xuống'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _isLoading = true);
    try {
      final csvData = ReportGenerator.generateCsvReport(widget.transactions);
      final bytes = Uint8List.fromList(csvData.codeUnits);

      _downloadFile(bytes, 'bao_cao_${widget.month}_${widget.year}.csv');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV đã được tải xuống'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _downloadFile(Uint8List bytes, String filename) {
    // This is a placeholder for web/desktop download
    // For actual implementation, use platform-specific code
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final link = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body!.children.add(link);
      link.click();
      html.document.body!.children.remove(link);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Download error: $e');
    }
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final withDots = intPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$withDots ₫';
  }
}

class _SummaryCard extends StatelessWidget {
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const _SummaryCard({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Tổng Thu Nhập',
            value: _formatCurrency(totalIncome),
            isPositive: true,
          ),
          Divider(height: 16),
          _SummaryRow(
            label: 'Tổng Chi Tiêu',
            value: _formatCurrency(totalExpense),
            isPositive: false,
          ),
          Divider(height: 16),
          _SummaryRow(
            label: 'Số Dư',
            value: _formatCurrency(balance),
            isPositive: balance >= 0,
            isBold: true,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final withDots = intPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$withDots ₫';
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isPositive,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isPositive ? Colors.green : Colors.red,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
