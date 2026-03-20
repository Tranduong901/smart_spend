# Smart Spend - Codebase Exploration Report

## Overview
Smart Spend is a Flutter-based personal finance management application with Material 3 design. It provides comprehensive financial tracking, detailed charts, trend analysis, and PDF report generation capabilities.

---

## 1. Project Architecture & Structure

### Directory Structure
```
lib/
├── main.dart                          # App entry point & initialization
├── adapters/                          # Hive TypeAdapters for serialization
│   ├── transaction_adapter.dart
│   └── category_adapter.dart
├── models/                            # Data models
│   ├── transaction.dart              # Income/expense transaction
│   ├── category.dart                 # Category with color, icon
│   ├── budget.dart                   # Budget model
│   └── limit.dart                    # Spending limit model
├── providers/                         # State management (Provider)
│   └── expense_provider.dart         # Central state management
├── repositories/                      # Data access layer
│   ├── local_repository.dart         # Hive local storage
│   └── exchange_rate_repository.dart # External API rates
├── screens/                           # Full-screen widgets (Pages)
│   ├── home_screen.dart              # Transaction history view
│   ├── dashboard_screen.dart         # Welcome/overview screen
│   ├── analysis_screen.dart          # Charts & reports (Main hub)
│   ├── add_transaction_screen.dart   # Transaction input form
│   ├── history_screen.dart           # Extended history
│   └── limits_screen.dart            # Budget/limit management
├── services/                          # Business logic services
│   ├── report_generator.dart         # PDF & CSV generation 🎯
│   ├── pdf_font_loader.dart          # Vietnamese font support 🎯
│   ├── budget_notification.dart      # Budget alerts
│   ├── file_export_helper.dart       # Platform-specific export
│   ├── file_export_helper_io.dart    # iOS/Android file export
│   ├── file_export_helper_web.dart   # Web file export
│   └── file_export_helper_stub.dart  # Fallback stub
├── widgets/                           # Reusable UI components
│   ├── expense_pie_chart.dart        # fl_chart PieChart 📊
│   ├── trend_chart.dart              # fl_chart LineChart/BarChart 📊
│   ├── category_breakdown.dart       # Category expense list
│   ├── dashboard_overview.dart       # Financial summary cards
│   ├── report_preview.dart           # Report PDF/CSV preview 📋
│   ├── balance_card.dart             # Current balance display
│   ├── exchange_rate_card.dart       # USD/VND exchange rates
│   ├── recent_transactions_list.dart # Recent activity
│   ├── transaction_tile.dart         # Transaction list item
│   ├── history_filter_bar.dart       # Date/category filters
│   ├── dynamic_category_selector.dart # Category picker
│   ├── category_selector.dart        # Static category picker
│   └── receipt_capture_button.dart   # OCR receipt button
└── assets/
    └── fonts/static/                 # Roboto TTF for Vietnamese
```

---

## 2. Key Components Breakdown

### 2.1 Dashboard/Home Screens

#### **AnalysisScreen** (Main Dashboard Hub)
**Location:** `lib/screens/analysis_screen.dart`

- **Purpose:** Central hub for financial analysis with 3 tabbed sections
- **Sections:**
  1. **Overview** - Financial summary and category breakdown
  2. **Trend** - Time-series income/expense trends
  3. **Report** - PDF/CSV export functionality
  
- **Key Features:**
  ```dart
  _AnalysisSection.overview   → DashboardOverviewWidget + ExpensePieChart + CategoryBreakdown
  _AnalysisSection.trend      → TrendChartWidget (Line/Bar charts)
  _AnalysisSection.report     → ReportPreviewWidget (Export options)
  ```
  
- **Data Processing:**
  - Filters current month transactions
  - Calculates expense change % vs previous month
  - Separates income/expense for analysis
  - Uses Material 3 SegmentedButton for section selection with smooth AnimatedSwitcher transitions

#### **DashboardScreen** (Welcome Screen)
**Location:** `lib/screens/dashboard_screen.dart`

- **Purpose:** App entry point showing quick overview
- **Components:**
  - ExchangeRateCard - USD/VND conversion rates
  - BalanceCard - Total balance with starting balance edit
  - RecentTransactionsList - Last 5 transactions
  
- **Design:** Material 3 Cards with proper spacing and typography

