# Smart Spend - Developer Quick Start Guide

## 📍 Key File Locations & Entry Points

### Absolute Starting Points (Read These First)

#### 1. **main.dart** - App Bootstrap
**File:** `lib/main.dart`
- Hive initialization
- TypeAdapter registration
- ExpenseProvider setup
- Initial data loading

**Key Lines:**
```dart
Line 17-31: Hive setup & adapter registration
Line 33-38: Initial data loading from repository
Line 42-50: MultiProvider with ExpenseProvider
```

#### 2. **AnalysisScreen** - Main Dashboard Hub
**File:** `lib/screens/analysis_screen.dart`
- Central page for financial analysis
- 3 main sections: Overview, Trend, Report
- Where most features converge

**Navigation Path:** App Launch → DashboardScreen (Welcome) → AnalysisScreen (Main Hub)

---

## 🎯 Understanding Core Flows

### Flow 1: "I want to see charts"

**Starting File:** `lib/screens/analysis_screen.dart`

```
1. Open AnalysisScreen
   └─ Switch to "Xu hướng" tab
      └─ _AnalysisSection.trend
         └─ Render TrendChartWidget

2. TrendChartWidget
   ├─ Display period selector (Month, Week, etc.)
   ├─ Display chart type selector (Line, Bar)
   └─ Render selected chart type

3. Chart Data Calculation
   ├─ _getTrendData() groups transactions by period
   ├─ Creates FlSpot lists for income/expense
   └─ Passes to fl_chart widgets

4. Rendering
   ├─ LineChart (if Line selected)
   │  ├─ Green line = Income
   │  └─ Red line = Expense
   └─ BarChart (if Bar selected)
      ├─ Green bars = Income
      └─ Red bars = Expense
```

**Files Involved:**
- `lib/widgets/trend_chart.dart` - Chart widget
- `lib/models/transaction.dart` - Transaction model
- `pubspec.yaml` - fl_chart dependency

---

### Flow 2: "I want to generate a PDF report"

**Starting File:** `lib/widgets/report_preview.dart`

```
1. User navigates to AnalysisScreen → "Báo cáo" tab
   └─ ReportPreviewWidget builds

2. ReportPreviewWidget renders
   ├─ ShowsSummaryCard with current/selected month data
   ├─ Shows export buttons (PDF, CSV)
   └─ Shows toggle for "Export all months"

3. User clicks "Xuất PDF"
   ├─ setLoading(true)
   ├─ Call ReportGenerator.generatePdfReport()
   │  ├─ Load Vietnamese font: PdfFontLoader.loadRobotoFont()
   │  ├─ Build PDF structure
   │  │  ├─ Title + Summary
   │  │  ├─ Transaction table
   │  │  └─ Category breakdown table
   │  ├─ Apply unicode font to all text
   │  └─ Return Uint8List (PDF bytes)
   └─ Call FileExportHelper.saveBytesAsFile()
      └─ Platform-specific file save
         └─ OpenFileX.open(filePath)
            └─ System PDF viewer

4. User sees beautifully formatted PDF with Vietnamese text
```

**Files Involved:**
- `lib/widgets/report_preview.dart` - Report UI
- `lib/services/report_generator.dart` - PDF generation
- `lib/services/pdf_font_loader.dart` - Font loading
- `lib/services/file_export_helper*.dart` - Platform-specific export
- `assets/fonts/static/Roboto-Regular.ttf` - Vietnamese font

---

### Flow 3: "I want to add a new feature"

**Example: Add Monthly Budget Alert Notification**

```
Step 1: Create Service
├─ File: lib/services/monthly_budget_alert.dart
├─ Listen: ExpenseProvider._transactions changes
├─ Check: current month expense vs monthlyBudgetLimit
└─ Alert: Show notification if exceeded

Step 2: Integrate with ExpenseProvider
├─ File: lib/providers/expense_provider.dart
├─ Add: `MonthlyBudgetAlert _alertService;`
├─ Initialize: in constructor
└─ Trigger: after addTransaction() or updateTransaction()

Step 3: Add UI Indicator
├─ File: lib/screens/analysis_screen.dart
├─ Show: Banner if budget exceeded
├─ Color: Material 3 error color
└─ Action: Link to limits management

Step 4: Test
├─ File: test/monthly_budget_alert_test.dart
├─ Mock: ExpenseProvider
└─ Verify: Alert triggers at correct threshold
```

---

## 🎨 Material 3 Design Components Quick Reference

### When to Use Each Component

