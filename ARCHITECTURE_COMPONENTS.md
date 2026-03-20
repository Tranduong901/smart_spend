# Smart Spend - Architecture & Components Reference

## Visual Component Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                         Smart Spend App                         │
│                        (Material 3 Themed)                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
         ┌──────▼─────┐ ┌────▼───┐ ┌────▼──────┐
         │  Dashboard │ │ Home   │ │  Analysis │
         │   Screen   │ │ Screen │ │  Screen   │
         └──────┬─────┘ └────┬───┘ └────┬──────┘
                │            │         │
    ┌───────────┼────────────┴─────────┼────────────┐
    │           │                      │            │
┌───▼────┐  ┌──▼────┐  ┌──────────┐  ┌▼──────────┐
│Exchange│  │Recent │  │Dashboard │  │ Pie      │
│Rate    │  │Transac│  │Overview  │  │ Chart    │
│Card    │  │tions  │  │Widget    │  │ Widget   │
└────────┘  └───────┘  └──────────┘  └──────────┘
    │           │          │            │
    └───────────┼──────────┼────────────┘
                │          │
         ┌──────▼──────────▼──────────┐
         │  Analysis Screen Sections  │
         ├────────────────────────────┤
         │ [Overview] [Trend] [Report]│
         └──────┬──────────┬────┬─────┘
                │          │    │
         ┌──────▼──┐ ┌────▼──┐ │
         │ Category│ │ Trend │ │
         │Breakdown│ │ Chart │ │
         │Widget   │ │Widget │ │
         └─────────┘ └───────┘ │
                               │
                          ┌────▼──────────┐
                          │Report Preview │
                          │  Widget       │
                          │(PDF/CSV)      │
                          └───────────────┘
```

---

## Data Flow Architecture

```
┌────────────────────────────────────────────────────────────┐
│                      USER INTERACTION                       │
│  (Add Transaction, View Report, Switch Chart Type, etc.)   │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────────┐
        │   Screen / Widget State            │
        │  (setState, AnimationController)   │
        └────────────────┬───────────────────┘
                         │
                         ▼
        ┌────────────────────────────────────┐
        │   ExpenseProvider (Main State)     │
        │  context.watch / context.read      │
        │                                    │
        │  - transactions[]                  │
        │  - startingBalance                 │
        │  - expenseCategories[]             │
        │  - monthlyBudgetLimit              │
        │  - limits[]                        │
        └────────────┬───────────────────────┘
                     │
        ┌────────────┼────────────────┐
        │            │                │
        ▼            │                ▼
   ┌─────────────┐   │          ┌──────────────────┐
   │ Calculation │   │          │ Notification     │
   │ Methods:    │   │          │ (Budget alerts)  │
   │ - Calculate │   │          └──────────────────┘
   │   Balance   │   │
   │ - Filter    │   │
   │   Category  │   │
   └─────────────┘   │
                     ▼
        ┌────────────────────────────────────┐
        │   LocalRepository                  │
        │  (Data Access Layer)               │
        │                                    │
        │  - readTransactions()              │
        │  - createTransaction()             │
        │  - updateTransaction()             │
        │  - deleteTransaction()             │
        │  - getStartingBalance()            │
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │   Hive Local Storage               │
        │  (NoSQL Database)                  │
        │                                    │
        │  Boxes:                            │
        │  - transactionsBox                 │
        │  - categoriesExpenseBox            │
        │  - categoriesIncomeBox             │
        │  - preferencesBox                  │
        └────────────────────────────────────┘
```

---

## Charts Rendering Pipeline

### Pie Chart Flow
```
Analysis Screen (Report Tab)
    │
    └─→ ExpensePieChart Widget
        │
        ├─→ Consumer<ExpenseProvider>()
        │   │
        │   ├─ Get transactions
        │   │
        │   └─ Filter: (currentMonth && !isIncome)
        │
        ├─→ _calculateCategoryTotals()
        │   │
        │   └─ Group by categoryName
        │      └─ Sum amounts per category
        │
        ├─→ Map Material 3 ColorScheme
        │   ├─ primary (Category 1)
        │   ├─ secondary (Category 2)
        │   ├─ tertiary (Category 3)
        │   ├─ error (Category 4)
        │   └─ outline (Category 5+)
        │
        └─→ fl_chart PieChart Widget
            ├─ PieChartData(
            │   centerSpaceRadius: 36,
            │   sectionsSpace: 2,
            │   sections: [
            │     PieChartSectionData(
            │       value: category.total,
            │       title: categoryName,
            │       color: colorScheme.primary,
            │       radius: 56,
            │     ),
            │     ...
            │   ]
            │ )
            │
            └─→ _LegendRow widget
                └─ Colored circle + category name