#### **HomeScreen** (Transaction History)
**Location:** `lib/screens/home_screen.dart`

- **Purpose:** Browse all transactions with filtering
- **Features:**
  - Month/year selector
  - Search by title
  - Edit/delete transactions
  - Starting balance editor

---

### 2.2 Chart Visualization Widgets (fl_chart Library)

#### **ExpensePieChart** ✨
**Location:** `lib/widgets/expense_pie_chart.dart`

```dart
// Dependencies
import 'package:fl_chart/fl_chart.dart';

// Key Implementation
- Aggregates current month transactions by category
- Uses Material 3 colorScheme (primary, secondary, tertiary, error, outline)
- Cyclic color assignment for multiple categories
- Center space radius: 36px, sections space: 2px
- Custom legend with colored circles
- Empty state: "Chưa có dữ liệu chi tiêu"
```

**Flow:**
```
ExpensePieChart
├── Input: List<Transaction> for current month
├── Process: Group by categoryName → calculate totals
├── Output: PieChart with sections
└── Legend: Category names with color indicators
```

**Integration with Material 3:**
```dart
final colorScheme = Theme.of(context).colorScheme;
// Uses: primary, secondary, tertiary, error, outline
// Respects theme light/dark modes automatically
```

#### **TrendChartWidget** 📈
**Location:** `lib/widgets/trend_chart.dart`

```dart
// Key Features
enum TrendPeriod { day, week, month, quarter, year }
enum TrendChartType { line, bar }

// Functionality:
1. Period Selector (FilterChips)
   - Day | Week | Month | Quarter | Year
   - Dynamically calculates aggregated data

2. Chart Type Selector (ChoiceChips)
   - Line Chart (curved, with dots)
   - Bar Chart (grouped bars)

3. Data Visualization
   - Y-axis: Currency in millions (M format)
   - X-axis: Time labels (dates/weeks/months)
   - Two series: Income (green) vs Expense (red)
   - Interactive tooltips
```

**LineChart Implementation:**
```dart
LineChartData(
  gridData: FlGridData(show: true),
  titlesData: FlTitlesData(...),
  borderData: FlBorderData(show: true),
  lineBarsData: [
    LineChartBarData(  // Income line - green
      spots: data.incomeSpots,
      isCurved: true,
      color: Colors.green,
    ),
    LineChartBarData(  // Expense line - red
      spots: data.expenseSpots,
      isCurved: true,
      color: Colors.red,
    ),
  ],
  lineTouchData: LineTouchData(enabled: true),
)
```

**BarChart Implementation:**
```dart
BarChartData(
  barGroups: [
    BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(toY: incomeValue, color: Colors.green),
        BarChartRodData(toY: expenseValue, color: Colors.red),
      ],
    ),
  ],
  barTouchData: BarTouchData(enabled: true),
)
```

---

### 2.3 Financial Summary & Analysis Widgets

#### **DashboardOverviewWidget**
**Location:** `lib/widgets/dashboard_overview.dart`

**Purpose:** Display key financial statistics and top categories

**Statistics Calculated:**
```
- Total Income (current month)
- Total Expense (current month)
- Net Balance (Income - Expense)
- Transaction Count
- Average Daily Spending
- Top 3 Categories by amount
```

**UI Layout:**
```
┌─────────────────────────────────────┐
│  [Total Income]  [Total Expense]    │
│      Colors: Green      Red         │
├─────────────────────────────────────┤
│  Net Balance: [Amount] (Blue Card)  │
├─────────────────────────────────────┤
│  Detailed Statistics:               │
│  • Average: [value] ₫/day          │
│  • Count: [n] transactions         │
├─────────────────────────────────────┤
│  Top Categories:                    │
│  1. Category A: 5,000,000 ₫        │
│  2. Category B: 3,500,000 ₫        │
│  3. Category C: 2,100,000 ₫        │
└─────────────────────────────────────┘
```

**Material 3 Features:**
- Responsive Card layouts
- Color scheme: primary (blue), error (red), success (green)
- Typography: headlineSmall, titleMedium, bodyMedium

#### **CategoryBreakdown**
**Location:** `lib/widgets/category_breakdown.dart`

**Purpose:** Detailed breakdown of expenses per category