| Need | Component | File Location | Example |
|------|-----------|--------|---------|
| Primary action button | FilledButton | widgets/report_preview.dart | "Xuất PDF" button |
| Secondary action | TextButton | lib/main.dart | "Cancel" dialog button |
| Toggle between 2-3 options | SegmentedButton | screens/analysis_screen.dart | Overview\|Trend\|Report |
| Filter by category | FilterChip | widgets/trend_chart.dart | Month\|Week\|Quarter |
| Select one from many | ChoiceChip | widgets/trend_chart.dart | Line\|Bar chart |
| Card container | Card | widgets/balance_card.dart | Summary cards |
| Icon with tooltip | IconButton | widgets/balance_card.dart | Edit balance icon |
| Currency/amount display | Text with colorScheme | widgets/balance_card.dart | Display ₫ amounts |
| Color scheme aware design | theme.colorScheme | All widgets | Dynamic colors |

### Color Usage in Codebase

```dart
// From Material 3 ColorScheme
colorScheme.primary       → Used for: Main balance, totals, headers
colorScheme.secondary     → Used for: Alternative accents
colorScheme.tertiary      → Used for: Third-tier information
colorScheme.error         → Used for: Expenses (red), warnings
colorScheme.outline       → Used for: Borders, disabled, secondary text
colorScheme.surface       → Used for: Card backgrounds

// Custom Colors (Non-Material3)
Colors.green             → Income display in charts
Colors.red               → Expense display in charts
Colors.blue              → Category selector, special highlights
```

### Typography Usage

```dart
theme.textTheme.headlineSmall    → Page titles: "Phân tích tài chính"
theme.textTheme.titleMedium      → Section headers: "Chi tiết giao dịch"
theme.textTheme.titleSmall       → Subsection headers
theme.textTheme.bodyLarge        → Main body text (16sp)
theme.textTheme.bodyMedium       → Standard body text (14sp)
theme.textTheme.labelMedium      → Small labels, captions
```

---

## 🔄 State Management: Provider Pattern

### Understanding the Data Flow

```
User adds transaction
    ↓
AddTransactionScreen.onSubmit()
    ↓
context.read<ExpenseProvider>().addTransaction(tx)
    ↓
ExpenseProvider.addTransaction()
    ├─ Save to LocalRepository
    ├─ Update internal _transactions list
    └─ Call notifyListeners()  ← KEY!
    ↓
All Consumer<ExpenseProvider>() widgets rebuild
    ├─ BalanceCard updates
    ├─ ExpensePieChart updates
    ├─ TrendChartWidget updates
    └─ DashboardOverviewWidget updates
```

### How to Access Provider Data

```dart
// In a widget that needs provider data:

// Option 1: Consumer (functional)
Consumer<ExpenseProvider>(
  builder: (context, provider, _) {
    final transactions = provider.transactions;
    return YourWidget();
  },
)

// Option 2: context.watch (in build method)
final provider = context.watch<ExpenseProvider>();
final balance = provider.calculateTotalBalance();

// Option 3: context.read (one-time read, no rebuild)
final provider = context.read<ExpenseProvider>();
await provider.addTransaction(tx);
```

### Adding State to Provider

```dart
// In ExpenseProvider class:

// 1. Add private variable
late List<CustomObject> _customData;

// 2. Add getter for public access
List<CustomObject> get customData => List.unmodifiable(_customData);

// 3. Add method to modify it
Future<void> addCustomObject(CustomObject obj) async {
  _customData.add(obj);
  // TODO: also save to LocalRepository if needed
  notifyListeners();  // Triggers all listeners to rebuild
}
```

---

## 📊 Working with Charts

### Pie Chart: Category Breakdown

**File:** `lib/widgets/expense_pie_chart.dart`

**To modify pie chart:**

```dart
// Change colors:
final colors = [
  colorScheme.primary,
  colorScheme.secondary,
  // Add more colors or customize
];

// Change center space:
centerSpaceRadius: 36,  // Increase for bigger donut hole

// Change section spacing:
sectionsSpace: 2,  // Increase for visible gaps

// Change title style:
titleStyle: const TextStyle(
  fontSize: 11,  // Adjust size
  fontWeight: FontWeight.w600,
  color: Colors.white,  // Change color
),
```

### Trend Chart: Time Series

**File:** `lib/widgets/trend_chart.dart`

**To add new chart type:**

```dart
// 1. Add to enum
enum TrendChartType { line, bar, area, scatter }

// 2. Add selector chip
ChoiceChip(
  label: Text('Vùng'),
  selected: _chartType == TrendChartType.area,
  onSelected: (selected) {
    if (selected) setState(() => _chartType = TrendChartType.area);
  },
)

// 3. Add builder method
else if (_chartType == TrendChartType.area)
  _buildAreaChart(data)

// 4. Implement _buildAreaChart()
Widget _buildAreaChart(TrendData data) {
  return AreaChart(AreaChartData(...));
}
```