```

### Trend Chart Flow
```
Analysis Screen (Trend Tab)
    │
    └─→ TrendChartWidget
        │
        ├─→ State: _selectedPeriod, _chartType
        │
        ├─→ Period Selector UI
        │   ├─ FilterChips: Day | Week | Month | Quarter | Year
        │   └─ setState → _getTrendData()
        │
        ├─→ Chart Type Selector UI
        │   ├─ ChoiceChips: Dòng (Line) | Cột (Bar)
        │   └─ setState → rebuild
        │
        ├─→ _getTrendData()
        │   │
        │   ├─ Group transactions by period
        │   │   (e.g., month: group by date → sum daily totals)
        │   │
        │   ├─ Create TrendData:
        │   │   ├─ labels[] → period names
        │   │   ├─ incomeSpots[] → [FlSpot(x, y), ...]
        │   │   └─ expenseSpots[] → [FlSpot(x, y), ...]
        │   │
        │   └─ Return TrendData
        │
        ├─→ if (_chartType == Line):
        │   │
        │   └─→ _buildLineChart(data)
        │       │
        │       └─ LineChart(
        │           LineChartData(
        │             lineBarsData: [
        │               LineChartBarData(  // Income series
        │                 spots: data.incomeSpots,
        │                 isCurved: true,
        │                 color: Colors.green,
        │                 barWidth: 2,
        │               ),
        │               LineChartBarData(  // Expense series
        │                 spots: data.expenseSpots,
        │                 isCurved: true,
        │                 color: Colors.red,
        │                 barWidth: 2,
        │               ),
        │             ],
        │             gridData: FlGridData(show: true),
        │             titlesData: FlTitlesData(...),
        │             lineTouchData: LineTouchData(enabled: true),
        │           )
        │         )
        │
        └─→ else if (_chartType == Bar):
            │
            └─ _buildBarChart(data)
                │
                └─ BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(toY: incomeY, color: Colors.green),
                            BarChartRodData(toY: expenseY, color: Colors.red),
                          ]
                        ),
                        ...
                      ]
                    )
                  )
```

---

## PDF Report Generation Pipeline

```
ReportPreviewWidget
    │
    └─→ User clicks "Xuất PDF"
        │
        ├─ setState(_isLoading = true)
        │
        ├─ Get selected transactions:
        │  ├─ if (_exportAllMonths)
        │  │  └─ widget.allTransactions
        │  │
        │  └─ else
        │     └─ widget.transactions (current month)
        │
        └─→ ReportGenerator.generatePdfReport()
            │
            ├─→ PdfFontLoader.loadRobotoFont()
            │   │
            │   ├─ Check cache: _robotoFont != null?
            │   │
            │   └─ Load from assets:
            │      └─ rootBundle.load('assets/fonts/static/Roboto-Regular.ttf')
            │         ├─ Parse TTF format
            │         ├─ Extract glyph table (Vietnamese diacritics + ₫)
            │         └─ Create pw.Font instance
            │
            ├─→ Create PDF Document
            │   └─ pw.Document()
            │
            ├─→ Build Page Content
            │   │
            │   ├─ Header Section:
            │   │  └─ Title: "Báo Cáo Tài Chính Tháng M/YYYY"
            │   │
            │   ├─ Summary Section:
            │   │  ├─ Tổng Thu Nhập: [formatted amount] ₫
            │   │  ├─ Tổng Chi Tiêu: [formatted amount] ₫
            │   │  └─ Số Dư: [formatted amount] ₫
            │   │
            │   ├─ Transaction Table:
            │   │  └─ _buildTransactionTable(transactions, vietnamFont)
            │   │     │
            │   │     └─ pw.Table(
            │   │         columns: [Date | Title | Category | Amount],
            │   │         rows: [
            │   │           {"Ngày": "16/03/2024", "Tiêu Đề": "...", ...},
            │   │           ...
            │   │         ],
            │   │         apply font: vietnamFont to all cells
            │   │       )
            │   │
            │   └─ Category Breakdown Table:
            │      └─ _buildCategoryBreakdown(byCategory, vietnamFont)
            │         │
            │         ├─ Group transactions by category
            │         │
            │         └─ pw.Table(
            │               columns: [Category | Total Amount],
            │               rows: [
            │                 {"Danh Mục": "Ăn uống", "Tổng Tiền": "2.500.000 ₫"},
            │                 ...
            │               ]
            │             )
            │
            ├─→ Apply Unicode Font
            │   │
            │   └─ All text elements use vietnamFont
            │      ├─ Vietnamese diacritics: á, à, ả, ã, ạ, etc.
            │      ├─ Vietnamese Dong: ₫ (U+20AB)
            │      └─ Proper rendering in PDF viewers
            │
            └─→ Export to Bytes
                └─ Uint8List pdfBytes = pdf.save()
                    │
                    ├─ PDF binary format
                    ├─ Compressed (optional)
                    └─ Ready for file storage
                        │
                        └─→ FileExportHelper.saveBytesAsFile()
                            │
                            ├─ Platform Detection:
                            │  ├─ kIsWeb? → Web download
                            │  ├─ Platform.isAndroid? → Android Downloads/
                            │  ├─ Platform.isIOS? → iOS Documents/
                            │  └─ else → Show dialog
                            │
                            ├─ Create file:
                            │  └─ File('${downloadPath}/report_3_2024.pdf')
                            │
                            ├─ Write bytes:
                            │  └─ file.writeAsBytes(pdfBytes)
                            │
                            └─→ OpenFileX.open(filePath)
                                │
                                └─ System PDF viewer
                                   └─ User sees formatted report