**Features:**
- Total spending card with Material 3 elevation
- Category rows with:
  - Category icon in colored container
  - Category name
  - Amount spent
  - Percentage of total
- Empty state with icon and message
- Responsive scrolling layout

**Data Calculation:**
```dart
Map<String, double> _calculateCategoryTotals(List<Transaction> expenses) {
  // Group expenses by categoryName
  // Sum amounts per category
  // Filter: only !tx.isIncome
}
```

---

### 2.4 Report Generation System 🎯

#### **ReportGenerator Service**
**Location:** `lib/services/report_generator.dart`

**Capabilities:**
1. **PDF Report Generation** (`generatePdfReport`)
2. **CSV Export** (`generateCsvReport`)

**PDF Report Structure:**
```
┌──────────────────────────────────────────┐
│   Báo Cáo Tài Chính Tháng M/YYYY        │
├──────────────────────────────────────────┤
│   Financial Summary:                     │
│   • Tổng Thu Nhập: [amount] ₫           │
│   • Tổng Chi Tiêu: [amount] ₫           │
│   • Số Dư: [amount] ₫                   │
├──────────────────────────────────────────┤
│   Chi Tiết Giao Dịch:                   │
│   ┌─────┬─────┬─────┬────────┐         │
│   │Ngày │Tiêu │Hạng │Số Tiền│         │
│   ├─────┼─────┼─────┼────────┤         │
│   │...  │...  │...  │...     │ (Rows) │
│   └─────┴─────┴─────┴────────┘         │
├──────────────────────────────────────────┤
│   Phân Tích Theo Danh Mục:              │
│   ┌──────────────┬──────────┐           │
│   │Danh Mục      │Tổng Tiền │           │
│   ├──────────────┼──────────┤           │
│   │Category 1    │ amount   │ (Rows)    │
│   └──────────────┴──────────┘           │
└──────────────────────────────────────────┘
```

**Key Implementation Details:**

```dart
// 1. Vietnamese Font Loading (CRITICAL)
final vietnamFont = await PdfFontLoader.loadRobotoFont();

// 2. PDF Document Creation
final pdf = pw.Document();

// 3. Transaction Table
_buildTransactionTable(transactions, vietnamFont)
  - Columns: Date | Title | Category | Amount
  - Gray header row
  - Currency formatting with ₫ symbol

// 4. Category Breakdown Table
_buildCategoryBreakdown(byCategory, vietnamFont)
  - Groups transactions by category
  - Sums amounts per category
  - Two columns: Category | Total Amount

// 5. CSV Data Generation
generateCsvReport(List<Transaction> transactions)
  - Headers: Ngày, Tiêu Đề, Danh Mục, Số Tiền, Loại, Ghi Chú
  - Comma-separated format
  - Date formatting: dd/MM/yyyy
  - Currency formatting: explicit amount without symbol
```

**Data Flow:**
```
ReportGenerator.generatePdfReport()
    ↓
1. Load Vietnamese Font via PdfFontLoader
2. Create pw.Document()
3. Build multi-page layout:
   - Header with title & summary
   - Transaction detail table
   - Category breakdown table
4. Apply unicode font to all text elements
5. Return Uint8List (PDF bytes)
```

#### **PdfFontLoader Service**
**Location:** `lib/services/pdf_font_loader.dart`

**Purpose:** Load TTF fonts for Unicode support (Vietnamese characters + ₫ symbol)

**Implementation:**
```dart
class PdfFontLoader {
  static pw.Font? _robotoFont;
  static pw.Font? _notoSansFont;
  
  // Load Roboto font with caching
  static Future<pw.Font> loadRobotoFont() async {
    if (_robotoFont != null) return _robotoFont!;
    
    final fontData = await rootBundle.load('assets/fonts/static/Roboto-Regular.ttf');
    _robotoFont = pw.Font.ttf(fontData);
    return _robotoFont!;
  }
  
  // Fallback to NotoSans if needed
  static Future<pw.Font> loadNotoSansFont() async { ... }
  
  // Cache reset
  static void resetFontCache() { ... }
}
```

**Font Files Location:**
```
assets/
└── fonts/
    ├── README.txt
    ├── OFL.txt
    └── static/
        └── Roboto-Regular.ttf  ← Used for PDF generation
```