---

## 📱 Adding New Screen/Feature

### Template: New Financial Feature

**Step 1: Create Model** (if needed)
```dart
// File: lib/models/new_feature.dart

class NewFeature {
  String id;
  String name;
  double value;
  DateTime createdAt;
}
```

**Step 2: Create Screen**
```dart
// File: lib/screens/new_feature_screen.dart

class NewFeatureScreen extends StatefulWidget {
  const NewFeatureScreen({super.key});
  @override
  State<NewFeatureScreen> createState() => _NewFeatureScreenState();
}

class _NewFeatureScreenState extends State<NewFeatureScreen> {
  @override
  Widget build(BuildContext context) {
    // Your Material 3 UI here
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          // Access provider data
          return Center(child: Text('Your content'));
        },
      ),
    );
  }
}
```

**Step 3: Extend ExpenseProvider** (if needed)
```dart
// In lib/providers/expense_provider.dart

late List<NewFeature> _newFeatures;

List<NewFeature> get newFeatures => List.unmodifiable(_newFeatures);

Future<void> addNewFeature(NewFeature feature) async {
  _newFeatures.add(feature);
  // TODO: persist to LocalRepository
  notifyListeners();
}
```

**Step 4: Wire Navigation** (in home/main navigation)
```dart
// In lib/screens/main_navigation.dart or similar

// Add route to new screen
NewFeatureScreen(),

// Or add navigation button
TextButton(
  onPressed: () => Navigator.push(...NewFeatureScreen()),
  child: const Text('New Feature'),
)
```

---

## 🧪 Testing Essential Components

### Test Template: Provider State

```dart
// File: test/new_feature_provider_test.dart

void main() {
  group('NewFeatureProvider', () {
    late ExpenseProvider provider;

    setUp(() {
      provider = ExpenseProvider(
        localRepository: FakeLocalRepository(),
        initialTransactions: [],
      );
    });

    test('Add new feature updates state', () {
      final feature = NewFeature(...);
      
      provider.addNewFeature(feature);
      
      expect(provider.newFeatures.length, 1);
      expect(provider.newFeatures[0].id, feature.id);
    });

    test('notifyListeners is called', () {
      bool listened = false;
      
      provider.addListener(() => listened = true);
      provider.addNewFeature(NewFeature(...));
      
      expect(listened, true);
    });
  });
}
```

### Test Template: Widget

```dart
// File: test/new_feature_screen_test.dart

void main() {
  group('NewFeatureScreen', () {
    testWidgets('Displays features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => ExpenseProvider(...),
            ),
          ],
          child: const MaterialApp(
            home: NewFeatureScreen(),
          ),
        ),
      );

      expect(find.text('New Feature'), findsOneWidget);
    });
  });
}
```

---

## 🎯 Debugging Tips

### Check State
```dart
// Add to build method temporarily
builder: (context, provider, _) {
  print('Transactions: ${provider.transactions.length}');
  print('Balance: ${provider.calculateTotalBalance()}');
  return YourWidget();
}
```

### Verify Provider Mutation
```dart
// In ExpenseProvider methods
Future<void> addTransaction(Transaction transaction) async {
  print('Before: ${_transactions.length}');
  // ... add transaction code
  print('After: ${_transactions.length}');
  notifyListeners();
  print('Listeners notified');
}
```

### Chart Data Debug
```dart
// In TrendChartWidget
Widget _buildLineChart(TrendData data) {
  print('Income spots: ${data.incomeSpots}');
  print('Expense spots: ${data.expenseSpots}');
  print('Labels: ${data.labels}');
  // ...
}
```

### Font Loading Debug
```dart
// In PdfFontLoader
static Future<pw.Font> loadRobotoFont() async {
  print('Attempting to load Roboto font...');
  try {
    final fontData = await rootBundle.load('assets/fonts/static/Roboto-Regular.ttf');
    print('✅ Font loaded successfully: ${fontData.lengthInBytes} bytes');
    _robotoFont = pw.Font.ttf(fontData);
    return _robotoFont!;
  } catch (e) {
    print('❌ Font load error: $e');
    // fallback...
  }
}
```

---

## 📦 Dependencies at a Glance

### Must Know Dependencies