```

---

## Export Workflow (CSV & PDF)

```
Report Preview Screen
    │
    ├─→ User Action: Click Button
    │   │
    │   ├─ "Xuất PDF"
    │   │  └─→ _exportPDF()
    │   │     └─ ReportGenerator.generatePdfReport(...)
    │   │
    │   ├─ "Xuất CSV"
    │   │  └─→ _exportCSV()
    │   │     └─ ReportGenerator.generateCsvReport(...)
    │   │
    │   └─ "Xem lại"
    │      └─→ _exportAndPreview()
    │         └─ OpenFileX.open(filePath)
    │
    ├─→ Report Scope Selection
    │   │
    │   ├─ if (hasCurrentMonth)
    │   │  └─ Export current month transactions only
    │   │
    │   ├─ else if (hasAllTransactions)
    │   │  └─ Show: CheckboxListTile "Xuất tất cả các tháng"
    │   │     └─ User toggles _exportAllMonths
    │   │
    │   └─ Calculate summary:
    │      ├─ totalIncome = sum(tx where isIncome)
    │      ├─ totalExpense = sum(tx where !isIncome)
    │      └─ balance = totalIncome - totalExpense
    │
    └─→ Display Summary Card (_SummaryCard)
        │
        ├─ Month/Year label (or "Tất cả các tháng")
        ├─ Tổng Thu Nhập
        ├─ Tổng Chi Tiêu
        └─ Số Dư