**Why TTF Required:**
- Supports Vietnamese diacritics (á, à, ả, ã, ạ, etc.)
- Includes ₫ character (U+20AB Vietnamese Dong)
- Built-in hinting for PDF rendering
- Better than default PDF fonts for CJK languages

#### **ReportPreviewWidget**
**Location:** `lib/widgets/report_preview.dart`

**Purpose:** Interactive UI for generating and exporting reports

**Features:**
```dart
// Report Scope Toggle
- Export current month only (if has transactions)
- Export all months (fallback if current month empty)

// Summary Display
_SummaryCard showing:
  - Month/Year or "All Months"
  - Total Income
  - Total Expense
  - Balance (Income - Expense)

// Export Options
FilledButton: "Xuất PDF"
  └─→ Calls: ReportGenerator.generatePdfReport()
      └─→ Saves file via FileExportHelper
          └─→ Opens with OpenFileX

FilledButton: "Xuất CSV"
  └─→ Calls: ReportGenerator.generateCsvReport()
      └─→ Saves as .csv file

// State Management
_isLoading: Shows loading indicator during generation
_exportAllMonths: Boolean toggle for scope
```

**Export Flow:**
```
User clicks "Xuất PDF"
    ↓
Show loading indicator
    ↓
generatePdfReport() with selected transactions
    ↓
FileExportHelper.saveBytesAsFile()
    ├─ Platform: Android/iOS → saveToDownloads()
    ├─ Platform: Web → downloadFile()
    └─ Platform: Other → showDialog()
    ↓
OpenFileX.open(filePath)
    ↓
System opens PDF viewer
```

---

## 3. State Management Architecture

### **ExpenseProvider** (Central State)
**Location:** `lib/providers/expense_provider.dart`

**Purpose:** Single source of truth for financial data

**State:**
```dart
class ExpenseProvider extends ChangeNotifier {
  final LocalRepository _localRepository;
  final List<Transaction> _transactions;        // All historical data
  double _startingBalance;                      // Initial balance
  List<Category> _expenseCategories;            // Expense categories
  List<Category> _incomeCategories;             // Income categories
  List<Limit> _limits;                          // Spending limits
  double _monthlyBudgetLimit;                   // Monthly budget cap
}
```

**Key Getter Methods:**
```dart
get transactions                → List<Transaction> (unmodifiable)
get startingBalance            → double
get expenseCategories          → List<Category>
get incomeCategories           → List<Category>
get limits                      → List<Limit>
get monthlyBudgetLimit         → double
```

**Key Methods:**
```dart
// Transaction Management
addTransaction(Transaction tx)       // Add new transaction
deleteTransaction(String id)         // Remove transaction
updateTransaction(Transaction tx)    // Update existing
loadTransactions()                   // Load from storage
filterByCategory(String name)        // Filter helper

// Balance Management
setStartingBalance(double balance)   // Update initial balance
calculateTotalBalance()              // Income - Expense + Starting
  → Formula: StartingBalance + TotalIncome - TotalExpense

// Category Management
loadCategories()                     // Load from storage
loadLimits()                         // Load spending limits
loadMonthlyBudgetLimit()            // Load monthly cap
```

**Data Flow:**
```
Screen → Provider (via context.watch<ExpenseProvider>())
             ↓
         LocalRepository (persists to Hive)
             ↓
         Hive Boxes (Transactions, Categories)
             ↓
         notifyListeners() → UI rebuilds
```

---

## 4. Material 3 Design Implementation

### Design System Features Used:

#### **Color Scheme (Dynamic)**
```dart
Theme.of(context).colorScheme
├── primary         → Main brand color (usually blue)
├── secondary       → Accent color
├── tertiary        → Alternative accent
├── error           → Error/warning (usually red)
├── outline         → Border/disabled colors
└── surface         → Background colors
```

#### **Typography Hierarchy**
```dart
Theme.of(context).textTheme
├── headlineSmall     → Titles (18sp)
├── titleMedium       → Section headers (16sp)
├── titleSmall        → Subsection headers (14sp)
├── bodyLarge         → Body text (16sp)
├── bodyMedium        → Standard body (14sp)
└── labelMedium       → Small labels (12sp)
```

