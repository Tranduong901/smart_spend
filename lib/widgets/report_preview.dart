import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/transaction.dart';
import '../services/file_export_helper.dart';
import '../services/report_generator.dart';

/// Widget for previewing and exporting reports
class ReportPreviewWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Transaction> allTransactions;
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const ReportPreviewWidget({
    Key? key,
    required this.transactions,
    required this.allTransactions,
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
  bool _exportAllMonths = false;

  List<Transaction> _getEffectiveExportTransactions() {
    final selected =
        _exportAllMonths ? widget.allTransactions : widget.transactions;
    if (selected.isNotEmpty) {
      return selected;
    }

    return widget.allTransactions;
  }

  bool _isUsingFallbackAllTransactions() {
    return !_exportAllMonths &&
        widget.transactions.isEmpty &&
        widget.allTransactions.isNotEmpty;
  }

  double _incomeOf(List<Transaction> transactions) {
    return transactions
        .where((tx) => tx.isIncome)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
  }

  double _expenseOf(List<Transaction> transactions) {
    return transactions
        .where((tx) => !tx.isIncome)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrentMonth = widget.transactions.isNotEmpty;
    final exportTransactions = _getEffectiveExportTransactions();
    final usingFallback = _isUsingFallbackAllTransactions();
    final exportIncome = _incomeOf(exportTransactions);
    final exportExpense = _expenseOf(exportTransactions);
    final exportBalance = exportIncome - exportExpense;

    return Padding(
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
          if (!_exportAllMonths && !usingFallback)
            Text(
              'Tháng ${widget.month}/${widget.year}',
              style: TextStyle(color: Colors.grey[600]),
            )
          else
            Text(
              'Tất cả các tháng',
              style: TextStyle(
                  color: Colors.blue[600], fontWeight: FontWeight.w500),
            ),
          SizedBox(height: 24),

          // Warning if no transactions in current month
          if (!hasCurrentMonth)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                border: Border.all(color: Colors.amber.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_outlined, color: Colors.amber.shade900),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tháng này chưa có giao dịch. Bạn có thể xuất dữ liệu từ tất cả các tháng.',
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),

          if (!hasCurrentMonth) SizedBox(height: 16),

          // Summary section (show what will be exported)
          _SummaryCard(
            month: widget.month,
            year: widget.year,
            totalIncome: exportIncome,
            totalExpense: exportExpense,
            balance: exportBalance,
            showAllMonths: _exportAllMonths || usingFallback,
          ),
          SizedBox(height: 16),

          // Toggle for exporting all months
          if (!hasCurrentMonth)
            CheckboxListTile(
              value: _exportAllMonths,
              onChanged: (value) {
                setState(() => _exportAllMonths = value ?? false);
              },
              title: Text('Xuất dữ liệu từ tất cả các tháng'),
              subtitle: Text('${widget.allTransactions.length} giao dịch'),
            ),

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
          if (exportTransactions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Các Giao Dịch Gần Đây',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                _buildTransactionList(exportTransactions),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> txList) {
    final displayList = txList.take(5).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final tx = displayList[index];
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
      final exportTransactions = _getEffectiveExportTransactions();
      final usingFallback = _isUsingFallbackAllTransactions();
      if (exportTransactions.isEmpty) {
        throw Exception('Không có dữ liệu giao dịch để xuất báo cáo.');
      }

      final pdfData = await ReportGenerator.generatePdfReport(
        transactions: exportTransactions,
        totalIncome: _incomeOf(exportTransactions),
        totalExpense: _expenseOf(exportTransactions),
        balance: _incomeOf(exportTransactions) - _expenseOf(exportTransactions),
        month: widget.month,
        year: widget.year,
      );

      final savedPath = await exportReportFile(
        pdfData,
        'bao_cao_${widget.month}_${widget.year}.pdf',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usingFallback
                ? 'Không có dữ liệu tháng hiện tại, đã xuất toàn bộ giao dịch: ${savedPath ?? 'PDF đã được tải xuống'}'
                : (savedPath == null
                    ? 'PDF đã được tải xuống'
                    : 'PDF đã lưu tại: $savedPath'),
          ),
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
      final exportTransactions = _getEffectiveExportTransactions();
      final usingFallback = _isUsingFallbackAllTransactions();
      if (exportTransactions.isEmpty) {
        throw Exception('Không có dữ liệu giao dịch để xuất báo cáo.');
      }

      final csvData = ReportGenerator.generateCsvReport(exportTransactions);
      final bytes = Uint8List.fromList(csvData.codeUnits);

      final savedPath = await exportReportFile(
        bytes,
        'bao_cao_${widget.month}_${widget.year}.csv',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usingFallback
                ? 'Không có dữ liệu tháng hiện tại, đã xuất toàn bộ giao dịch: ${savedPath ?? 'CSV đã được tải xuống'}'
                : (savedPath == null
                    ? 'CSV đã được tải xuống'
                    : 'CSV đã lưu tại: $savedPath'),
          ),
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
  final bool showAllMonths;

  const _SummaryCard({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.showAllMonths = false,
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