```yaml
provider: ^6.1.2
  # State management - Learn: ChangeNotifierProvider, Consumer

fl_chart: ^0.69.0
  # Charts - Learn: PieChart, LineChart, BarChart, FlSpot

pdf: ^3.12.0
  # PDF generation - Learn: Document, Page, Table, Text rendering

hive: ^2.2.3 + hive_flutter: ^1.1.0
  # Local storage - Learn: TypeAdapter, Box.add/update/delete

intl: 0.20.2
  # Formatting - Learn: DateFormat, NumberFormat for currency

open_filex: ^4.4.0
  # File opening - Learn: OpenFileX.open(path)
```

### Optional but Useful

```yaml
google_fonts: ^6.1.0      # Additional fonts
http: ^1.3.0             # API calls
uuid: ^4.0.0             # ID generation
csv: ^6.0.0              # CSV export format
```

---

## ⚡ Common Tasks

### Task: Export Transaction Data as CSV

**File:** `lib/widgets/report_preview.dart` (already exists)

**Code location:** Lines ~140-160

```dart
Future<void> _exportCSV() async {
  final csv = ReportGenerator.generateCsvReport(exportTransactions);
  // csv is a String with newlines
  final bytes = utf8.encode(csv);
  await FileExportHelper.saveBytesAsFile(
    bytes: bytes,
    fileName: 'transactions_${widget.month}_${widget.year}.csv',
    mimeType: 'text/csv',
  );
}
```

### Task: Add New Category

**File:** `lib/models/category.dart` (defines default categories)

```dart
// In the file, modify these constants:
const List<Category> expenseDefaultCategories = [
  Category(
    id: 'new-id',
    name: 'New Category',
    icon: Icons.your_icon,
    color: Colors.yourColor,
    isDefault: true,
  ),
  // ... existing categories
];
```

### Task: Change Budget Limit

**File:** `lib/providers/expense_provider.dart`

```dart
// Find this line:
_monthlyBudgetLimit = 8000000.0;  // Default: 8 million VND

// Change to your desired limit:
_monthlyBudgetLimit = 10000000.0;  // 10 million VND
```

### Task: Add Currency Prefix/Suffix

**File:** `lib/widgets/balance_card.dart`

**In _formatCurrency method:**

```dart
String _formatCurrency(double value) {
  const prefix = '';      // Example: '$'
  const suffix = ' ₫';    // Vietnamese Dong

  final text = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  
  // ... formatting logic ...
  
  return '$prefix$buffer$suffix';
}
```

---

## 🔗 File Navigation Cheatsheet

```
Want to...                      → Open file...
─────────────────────────────────────────────────────────────
See all transactions            → lib/screens/home_screen.dart
Add a transaction               → lib/screens/add_transaction_screen.dart
View financial analysis         → lib/screens/analysis_screen.dart
Manage budgets/limits           → lib/screens/limits_screen.dart
Manage categories               → lib/models/category.dart
Modify state/provider           → lib/providers/expense_provider.dart
Generate reports                → lib/services/report_generator.dart
Customize pie chart             → lib/widgets/expense_pie_chart.dart
Customize trend chart           → lib/widgets/trend_chart.dart
Change app theme               → lib/main.dart (MaterialApp theme)
Add data storage logic         → lib/repositories/local_repository.dart
Handle file export             → lib/services/file_export_helper*.dart
```

---

## 🚀 Quick Start Checklist

- [ ] **Read** `lib/main.dart` to understand app initialization
- [ ] **Read** `lib/providers/expense_provider.dart` to understand state
- [ ] **Read** `lib/screens/analysis_screen.dart` to understand main UI flow
- [ ] **Review** `lib/widgets/trend_chart.dart` and `expense_pie_chart.dart` for charts
- [ ] **Review** `lib/services/report_generator.dart` for PDF generation
- [ ] **Check** `pubspec.yaml` for all dependencies
- [ ] **Run** `flutter pub get` to install dependencies
- [ ] **Run** `flutter run` to test app locally
- [ ] **Review** test files in `test/` directory
- [ ] **Read** `CODEBASE_EXPLORATION.md` for deep dive

---

## 📚 Learning Path

### Beginner (1-2 hours)
1. Read `CODEBASE_EXPLORATION.md` sections 1-4
2. Run the app and navigate through screens
3. Understand the 3 Analysis tabs (Overview, Trend, Report)

### Intermediate (4-6 hours)
1. Review State Management (`ExpenseProvider`)
2. Understand chart data flows (Pie & Trend)
3. Trace a transaction from add → storage → display
4. Examine PDF generation & font loading

### Advanced (8+ hours)
1. Plan new features (budgeting, alerts, etc.)
2. Implement with tests
3. Integrate with existing provider pattern
4. Optimize performance for large datasets

---

**Document Version:** 1.0
**Last Updated:** March 2024
**For:** Smart Spend v1.0.0 Flutter App