#### **Component Styles**
```dart
// Cards with Material 3 elevation
Card(
  child: Padding(...),
)

// Filled buttons (primary action)
FilledButton(onPressed: ..., child: Text(...))

// Text buttons (secondary action)
TextButton(onPressed: ..., child: Text(...))

// Segmented buttons (multi-select)
SegmentedButton<T>(
  segments: [ButtonSegment(...)],
  selected: {selected},
)

// Filter chips
FilterChip(
  label: Text(...),
  selected: isSelected,
)

// Choice chips
ChoiceChip(
  label: Text(...),
  selected: isSelected,
)

// Icon buttons
IconButton(
  icon: Icon(...),
  tooltip: 'Help text',
)
```

#### **Spacing Conventions**
```dart
const EdgeInsets.all(16)           // Standard padding
const EdgeInsets.symmetric(horizontal: 16)
const SizedBox(height: 16)         // Spacing between sections
const SizedBox(width: 8)           // Inline spacing
```

---

## 5. Data Models

### **Transaction**
```dart
class Transaction {
  String id;              // UUID
  String title;           // Description
  double amount;          // Numeric value
  String categoryName;    // Category reference
  DateTime date;          // Date of transaction
  bool isIncome;          // true=income, false=expense
  String note;            // Optional notes
  String? receiptImagePath; // Optional receipt image
}
```

### **Category**
```dart
class Category {
  String id;
  String name;
  IconData icon;          // Material icon
  Color color;            // UI color
  bool isDefault;         // Built-in or custom
}
```

### **Budget & Limit**
```dart
class Budget {
  double monthlyLimit;    // Max spending per month
  double weeklyLimit;     // Max spending per week
}

class Limit {
  String id;
  String categoryName;
  double amount;          // Spending cap
  DateTime startDate;
  DateTime endDate;
}
```

---

## 6. Data Persistence Layer

### **LocalRepository** (Hive-based)
**Location:** `lib/repositories/local_repository.dart`

```dart
// Hive Boxes
- transactionsBox          → List<Transaction>
- categoriesExpenseBox      → List<Category>
- categoriesIncomeBox       → List<Category>
- preferencesBox          → Various preferences

// Key Methods
readTransactions()         → List<Transaction>
createTransaction()        → Transaction (with ID)
updateTransaction()        → Updated Transaction
deleteTransaction()        → void
getStartingBalance()       → double
saveStartingBalance()      → void
```

**Why Hive:**
- Local-first, no cloud dependency
- Type-safe with TypeAdapters
- Lightweight and performant
- Supports Flutter/Dart natively

---

## 7. File Export System

### **FileExportHelper** (Platform-specific)
**Location:** `lib/services/file_export_helper*.dart`

**Variants:**
```
file_export_helper.dart       → Public interface (exports conditional)
├── file_export_helper_io.dart     → Android/iOS implementation
├── file_export_helper_web.dart    → Web implementation
└── file_export_helper_stub.dart   → Fallback

// Usage:
FileExportHelper.saveBytesAsFile(
  bytes: pdfBytes,
  fileName: 'report_3_2024.pdf',
  mimeType: 'application/pdf',
)
```

**Platform Behaviors:**
- **Android/iOS:** Save to Downloads folder via DocumentsDirectory
- **Web:** Trigger browser download dialog
- **Unsupported:** Show manual save dialog with base64

**Integration:**
```dart
// After file is saved
OpenFileX.open(filePath)  // System file viewer
```

---

## 8. External Dependencies

### Core Framework
```yaml
flutter:              # v3.x with Material 3 support
flutter_localizations # Localization support
google_fonts: ^6.1.0 # Font management
```

### State Management
```yaml
provider: ^6.1.2      # ChangeNotifier + Consumer pattern
```

### Local Storage
```yaml
hive: ^2.2.3              # NoSQL database
hive_flutter: ^1.1.0      # Flutter integration
path_provider: ^2.1.5     # System paths (Documents, Downloads)
```

### Charts & Visualization
```yaml
fl_chart: ^0.69.0    # Line, Bar, Pie charts
```

### PDF & Export
```yaml
pdf: ^3.12.0         # PDF generation (package:pdf/widgets.dart)
csv: ^6.0.0          # CSV formatting
uuid: ^4.0.0         # Transaction IDs
```

### Utilities
```yaml
http: ^1.3.0                # API calls (exchange rates)
intl: 0.20.2               # Date/currency formatting
open_filex: ^4.4.0         # File opening
path: ^1.9.1               # Path manipulation
```