```

---

## Material 3 Component Usage

### Button Components
```
┌─────────────────────────────────────────────────────────┐
│ FilledButton (Primary Action)                           │
│ ─────────────────────────────────────────────────────── │
│ Usage: "Save", "Export", "Confirm action"              │
│ Example:                                                │
│   FilledButton(                                         │
│     onPressed: () => _exportPDF(),                      │
│     child: Text('Xuất PDF'),                            │
│   )                                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ TextButton (Secondary Action)                           │
│ ─────────────────────────────────────────────────────── │
│ Usage: "Cancel", "Discard", "Back"                      │
│ Example:                                                │
│   TextButton(                                           │
│     onPressed: () => Navigator.pop(context),            │
│     child: Text('Huỷ'),                                 │
│   )                                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ SegmentedButton (Multiple Options Selection)            │
│ ─────────────────────────────────────────────────────── │
│ Usage: Analysis tabs (Overview | Trend | Report)        │
│ Example:                                                │
│   SegmentedButton<_AnalysisSection>(                    │
│     segments: [                                         │
│       ButtonSegment(value: .overview, label: ...),      │
│       ButtonSegment(value: .trend, label: ...),         │
│       ButtonSegment(value: .report, label: ...),        │
│     ],                                                  │
│     selected: {_selectedSection},                       │
│   )                                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ FilterChip (Filter Selection)                           │
│ ─────────────────────────────────────────────────────── │
│ Usage: Trend period selection (Month | Week | ...      │
│ Example:                                                │
│  FilterChip(                                            │
│    label: Text('Tháng'),                                │
│    selected: _selectedPeriod == TrendPeriod.month,      │
│    onSelected: (selected) { setState(...) }             │
│  )                                                       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ ChoiceChip (Single Choice Selection)                    │
│ ─────────────────────────────────────────────────────── │
│ Usage: Chart type selection (Line | Bar)               │
│ Example:                                                │
│  ChoiceChip(                                            │
│    label: Text('Dòng'),                                 │
│    selected: _chartType == TrendChartType.line,         │
│    onSelected: (selected) { setState(...) }             │
│  )                                                       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ IconButton (Icon-based Action)                          │
│ ─────────────────────────────────────────────────────── │
│ Usage: Edit balance, refresh, menu actions             │
│ Example:                                                │
│  IconButton(                                            │
│    icon: Icon(Icons.edit_outlined),                     │
│    tooltip: 'Chỉnh số dư',                              │
│    onPressed: () => _editStartingBalance(),             │
│  )                                                       │
└─────────────────────────────────────────────────────────┘
```

### Card Components
```
┌────────────────────────────────────┐
│ Material 3 Card                    │
│ ────────────────────────────────── │
│ Elevation: 1 (subtle shadow)       │
│ Color: Surface color (theme-aware) │
│                                    │
│ Usage: Containers for content      │
│  - Balance Card                    │
│  - Summary Cards                   │
│  - Exchange Rate Card              │
│  - Dashboard Overview              │
│  - Chart containers                │
└────────────────────────────────────┘
```

---

## State Management Pattern

### ChangeNotifier Pattern Flow

```
┌──────────────────────────────────┐
│   ExpenseProvider Class           │
│   extends ChangeNotifier          │
│                                  │
│  Properties:                     │
│  - _transactions                 │
│  - _startingBalance             │
│  - _expenseCategories           │
│  - _incomeCategories            │
│  - _limits                      │
│  - _monthlyBudgetLimit          │
│                                 │
│  Methods:                       │
│  - addTransaction()             │
│  - updateTransaction()          │
│  - deleteTransaction()          │
│  - setStartingBalance()         │
│  - loadTransactions()           │
│  - calculateTotalBalance()      │
│                                 │
│  Notification:                  │
│  - notifyListeners() ←┐         │
└────────────────────────┼────────┘
                         │
            ┌────────────┘
            │
    ┌───────▼──────────────┐
    │  Add to ProviderScope │
    │                      │
    │ MultiProvider(       │
    │   providers: [       │
    │     ChangeNotifier   │
    │     Provider(...)    │
    │   ]                  │
    │ )                    │
    └───────┬──────────────┘
            │
    ┌───────▼──────────────┐
    │  Widget Tree         │
    │  Has Access via:     │
    │                      │
    │  1. Consumer<T>()    │
    │  2. context.watch()  │
    │  3. context.read()   │
    └───────┬──────────────┘
            │
    ┌───────▼──────────────┐
    │  UI Rebuilds         │
    │  Only when:          │
    │  notifyListeners()   │
    │  is called           │
    └──────────────────────┘
```

---

## Data Persistence with Hive

```
┌─────────────────────────────────────┐
│   Local Repository Initialization    │
│   (main.dart)                        │
└────────┬────────────────────────────┘
         │
    ┌────▼────────────────────┐
    │ await Hive.initFlutter() │
    └────┬────────────────────┘
         │
    ┌────▼──────────────────────────────────┐
    │ Register TypeAdapters                │
    │                                      │
    │ Hive.registerAdapter(                │
    │   TransactionAdapter()   typeId: 0   │
    │ )                                    │
    │                                      │
    │ Hive.registerAdapter(                │
    │   CategoryAdapter()      typeId: 1   │
    │ )                                    │
    └────┬──────────────────────────────────┘
         │
    ┌────▼──────────────────────────────────┐
    │ Open Hive Boxes                      │
    │                                      │
    │ Box<Transaction>:                    │
    │   'transactions' ← all transactions  │
    │                                      │
    │ Box<Category>:                       │
    │   'expenseCategories'← expense cats  │
    │   'incomeCategories' ← income cats   │
    │                                      │
    │ Box (dynamic):                       │
    │   'preferences' ← app settings       │
    └────┬──────────────────────────────────┘
         │
    ┌────▼────────────────────────┐
    │ Available for App Runtime   │
    │                             │
    │ LocalRepository.readAll()   │
    │ LocalRepository.create()    │
    │ LocalRepository.update()    │
    │ LocalRepository.delete()    │
    └─────────────────────────────┘
```

---

## Vietnamese Language Integration

### Text Localization
```
All UI strings are hardcoded in Vietnamese:
- Screens: "Phân tích tài chính" (Financial Analysis)
- Buttons: "Xuất PDF" (Export PDF), "Lưu" (Save)
- Labels: "Tổng Thu Nhập" (Total Income), "Số Dư" (Balance)
- Messages: "Chưa có dữ liệu" (No data)

Note: Future i18n via flutter_localizations
      requires .arb files in l10n/ directory
```

### Currency Formatting
```
Input: 5000000.0 (double)
    │
    └─→ _formatCurrency()
        │
        ├─ DecimalFormat with grouping:
        │  Numbers: "5.000.000"
        │
        └─ Append currency symbol:
           Output: "5.000.000 ₫"
           
Unicode Character: U+20AB (Vietnamese Dong)
```

### Date Formatting
```
Input: DateTime(2024, 3, 16)
    │
    └─→ DateFormat('dd/MM/yyyy').format()
        │
        └─ Output: "16/03/2024"
```

---

## Quick Component Reference

| Component | File | Purpose | Material 3 Feature |
|-----------|------|---------|-------------------|
| AnalysisScreen | screens/analysis_screen.dart | Hub for financiaanalysis | SegmentedButton |
| TrendChartWidget | widgets/trend_chart.dart | Line/bar chart visualization| - |
| ExpensePieChart | widgets/expense_pie_chart.dart | Category breakdown pie | ColorScheme |
| ReportGenerator | services/report_generator.dart | PDF & CSV generation | - |
| PdfFontLoader | services/pdf_font_loader.dart | Unicode font management | - |
| ReportPreviewWidget | widgets/report_preview.dart | Export UI | FilledButton, Cards |
| DashboardOverviewWidget | widgets/dashboard_overview.dart | Financial summary | Cards, Colors |
| CategoryBreakdown | widgets/category_breakdown.dart | Expense breakdown | Icons, Colors |
| BalanceCard | widgets/balance_card.dart | Current balance display | Card, Typography |
| ExpenseProvider | providers/expense_provider.dart | Central state management | ChangeNotifier |
| LocalRepository | repositories/local_repository.dart | Data persistence layer | Hive TypeAdapter |

---

## Performance Metrics & Optimization Tips

### Current Implementation
- ✅ **Font Caching:** PdfFontLoader caches TTF fonts in memory
- ✅ **Lazy Loading:** Charts only render when tab selected
- ✅ **Unmodifiable Lists:** Prevents accidental state mutations
- ✅ **Hive Indexing:** Fast local lookups

### Potential Improvements
- Consider: Pagination for 1000+ transactions
- Consider: Virtual scrolling for transaction lists
- Consider: Debouncing for frequent calculations
- Consider: Isolate PDF generation to background thread

---

## Troubleshooting Guide

### PDF Not Generated
- ❌ Font file missing: Check `assets/fonts/static/Roboto-Regular.ttf`
- ❌ Font not loaded: Ensure `PdfFontLoader.loadRobotoFont()` called first
- ❌ Unicode characters corrupted: Verify TTF font includes Vietnamese glyphs

### Charts Not Rendering
- ❌ Empty transactions: Filter check currentMonth only
- ❌ fl_chart version mismatch: Check pubspec.yaml (^0.69.0)
- ❌ Data type error: Ensure transaction amounts are double, not int

### Export Failed
- ❌ File path error: Verify platform-specific path in FileExportHelper
- ❌ Permission denied: Check AndroidManifest.xml write permission
- ❌ File already exists: Add timestamp to filename

---

## Next Steps for Development

### Recommended Enhancements
1. **Biometric Authentication**
   - File: Create `services/auth_service.dart`
   - Use: `local_auth` package
   - Scope: Protect app launch + sensitive operations

2. **Cloud Sync**
   - File: Create `repositories/cloud_repository.dart`
   - Use: Firebase Firestore
   - Scope: Backup & cross-device sync

3. **Advanced Charts**
   - Candlestick charts for budget vs actual
   - Sankey diagrams for cash flow
   - Scatter plots for correlations

4. **Receipt OCR**
   - File: Expand `widgets/receipt_capture_button.dart`
   - Use: `google_mlkit_text_recognition` or `tesseract`
   - Feature: Auto-fill transaction from receipt

5. **Notifications**
   - File: Extend `services/budget_notification.dart`
   - Use: `flutter_local_notifications`
   - Triggers: Budget warnings, recurring reminders

6. **Data Export Enhancements**
   - Excel/XLSX support via `xlsx` package
   - Email integration via `mailer` package
   - Cloud storage (Google Drive, Dropbox)

---

**Document generated for:** Smart Spend v1.0.0
**Framework:** Flutter 3.x
**Design System:** Material 3
**Target Platforms:** Android, iOS, Web, Windows, macOS, Linux
