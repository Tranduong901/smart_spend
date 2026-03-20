# 📊 D. Phân tích & Báo cáo: Dashboard, Biểu Đồ & Xuất PDF

> **Tập trung vào:** Dashboard tóm tắt, biểu đồ xu hướng Material 3, và xuất báo cáo PDF

---

## 📋 Mục Lục

1. [Overview & Kiến Trúc](#overview--kiến-trúc)
2. [Dashboard Tóm Tắt Tài Chính](#dashboard-tóm-tắt-tài-chính)
3. [Biểu Đồ Material 3](#biểu-đồ-material-3)
4. [Xuất Báo Cáo PDF](#xuất-báo-cáo-pdf)
5. [Luồng Dữ Liệu Toàn Bộ](#luồng-dữ-liệu-toàn-bộ)
6. [Material 3 Design](#material-3-design-principles)

---

## Overview & Kiến Trúc

### 🎯 Mục Đích

Module **Phân tích & Báo cáo** cung cấp ba khả năng chính:

| Tính Năng | Mục Đích | Người Dùng |
|-----------|---------|-----------|
| **Dashboard** | Tóm tắt nhanh tài chính (tháng, tất cả, so sánh) | Tất cả |
| **Biểu Đồ Xu Hướng** | Trực quan hóa thu chi theo thời gian (lineChart, barChart) | Phân tích |
| **Xuất Báo Cáo** | Tạo PDF/CSV cho chia sẻ, lưu trữ | Quản lý, Kế toán |

### 🏗️ Kiến Trúc Thành Phần

```
AnalysisScreen (Main Hub)
├── Dashboard Overview Tab
│   └── DashboardOverviewWidget → CategoryBreakdown
├── Trend Analysis Tab
│   └── TrendChartWidget (Line/Bar Chart)
└── Report Tab
    └── ReportPreviewWidget
        ├── Report Generator (PDF)
        └── File Export Helper
```

---

## Dashboard Tóm Tắt Tài Chính

### 📌 File Liên Quan

- **[lib/screens/analysis_screen.dart](../lib/screens/analysis_screen.dart)** - Main screen
- **[lib/widgets/dashboard_overview_widget.dart](../lib/widgets/dashboard_overview_widget.dart)** - Widget tóm tắt
- **[lib/widgets/category_breakdown_widget.dart](../lib/widgets/category_breakdown_widget.dart)** - Chi tiết danh mục
- **[lib/providers/expense_provider.dart](../lib/providers/expense_provider.dart)** - State management

### 🎨 Giao Diện Dashboard

```
┌─────────────────────────────────────────┐
│  📊 Báo Cáo Tài Chính - Tháng 3/2026    │
├─────────────────────────────────────────┤
│                                         │
│  Bộ Số Liệu:                           │
│  ┌─────────────────────────────────┐   │
│  │ 💰 Tổng Thu Nhập:  10,000,000₫ │   │
│  │ 💸 Tổng Chi Tiêu:   5,500,000₫ │   │
│  │ 💵 Số Dư:            4,500,000₫ │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Phân Tích Danh Mục:                   │
│  ┌─────────────────────────────────┐   │
│  │ 🍔 Ăn ở nhà:      2,500,000₫   │   │
│  │ 🛒 Mua sắm:       1,500,000₫   │   │
│  │ 🚗 Giao thông:    1,000,000₫   │   │
│  │ 💻 Công việc:       500,000₫   │   │
│  └─────────────────────────────────┘   │
│                                         │
│         [Xem Báo Cáo] [Tải PDF]        │
└─────────────────────────────────────────┘
```

### 💻 Code Implementation

#### 1️⃣ AnalysisScreen - Main Entry Point

```dart
class AnalysisScreen extends StatefulWidget {
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích & Báo cáo'),
        elevation: 0,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          // Tab navigation
          return Column(
            children: [
              // Month/Year selector
              _buildMonthYearSelector(provider),
              // Tab view
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.dashboard), text: 'Tổng Quan'),
                          Tab(icon: Icon(Icons.trending_up), text: 'Xu Hướng'),
                          Tab(icon: Icon(Icons.description), text: 'Báo Cáo'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: Dashboard
                            _buildDashboardTab(provider),
                            // Tab 2: Trend Chart
                            _buildTrendTab(provider),
                            // Tab 3: Report Preview
                            _buildReportTab(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthYearSelector(ExpenseProvider provider) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilledButton.tonal(
            onPressed: () => setState(() => _selectedMonth--),
            child: Text('< Tháng'),
          ),
          Text(
            'Tháng $_selectedMonth/$_selectedYear',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          FilledButton.tonal(
            onPressed: () => setState(() => _selectedMonth++),
            child: Text('Tháng >'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(ExpenseProvider provider) {
    final transactions = provider.getTransactionsByMonth(_selectedMonth, _selectedYear);
    
    return SingleChildScrollView(
      child: DashboardOverviewWidget(
        transactions: transactions,
        month: _selectedMonth,
        year: _selectedYear,
      ),
    );
  }
}
```

#### 2️⃣ DashboardOverviewWidget - Tóm Tắt Chi Tiết

```dart
class DashboardOverviewWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final int month;
  final int year;

  const DashboardOverviewWidget({
    required this.transactions,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    // Tính toán các số liệu chính
    double totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);

    double totalExpense = transactions
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);

    double balance = totalIncome - totalExpense;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 1️⃣ Thẻ tóm tắt chính (3 số liệu)
          _buildSummaryCards(context, totalIncome, totalExpense, balance),
          SizedBox(height: 24),

          // 2️⃣ Biểu đồ tròn chi tiêu
          _buildExpensePieChart(),
          SizedBox(height: 24),

          // 3️⃣ Danh sách chi tiết danh mục
          _buildCategoryBreakdown(),
        ],
      ),
    );
  }

  // Building Three Summary Cards
  Widget _buildSummaryCards(
    BuildContext context,
    double income,
    double expense,
    double balance,
  ) {
    return Row(
      children: [
        // Card 1: Income (Xanh lá)
        Expanded(
          child: Card(
            color: Colors.green.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Thu Nhập'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatCurrency(income),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12),

        // Card 2: Expense (Đỏ)
        Expanded(
          child: Card(
            color: Colors.red.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_down, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Chi Tiêu'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatCurrency(expense),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12),

        // Card 3: Balance (Xanh dương)
        Expanded(
          child: Card(
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Số Dư'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatCurrency(balance),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Pie Chart
  Widget _buildExpensePieChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi Tiêu Theo Danh Mục',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ExpensePieChart(transactions: transactions),
            ),
          ],
        ),
      ),
    );
  }

  // Category Breakdown List
  Widget _buildCategoryBreakdown() {
    // Group by category
    Map<String, double> categoryTotals = {};
    for (var tx in transactions.where((t) => !t.isIncome)) {
      categoryTotals[tx.categoryName] =
          (categoryTotals[tx.categoryName] ?? 0) + tx.amount;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phân Tích Chi Tiết',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...categoryTotals.entries.map((entry) {
              final percentage = entry.value /
                  categoryTotals.values.fold(0.0, (a, b) => a + b) *
                  100;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key),
                          SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
```

### 🔄 Luồng Dữ Liệu Dashboard

```
User Opens Analysis Screen
    ↓
ExpenseProvider.getTransactionsByMonth()
    ↓
Lấy danh sách Transaction từ LocalRepository (Hive)
    ↓
Filter theo tháng/năm selected
    ↓
DashboardOverviewWidget nhận danh sách
    ↓
Tính toán:
  - totalIncome (T.isIncome = true)
  - totalExpense (T.isIncome = false)
  - balance = income - expense
    ↓
Render 3 thẻ + Biểu đồ tròn + Danh sách danh mục
    ↓
User thấy tóm tắt tài chính theo thời gian
```

---

## Biểu Đồ Material 3

### 📌 File Liên Quan

- **[lib/widgets/trend_chart_widget.dart](../lib/widgets/trend_chart_widget.dart)** - Main trend chart
- **[lib/widgets/expense_pie_chart.dart](../lib/widgets/expense_pie_chart.dart)** - Pie chart
- **pubspec.yaml** - `fl_chart: ^0.69.0` package

### 🎨 Biểu Đồ Material 3 Design

#### 1️⃣ Pie Chart (Danh Mục Chi Tiêu)

```dart
class ExpensePieChart extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpensePieChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Nhóm theo danh mục
    Map<String, double> categoryTotals = {};
    List<Color> colors = [];
    
    for (var tx in transactions.where((t) => !t.isIncome)) {
      categoryTotals[tx.categoryName] =
          (categoryTotals[tx.categoryName] ?? 0) + tx.amount;
      
      // Gán màu đa sắc (Material 3)
      if (!colors.contains(_getColorForCategory(tx.categoryName))) {
        colors.add(_getColorForCategory(tx.categoryName));
      }
    }

    final sections = categoryTotals.entries
        .asMap()
        .entries
        .map((entry) {
          int index = entry.key;
          String category = entry.value.key;
          double value = entry.value.value;
          double percentage = value / categoryTotals.values.sum * 100;

          return PieChartSectionData(
            color: colors[index % colors.length],
            value: value,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        })
        .toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Color _getColorForCategory(String category) {
    // Material 3 Color Palette
    const colors = [
      Color(0xFF6200EE), // Scheme Primary
      Color(0xFF03DAC6), // Scheme Tertiary
      Color(0xFFFF5722), // Material Orange
      Color(0xFF2196F3), // Material Blue
      Color(0xFFFF9800), // Material Orange Light
      Color(0xFF9C27B0), // Material Purple
    ];
    
    return colors[category.hashCode % colors.length];
  }
}
```

#### 2️⃣ Trend Chart (Line/Bar Chart)

```dart
class TrendChartWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final int month;
  final int year;

  const TrendChartWidget({
    required this.transactions,
    required this.month,
    required this.year,
  });

  @override
  State<TrendChartWidget> createState() => _TrendChartWidgetState();
}

class _TrendChartWidgetState extends State<TrendChartWidget> {
  late ChartType _chartType; // Line, Bar, hoặc Combination

  @override
  void initState() {
    super.initState();
    _chartType = ChartType.line;
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán dữ liệu hàng ngày
    Map<int, double> dailyIncome = {};
    Map<int, double> dailyExpense = {};

    for (var tx in widget.transactions) {
      int day = tx.date.day;
      if (tx.isIncome) {
        dailyIncome[day] = (dailyIncome[day] ?? 0) + tx.amount;
      } else {
        dailyExpense[day] = (dailyExpense[day] ?? 0) + tx.amount;
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart Type Selector (Segmented Button)
          Padding(
            padding: EdgeInsets.all(16),
            child: SegmentedButton<ChartType>(
              segments: [
                ButtonSegment(
                  value: ChartType.line,
                  label: Text('Line'),
                  icon: Icon(Icons.show_chart),
                ),
                ButtonSegment(
                  value: ChartType.bar,
                  label: Text('Bar'),
                  icon: Icon(Icons.bar_chart),
                ),
              ],
              selected: <ChartType>{_chartType},
              onSelectionChanged: (Set<ChartType> newSelection) {
                setState(() => _chartType = newSelection.first);
              },
            ),
          ),

          // Chart
          Padding(
            padding: EdgeInsets.all(16),
            child: _chartType == ChartType.line
                ? _buildLineChart(dailyIncome, dailyExpense)
                : _buildBarChart(dailyIncome, dailyExpense),
          ),

          // Legend
          _buildLegend(),

          // Statistics Card
          _buildStatisticsCard(dailyIncome, dailyExpense),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    Map<int, double> income,
    Map<int, double> expense,
  ) {
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];

    for (int i = 1; i <= 31; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), income[i] ?? 0));
      expenseSpots.add(FlSpot(i.toDouble(), expense[i] ?? 0));
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            // Thu Nhập (Xanh)
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Colors.green,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Chi Tiêu (Đỏ)
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Colors.red,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 5 == 0) {
                    return Text(value.toInt().toString());
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(
    Map<int, double> income,
    Map<int, double> expense,
  ) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 1; i <= 31; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income[i] ?? 0,
              color: Colors.green,
              width: 6,
            ),
            BarChartRodData(
              toY: expense[i] ?? 0,
              color: Colors.red,
              width: 6,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 5 == 0) {
                    return Text(value.toInt().toString());
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Chip(
            avatar: Container(width: 12, height: 12, color: Colors.green),
            label: Text('Thu Nhập'),
          ),
          SizedBox(width: 12),
          Chip(
            avatar: Container(width: 12, height: 12, color: Colors.red),
            label: Text('Chi Tiêu'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(
    Map<int, double> income,
    Map<int, double> expense,
  ) {
    double totalIncome = income.values.fold(0, (a, b) => a + b);
    double totalExpense = expense.values.fold(0, (a, b) => a + b);
    int transactionDays = [...income.keys, ...expense.keys].toSet().length;

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatisticItem('Trung Bình Thu', totalIncome / (transactionDays > 0 ? transactionDays : 1)),
                _StatisticItem('Trung Bình Chi', totalExpense / (transactionDays > 0 ? transactionDays : 1)),
                _StatisticItem('Ngày Giao Dịch', transactionDays.toDouble()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final String label;
  final double value;

  const _StatisticItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          _formatCurrency(value),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

enum ChartType { line, bar }
```

### 📊 Material 3 Chart Features

| Tính Năng | Triển Khai |
|-----------|-----------|
| **Dynamic Colors** | Sử dụng Material 3 ColorScheme (primary, secondary, tertiary) |
| **SegmentedButton** | Chuyển đổi giữa Line/Bar Chart |
| **Responsive** | fl_chart tự động responsive theo screen size |
| **Animations** | fl_chart có built-in animations |
| **Dark Mode** | Tự động thích ứng với Material 3 theme |
| **Typography** | Sử dụng Material 3 text styles |

---

## Xuất Báo Cáo PDF

### 📌 File Liên Quan

- **[lib/widgets/report_preview.dart](../lib/widgets/report_preview.dart)** - Preview UI
- **[lib/services/report_generator.dart](../lib/services/report_generator.dart)** - PDF generation
- **[lib/services/pdf_font_loader.dart](../lib/services/pdf_font_loader.dart)** - Font Unicode
- **[lib/services/file_export_helper_io.dart](../lib/services/file_export_helper_io.dart)** - File saving

### 🎨 UI Report Preview

```
┌─────────────────────────────────┐
│  📄 Xuất Báo Cáo                │
├─────────────────────────────────┤
│                                 │
│  Format:                        │
│  ◉ PDF      ○ CSV              │
│                                 │
│  Bao gồm:                      │
│  ☐ Tộng Hợp                    │
│  ☑ Chi Tiết Giao Dịch          │
│  ☑ Phân Tích Danh Mục          │
│                                 │
│      [Xuất] [Hủy]              │
│                                 │
│  📋 Xem Trước:                  │
│  ┌─────────────────────────┐   │
│  │ Báo Cáo Tháng 3/2026    │   │
│  │                         │   │
│  │ Tổng Thu:  10,000,000₫  │   │
│  │ Tổng Chi:   5,500,000₫  │   │
│  │ Số Dư:      4,500,000₫  │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

### 💻 Code Implementation

#### 1️⃣ ReportPreviewWidget - UI Container

```dart
class ReportPreviewWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Transaction> allTransactions;
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const ReportPreviewWidget({
    required this.transactions,
    required this.allTransactions,
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  State<ReportPreviewWidget> createState() => _ReportPreviewWidgetState();
}

class _ReportPreviewWidgetState extends State<ReportPreviewWidget> {
  // Export format selection
  ExportFormat _selectedFormat = ExportFormat.pdf;
  bool _isLoading = false;

  enum ExportFormat { pdf, csv }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1️⃣ Format Selection (Segmented Button)
          Padding(
            padding: EdgeInsets.all(16),
            child: SegmentedButton<ExportFormat>(
              segments: [
                ButtonSegment(
                  value: ExportFormat.pdf,
                  label: Text('📄 PDF'),
                  icon: Icon(Icons.picture_as_pdf),
                ),
                ButtonSegment(
                  value: ExportFormat.csv,
                  label: Text('📊 CSV'),
                  icon: Icon(Icons.table_chart),
                ),
              ],
              selected: <ExportFormat>{_selectedFormat},
              onSelectionChanged: (Set<ExportFormat> newSelection) {
                setState(() => _selectedFormat = newSelection.first);
              },
            ),
          ),

          // 2️⃣ Export Options (Checkboxes/Chips)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bao gồm:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text('Tổng Hợp'),
                      onSelected: (_) {},
                      selected: true,
                    ),
                    FilterChip(
                      label: Text('Chi Tiết Giao Dịch'),
                      onSelected: (_) {},
                      selected: true,
                    ),
                    FilterChip(
                      label: Text('Phân Tích Danh Mục'),
                      onSelected: (_) {},
                      selected: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // 3️⃣ Preview Section
          _buildPreviewSection(),

          SizedBox(height: 16),

          // 4️⃣ Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📋 Xem Trước', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildPreviewContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Báo Cáo Tháng ${widget.month}/${widget.year}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _PreviewItem('Tổng Thu Nhập', widget.totalIncome, Colors.green),
        _PreviewItem('Tổng Chi Tiêu', widget.totalExpense, Colors.red),
        _PreviewItem('Số Dư', widget.balance, Colors.blue),
        SizedBox(height: 12),
        Text(
          'Tổng Giao Dịch: ${widget.transactions.length}',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilledButton(
            icon: _isLoading ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ) : Icon(Icons.download),
            label: Text(_isLoading ? 'Đang xuất...' : 'Xuất'),
            onPressed: _isLoading ? null : _handleExport,
          ),
          OutlinedButton(
            icon: Icon(Icons.close),
            label: Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedFormat == ExportFormat.pdf) {
        await _exportPdf();
      } else {
        await _exportCsv();
      }
    } catch (e) {
      _showError('Lỗi: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportPdf() async {
    // Generate PDF
    final pdfData = await ReportGenerator.generatePdfReport(
      transactions: widget.transactions,
      totalIncome: widget.totalIncome,
      totalExpense: widget.totalExpense,
      balance: widget.balance,
      month: widget.month,
      year: widget.year,
    );

    // Save to file
    final savedPath = await exportReportFile(
      pdfData,
      'bao_cao_${widget.month}_${widget.year}.pdf',
    );

    if (mounted && savedPath != null) {
      // Mở file tự động
      await OpenFilex.open(savedPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF đã được lưu: $savedPath'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportCsv() async {
    // Generate CSV
    final csvData = ReportGenerator.generateCsvReport(widget.transactions);

    // Save to file
    final savedPath = await exportReportFile(
      Uint8List.fromList(csvData.codeUnits),
      'bao_cao_${widget.month}_${widget.year}.csv',
    );

    if (mounted && savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV đã được lưu: $savedPath'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _PreviewItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
```

#### 2️⃣ ReportGenerator - PDF Generation Logic

```dart
class ReportGenerator {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Tạo báo cáo PDF
  static Future<Uint8List> generatePdfReport({
    required List<Transaction> transactions,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required int month,
    required int year,
  }) async {
    // ⭐ Load font Unicode cho tiếng Việt
    final vietnamFont = await PdfFontLoader.loadRobotoFont();

    final pdf = pw.Document();

    // Build title & summary
    final title = '💰 Báo Cáo Tài Chính Tháng $month/$year';
    final summary = '''
Tổng Thu Nhập: ${_formatCurrency(totalIncome)}
Tổng Chi Tiêu: ${_formatCurrency(totalExpense)}
Số Dư: ${_formatCurrency(balance)}
''';

    // Group by category
    final Map<String, List<Transaction>> byCategory = {};
    for (var tx in transactions) {
      if (!byCategory.containsKey(tx.categoryName)) {
        byCategory[tx.categoryName] = [];
      }
      byCategory[tx.categoryName]!.add(tx);
    }

    // Add page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
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

          // Summary section
          pw.Paragraph(
            text: summary,
            style: pw.TextStyle(font: vietnamFont, fontSize: 12),
          ),
          pw.SizedBox(height: 20),

          // Transaction table
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

          // Category breakdown
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

  // Build transaction table
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
        // Header
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
                  child: pw.Text(
                    _dateFormat.format(tx.date),
                    style: pw.TextStyle(font: vietnamFont, fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    tx.title,
                    style: pw.TextStyle(font: vietnamFont, fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    tx.categoryName,
                    style: pw.TextStyle(font: vietnamFont, fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '${tx.isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}',
                    style: pw.TextStyle(font: vietnamFont, fontSize: 10),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  // Build category breakdown
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
            child: pw.Text(
              entry.key,
              style: pw.TextStyle(font: vietnamFont, fontSize: 11),
            ),
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

  // Generate CSV
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

  static String _formatCurrency(double amount) {
    try {
      return _currencyFormat.format(amount);
    } catch (e) {
      return '${amount.toStringAsFixed(0)} ₫';
    }
  }
}
```

#### 3️⃣ PdfFontLoader - Unicode Support

```dart
class PdfFontLoader {
  static pw.Font? _robotoFont;

  /// Load Roboto font từ assets
  static Future<pw.Font> loadRobotoFont() async {
    if (_robotoFont != null) return _robotoFont!;

    try {
      // Tải từ assets/fonts/static/Roboto-Regular.ttf
      final fontData = await rootBundle.load(
        'assets/fonts/static/Roboto-Regular.ttf',
      );
      _robotoFont = pw.Font.ttf(fontData);
      print('✅ Font loaded: Roboto-Regular');
      return _robotoFont!;
    } catch (e) {
      print('❌ Lỗi load font: $e');
      // Fallback: Helvetica (có hạn chế tiếng Việt)
      return pw.Font.helvetica();
    }
  }

  static pw.Font? getCurrentFont() => _robotoFont;
  static void resetFontCache() => _robotoFont = null;
}
```

### 📊 PDF Generation Flow

```
User Clicks "Xuất PDF"
    ↓
ReportPreviewWidget._exportPdf()
    ↓
ReportGenerator.generatePdfReport()
    ├─ PdfFontLoader.loadRobotoFont()
    │  └─ Load assets/fonts/static/Roboto-Regular.ttf
    ├─ Create PDF Document
    ├─ Add Title + Summary (Tiêu đề, Tổng Thu Chi, Số Dư)
    ├─ Add Transaction Table (Ngày, Tiêu đề, Danh mục, Số tiền)
    ├─ Add Category Breakdown (Phân tích danh mục)
    └─ Return Uint8List (PDF bytes)
    ↓
exportReportFile(pdfData, filename)
    ├─ Đặc định vị trí (Hive path selection)
    ├─ Ghi file PDF vào Downloads/Documents
    └─ Return file path
    ↓
OpenFilex.open(savedPath)
    └─ Mở file PDF tự động bằng default app
    ↓
User thấy báo cáo PDF hiển thị ✅
```

---

## Luồng Dữ Liệu Toàn Bộ

### 🔄 Complete Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interface Layer                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  AnalysisScreen (3 Tabs)                                  │
│  ├── Tab 1: Dashboard (Overview Page)                    │
│  │   ├── DashboardOverviewWidget                         │
│  │   │   ├── Summary Cards (Income/Expense/Balance)     │
│  │   │   ├── ExpensePieChart                            │
│  │   │   └── Category Breakdown List                    │
│  │                                                      │
│  ├── Tab 2: Trend Analysis                              │
│  │   └── TrendChartWidget                               │
│  │       ├── Chart Type Selector (Line/Bar)             │
│  │       ├── Line/Bar Chart Display                     │
│  │       └── Statistics Card                            │
│  │                                                      │
│  └── Tab 3: Report Preview                              │
│      └── ReportPreviewWidget                            │
│          ├── Format Selector (PDF/CSV)                  │
│          ├── Export Options (Checkboxes)                │
│          ├── Preview Section                            │
│          └── Action Buttons (Export/Cancel)             │
│                                                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   State Management Layer                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ExpenseProvider (ChangeNotifier)                          │
│  ├── getTransactionsByMonth(month, year)                 │
│  │   └─ Filter + Return transactions                    │
│  ├── getTransactionsByCategory(category)                │
│  ├── Categories list                                    │
│  └── Statistics (income, expense, balance)              │
│                                                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ReportGenerator                                           │
│  ├── generatePdfReport() → Uint8List                      │
│  │   ├─ Calculate summary stats                          │
│  │   ├─ Group by category                                │
│  │   └─ Create PDF with tables & charts                  │
│  └── generateCsvReport() → String                        │
│                                                         │
│  PdfFontLoader                                           │
│  └── loadRobotoFont() → pw.Font (Unicode support)       │
│                                                         │
│  FileExportHelper                                        │
│  └── exportReportFile(bytes) → filePath                 │
│                                                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Data Access Layer                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  LocalRepository                                           │
│  ├── getAllTransactions() → List<Transaction>             │
│  ├── getTransactionsByMonth(m, y) → List<Transaction>    │
│  └── getCategories() → List<Category>                    │
│                                                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Persistence Layer                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Hive Database                                             │
│  ├── transactions_box → Transaction objects              │
│  ├── categories_box → Category objects                   │
│  ├── budgets_box → Budget objects                        │
│  └── limits_box → Limit objects                          │
│                                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Material 3 Design Principles

### 🎨 Design Tokens & Components

#### Color System
```dart
// Primary Colors (Brand)
primary: 0xFF6200EE      // Deep Purple
onPrimary: 0xFFFFFFFF    // White text on primary

// Secondary Colors (Supporting)
secondary: 0xFF03DAC6    // Teal
onSecondary: 0xFF000000  // Black text on secondary

// Tertiary Colors (Accent)
tertiary: 0xFF018786     // Cyan
onTertiary: 0xFFFFFFFF

// Status Colors
error: 0xFFB3261E        // Red
success: 0xFF4CAF50      // Green (custom)
```

#### Components Used

| Component | Sử Dụng | Mục Đích |
|-----------|--------|---------|
| **SegmentedButton** | Chart/Format selector | Material 3 choice UI |
| **FilledButton** | Export action | Primary action |
| **OutlinedButton** | Cancel action | Secondary action |
| **FilterChip** | Export options | Multi-select |
| **Card** | Summary cards, Cards container | Elevation & grouping |
| **Chip** | Legend, Category filters | Compact labels |
| **LinearProgressIndicator** | Category breakdown | Visual % | **TabBar** | Tab navigation | Switching between views |
| **SegmentedButton** | Theme switching | Material 3 choice |

#### Typography

```dart
// Display Large - Page titles
displayLarge: fontSize 57, fontWeight 400, letterSpacing -0.25

// Headline Large - Section headers
headlineLarge: fontSize 32, fontWeight 700

// Title Large - Card titles
titleLarge: fontSize 22, fontWeight 500

// Title Medium - Widget titles
titleMedium: fontSize 16, fontWeight 500

// Body Large - Main content
bodyLarge: fontSize 16, fontWeight 400

// Body Small - Annotations
bodySmall: fontSize 12, fontWeight 400
```

#### Spacing & Layout

```dart
// Material 3 Standard Spacing
const double spacing4 = 4.0;
const double spacing8 = 8.0;
const double spacing12 = 12.0;
const double spacing16 = 16.0;
const double spacing20 = 20.0;
const double spacing24 = 24.0;
```

### 📐 Responsive Design

```dart
// Breakpoints (Material 3)
// Compact: < 600 dp (Phone)
// Medium: 600-840 dp (Tablet vertical)
// Expanded: > 840 dp (Tablet horizontal)

double getMaxWidth(BuildContext context) {
  var width = MediaQuery.of(context).size.width;
  if (width < 600) return 180; // Compact
  if (width < 840) return 200; // Medium
  return 250; // Expanded
}
```

### 🌓 Dark Mode Support

```dart
// Automatic via Material 3 theme
class SmartSpendApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6200EE),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6200EE),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system, // System theme
    );
  }
}
```

---

## 🔑 Key Takeaways

### ✅ Dashboard
- Tóm tắt tài chính nhanh chóng (3 thẻ chính)
- Biểu đồ tròn phân tích danh mục chi tiêu
- Danh sách chi tiết phần trăm chi chi tiêu

### ✅ Biểu Đồ Material 3
- fl_chart library với Line/Bar chart
- SegmentedButton cho chuyển đổi loại chart
- Responsive, dark mode, animations tự động
- Legend + Statistics card

### ✅ Xuất Báo Cáo PDF
- PDF generation với Unicode font (Roboto)
- Hỗ trợ tiếng Việt + ký tự ₫ đầy đủ
- CSV export alternative
- Auto-open file sau khi save

### ✅ State Management
- Provider pattern với ChangeNotifier
- Data filtering & computation
- Chart data preparation

### ✅ Material 3 Design
- Dynamic colors, responsive, dark mode
- Modern components (SegmentedButton, FilterChip)
- Proper spacing & typography
- Accessible color contrast

---

**🎉 Báo cáo chi tiết hoàn thành!**