---

## 9. Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Main App (main.dart)                    │
│         Provider: ChangeNotifierProvider<ExpenseProvider>  │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   ┌────▼────┐    ┌────▼─────┐  ┌────▼──────┐
   │Dashboard │    │Home      │  │Analysis   │
   │Screen    │    │Screen    │  │Screen     │
   └────┬────┘    └────┬─────┘  └────┬──────┘
        │              │             │
        │    ┌─────────┼─────────┐   │
        │    │         │         │   │
   ┌────▼────▼─┐   ┌───▼──┐  ┌──▼──────┐
   │ Balance   │   │Recent│  │Trend    │
   │Card       │   │Trans │  │Chart    │
   └───────────┘   └──────┘  └─────────┘
                       │         │
               ┌───────┴─────────┘
               │
        ┌──────▼──────────────────────┐
        │  ExpenseProvider            │
        │  (Central State Manager)     │
        │                             │
        │  - transactions[]           │
        │  - categories[]             │
        │  - startingBalance          │
        │  - calculateTotalBalance()  │
        └──────┬─────────────────────┘
               │
               ├─ ReportGenerator ────┐
               │  ├─ generatePdfReport │
               │  └─ generateCsvReport │
               │         │             │
               │         └─ PdfFontLoader
               │            └─ Roboto-Regular.ttf
               │
               ├─ PieChart Widget ──┐
               │  (ExpensePieChart)  │
               │  fl_chart library   │
               │
               ├─ LineChart Widget ─┐
               │  (TrendChartWidget) │
               │  fl_chart library   │
               │
               └─ LocalRepository ──┐
                  └─ Hive          │
                     └─ Transactions, Categories, Prefs
```

---

## 10. Key Flows

### A. Adding Transaction Flow

```
Add Transaction Screen
    ↓
Form filled, "Lưu" pressed
    ↓
ExpenseProvider.addTransaction(tx)
    ↓
LocalRepository.createTransaction(tx)
    ↓
Hive Box.add(tx)
    ↓
notifyListeners()
    ↓
UI rebuilds (consumers update)
    ↓
BalanceCard shows new total
ExpensePieChart recalculates
TrendChart updates
```

### B. Viewing Financial Report

```
Analysis Screen → "Báo cáo" tab
    ↓
ReportPreviewWidget renders
    ↓
User selects month or "All"
    ↓
_SummaryCard calculates totals
    ↓
User clicks "Xuất PDF"
    ↓
setLoading(true)
    ↓
ReportGenerator.generatePdfReport()
    ├─ PdfFontLoader.loadRobotoFont()
    ├─ Build PDF structure with tables
    └─ Return Uint8List
    ↓
FileExportHelper.saveBytesAsFile()
    ├─ Platform check
    ├─ Save to Downloads
    └─ Return file path
    ↓
OpenFileX.open(filePath)
    ↓
System PDF viewer opens
```

### C. Viewing Charts

```
Analysis Screen → "Xu hướng" tab
    ↓
TrendChartWidget builds
    ↓
User selects period: "Month"
    ↓
setState() triggers rebuild
    ↓
_getTrendData() aggregates:
    - Filter transactions by period
    - Group by date
    - Sum income/expense per date
    - Create FlSpot pairs for chart
    ↓
LineChart renders with two series:
    - Income (green line)
    - Expense (red line)
    ↓
User selects "Bar" chart type
    ↓
_buildBarChart() creates BarChartData
    ↓
BarChart renders with grouped rods
```

---

## 11. Internationalization Notes

### Vietnamese Support
- **Locale:** vi_VN
- **Text:** All UI strings in Vietnamese (Tiếng Việt)
- **Date Format:** dd/MM/yyyy (16/03/2024)
- **Currency:** ₫ (Vietnamese Dong, U+20AB)
- **Numbers:** Dot separator for thousands (1.000.000 ₫)

### Font Support
- **Default Flutter Fonts:** Limited Unicode support
- **PDF Generation:** Requires TTF with Vietnamese glyphs
  - Used: Roboto-Regular.ttf
  - Provides: Full Latin extended + Vietnamese diacritics + ₫

---

## 12. Key Design Patterns Used

### Pattern: Provider Pattern
- **Use:** State management across app
- **Implementation:** ChangeNotifierProvider + Consumer/watch
- **Benefit:** Decoupled UI from business logic

### Pattern: Repository Pattern
- **Use:** Abstraction of data sources
- **Implementation:** LocalRepository interface
- **Benefit:** Easy to swap storage (Hive ↔ Firebase ↔ SQL)

### Pattern: TypeAdapter Pattern
- **Use:** Serialization for Hive
- **Implementation:** TransactionAdapter, CategoryAdapter
- **Benefit:** Type-safe storage of complex objects

### Pattern: Stateful Widgets
- **Use:** Components with internal state (Chart period selector)
- **Benefit:** Isolated state for responsive UI interactions

### Pattern: Material 3 Theming
- **Use:** Dynamic color scheme
- **Benefit:** Consistent design, dark mode support, Material You

---

## 13. Performance Considerations

### Optimization Strategies
1. **Lazy Loading:** Charts render only when tab selected
2. **Memoization:** PdfFontLoader caches loaded fonts
3. **Filtering:** Only current month transactions shown by default
4. **Unmodifiable Lists:** Prevent accidental mutations
5. **AnimatedSwitcher:** Smooth transitions between sections (220ms)

### Potential Bottlenecks
- **Large Transaction Lists:** Consider pagination for 1000+ records
- **PDF Generation:** Font loading for each report (mitigated by caching)
- **Chart Rendering:** Many data points may slow LineChart
- **Hive Queries:** Full table scan for category aggregations

---

## 14. Testing Considerations

### Test Files Available
```
test/
├── home_screen_test.dart
├── expense_provider_test.dart
├── local_repository_test.dart
├── add_transaction_test.dart
├── budget_test.dart
└── widget_test.dart
```

### Areas Covered
- Provider state mutations
- Repository persistence
- Transaction filtering
- Balance calculations

### Recommended Additional Tests
- PDF generation with Vietnamese text
- Chart data aggregation accuracy
- File export on different platforms
- Category breakdown calculations

---

## 15. Security & Privacy Notes

### Data Storage
- ✅ All data stored locally (Hive) - no cloud sync
- ⚠️ No encryption (standard Hive - consider hive_sealed_box for sensitive data)
- ✅ File exports saved to user Downloads folder

### External APIs
- USD/VND Exchange rates from web API
- No authentication needed (public rates)
- HTTP requests with timeout

### Recommendations
- Consider: Biometric auth before app opens
- Consider: Encrypting sensitive data in Hive
- Consider: Rate limiting exchange rate API calls

---

## 16. Quick Reference: File Organization

| Purpose | File |
|---------|------|
| **App Entry** | `main.dart` |
|**Charts** | `widgets/expense_pie_chart.dart`, `widgets/trend_chart.dart` |
| **PReport Generation** | `services/report_generator.dart` |
| **Font Management** | `services/pdf_font_loader.dart` |
| **Report Preview UI** | `widgets/report_preview.dart` |
| **Financial Summary** | `widgets/dashboard_overview.dart`, `widgets/category_breakdown.dart` |
| **Dashboard Hub** | `screens/analysis_screen.dart` |
| **Welcome Screen** | `screens/dashboard_screen.dart` |
| **State Management** | `providers/expense_provider.dart` |
| **Data Persistence** | `repositories/local_repository.dart` |
| **Export Utilities** | `services/file_export_helper*.dart` |

---

## Summary

The Smart Spend codebase demonstrates a well-structured Flutter app with:
- ✅ **Clean Architecture:** Separation of concerns (models, providers, repositories, services, widgets, screens)
- ✅ **Material 3 Design:** Modern, responsive UI with proper theming
- ✅ **Advanced Charts:** fl_chart library with multiple visualization types
- ✅ **PDF Generation:** Vietnamese language support with Unicode fonts
- ✅ **State Management:** Provider pattern for predictable data flow
- ✅ **Local-First Storage:** Hive for persistent data without cloud dependency
- ✅ **Internationalization:** Vietnamese locale with proper date/currency formatting
- ✅ **Export Capabilities:** PDF and CSV reports with platform-specific handling

The architecture supports easy expansion (e.g., adding budgeting features, notifications, cloud sync) while maintaining code maintainability.
