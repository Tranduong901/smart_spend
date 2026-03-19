# 🏗️ Architecture - Expense Tracker (Quản lý chi tiêu)

## 📐 High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│              UI Layer (Screens & Widgets)        │
│  - HomeScreen, AnalysisScreen, AddTransactionScreen
│  - Reusable widgets (BalanceCard, TransactionTile, etc.)
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│        State Management (Provider)              │
│  - ExpenseProvider (ChangeNotifier)             │
│  - Manages transactions, balance, categories    │
│  - Notifies listeners on data changes           │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│        Business Logic (Services)                │
│  - ReportGenerator (PDF/CSV export)             │
│  - BudgetNotificationService (alerts)           │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│      Repository Pattern (Data Access)           │
│  - LocalRepository (Hive CRUD abstraction)      │
│  - Adapter pattern for serialization            │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│          Data Models (Immutable)                │
│  - Transaction, Category, Budget                │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│      Local Storage (Hive + Preferences)         │
│  - In-app database (100% offline)               │
│  - No cloud sync, no internet required          │
└─────────────────────────────────────────────────┘
```

## 📁 Directory Structure & Responsibilities

### `lib/main.dart`
**Purpose**: Application root and navigation setup

**Key Components**:
- `SmartSpendApp`: Main Flutter app widget
- `MultiProvider`: Sets up Provider for state management
- Navigation structure (2 tabs + FAB)
- `GlobalKey<NavigatorState>`: Manages navigation context

**Key Functions**:
```dart
- _openAddTransactionPage(): Opens form via FAB
- Build material app with theme and navigation
```

### `lib/models/`
**Purpose**: Immutable data structures (no business logic)

**Files**:
- `transaction.dart`: Transaction model with fields: id, title, amount, categoryName, date, note, imagePath?, isIncome
- `category.dart`: Category model with fields: id, name, isIncome, colorValue, iconCodePoint
- `budget.dart`: Budget model with fields: id, categoryName, limitAmount, month, year

**Pattern**: All models use `copyWith()` for immutable updates

### `lib/screens/`
**Purpose**: Full-page screens with provider integration

**Files**:
- `home_screen.dart`: 
  - Displays balance, search bar, filter, transaction list
  - Handles edit/delete actions
  - Calls `_openEditTransaction()` when edit clicked
  
- `add_transaction_screen.dart`:
  - Dual-mode form (add/edit)
  - SegmentedButton for transaction type toggle
  - Dynamic category selector
  - Receipt button conditional on transaction type
  
- `analysis_screen.dart`:
  - Monthly comparison (current vs previous)
  - Pie chart breakdown by category
  - Category breakdown with progress bars

**Navigation Pattern**:
```dart
// FAB → AddTransactionScreen (new)
_navigatorKey.currentState?.push(
  MaterialPageRoute(builder: (_) => AddTransactionScreen())
);

// Edit → AddTransactionScreen (existing)
_navigatorKey.currentState?.push(
  MaterialPageRoute(builder: (_) => AddTransactionScreen(transaction: tx))
);
```

### `lib/widgets/`
**Purpose**: Reusable UI components

**Atomic Widgets**:
- `balance_card.dart`: Shows total balance with edit button
- `transaction_tile.dart`: Single transaction display with edit/delete buttons
- `category_selector.dart`: Dropdown for category selection
- `dynamic_category_selector.dart`: Category selector with type awareness
- `history_filter_bar.dart`: Month/year filter dropdowns

**Composite Widgets** (New):
- `dashboard_overview.dart`: Key statistics (income, expense, balance, etc.)
- `trend_chart.dart`: Line/bar charts for income/expense trends
- `expense_pie_chart.dart`: Pie chart breakdown
- `category_breakdown.dart`: Category progress bars
- `report_preview.dart`: Report preview and export functionality

### `lib/providers/`
**Purpose**: State management using Provider pattern

**Key Class**: `ExpenseProvider extends ChangeNotifier`

**Responsibility**:
- Holds all financial data in memory
- Implements CRUD for transactions, categories, budgets
- Calculates derived values (balance, statistics)
- Notifies listeners when data changes

**Key Methods**:
```dart
// Transaction management
addTransaction(Transaction tx)
updateTransaction(Transaction tx)
deleteTransaction(String id)
loadTransactions()

// Category management
loadCategories()
addCategory(Category cat)

// Balance management
calculateTotalBalance()
setStartingBalance(double amount)

// Statistics (new)
getTotalIncome(int month?, int year?)
getTotalExpense(int month?, int year?)
getByCategory(String categoryName)
getByMonth(int month, int year)

// Budget management
setBudget(Budget budget)
getBudget(String categoryName, int month, int year)
checkBudgetExceeded(Transaction tx)
```

### `lib/repositories/`
**Purpose**: Abstraction layer for data persistence

**Key Class**: `LocalRepository`

**Responsibility**:
- Manages Hive box operations
- Handles serialization/deserialization
- Provides storage abstraction (could swap Hive for SQLite, etc.)

**Key Methods**:
```dart
// Transactions
createTransaction(Transaction tx) → Future<void>
readTransactions() → Future<List<Transaction>>
updateTransaction(Transaction tx) → Future<void>
deleteTransaction(String id) → Future<void>

// Categories
getCategories(bool isIncome) → Future<List<Category>>
saveCategories(List<Category> cats) → Future<void>
addCategory(Category cat) → Future<void>

// Budgets (new)
createBudget(Budget budget) → Future<void>
readBudgets(int month, int year) → Future<List<Budget>>
updateBudget(Budget budget) → Future<void>
deleteBudget(String id) → Future<void>

// Preferences
getStartingBalance() → Future<double>
saveStartingBalance(double amount) → Future<void>
```

### `lib/adapters/`
**Purpose**: Serialization/deserialization for Hive storage

**Key Class**: `TransactionAdapter`

**Responsibility**:
- Converts Transaction objects to/from Hive format
- Handles backward compatibility (old enum → new string)
- Manages TypeId for Hive registration

**Process**:
```
Transaction object → TypeAdapter.write() → Hive storage
Hive storage → TypeAdapter.read() → Transaction object
```

### `lib/services/`
**Purpose**: Business logic and utilities (new)

**Key Files**:
- `report_generator.dart`:
  - PDF generation using `pdf` package
  - CSV export using `csv` package
  - Summary statistics calculation
  - Transaction detail formatting

- `budget_notification.dart`:
  - Budget alert detection (80% and 100% thresholds)
  - Snackbar notification display
  - Alert model and enums

## 🔄 Data Flow Patterns

### 1️⃣ Add Transaction Flow

```
AddTransactionScreen
  └─ User enters data + clicks "Save"
     └─ Validate form
        └─ Create Transaction object
           └─ ExpenseProvider.addTransaction(tx)
              └─ LocalRepository.createTransaction(tx)
                 └─ Hive box.add(tx)  [Persisted]
                    └─ _transactions.add(tx)
                       └─ notifyListeners()
                          └─ UI rebuilds (HomeScreen)
```

### 2️⃣ Edit Transaction Flow

```
HomeScreen.TransactionTile
  └─ User clicks edit button
     └─ onEdit() callback
        └─ _openEditTransaction(tx)
           └─ Navigator.push(AddTransactionScreen(transaction: tx))
              └─ Form pre-fills with tx data
                 └─ User modifies + clicks "Update"
                    └─ ExpenseProvider.updateTransaction(updatedTx)
                       └─ LocalRepository.updateTransaction(tx)
                          └─ Hive box.update(tx)  [Persisted]
                             └─ _transactions.replaceWhere(...)
                                └─ notifyListeners()
                                   └─ UI rebuilds
```

### 3️⃣ Search/Filter Flow

```
HomeScreen.SearchBar/HistoryFilterBar
  └─ User types search or selects month/year
     └─ setState() → _filteredTransactions calculated
        └─ Filter logic:
           - If selectedMonth/year != null:
             filter by date range
           - If searchQuery != null:
             filter by title/category/note (case-insensitive)
           - Combine both filters (AND logic)
        └─ ListView rebuilds with filtered items
```

### 4️⃣ Balance Calculation

```
ExpenseProvider.calculateTotalBalance()
  └─ return startingBalance + getTotalIncome() - getTotalExpense()
     └─ getTotalIncome():
        return transactions.where(isIncome).sum(amount)
     └─ getTotalExpense():
        return transactions.where(!isIncome).sum(amount)
     └─ Called on every transaction change
        └─ BalanceCard rebuilds via Consumer
```

### 5️⃣ Report Generation

```
ReportPreviewWidget ("Xuất PDF" button)
  └─ _exportPdf()
     └─ ReportGenerator.generatePdfReport(...)
        └─ Create PDF document structure
           - Title + date
           - Summary card (income, expense, balance)
           - Transaction detail table
           - Category breakdown
        └─ pdf.save() → Uint8List
           └─ _downloadFile(...) → Browser download
              └─ Show success snackbar
```

## 💾 Data Persistence Architecture

### Hive Setup

```dart
// main.dart - Initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  
  // Open boxes
  await Hive.openBox('transactions');
  await Hive.openBox('categories_expense');
  await Hive.openBox('categories_income');
  await Hive.openBox('preferences');
  
  runApp(SmartSpendApp());
}
```

### Box Usage

| Box Name | Purpose | Type |
|----------|---------|------|
| `transactions` | All transactions | List<Transaction> |
| `categories_expense` | Expense categories | List<Category> |
| `categories_income` | Income categories | List<Category> |
| `preferences` | App settings (starting balance) | Key-value |

### Backward Compatibility

```dart
// In TransactionAdapter._decodeCategoryName()
String _decodeCategoryName(int? oldIndex) {
  const categoryMap = {
    0: 'Ăn uống',
    1: 'Di chuyển',
    2: 'Shopping',
    // ... etc
  };
  return categoryMap[oldIndex] ?? 'Khác';
}
```

## 🎯 State Management Details

### Provider Pattern (MVVM-like)

```
UI Layer (Views)
  └─ Consumer<ExpenseProvider>
     └─ Rebuilds when provider notifies
        └─ Access provider.transactions
           └─ Display in ListView/GridView

ExpenseProvider (ViewModel)
  └─ Holds _transactions, _categories, _startingBalance
  └─ Implements business logic
  └─ Calls notifyListeners() when data changes

LocalRepository (Model)
  └─ Handles Hive persistence
  └─ Provides CRUD abstraction
```

### Immutability Pattern

```dart
// ✅ Good - Use copyWith() for updates
final updatedTx = transaction.copyWith(
  title: 'New Title',
  amount: 500000,
);

// ❌ Bad - Direct mutation
transaction.title = 'New Title';
```

## 🔐 Error Handling Strategy

### At Repository Level
```dart
try {
  await box.put(key, item);
} catch (e) {
  logger.error('Failed to save: $e');
  rethrow;  // Let provider handle
}
```

### At Provider Level
```dart
try {
  await repository.addTransaction(tx);
  _transactions.add(tx);
  notifyListeners();
} catch (e) {
  _error = e.toString();
  notifyListeners();  // UI shows error
}
```

### At UI Level
```dart
Consumer<ExpenseProvider>(
  builder: (context, provider, _) {
    if (provider.error != null) {
      return ErrorWidget(provider.error);
    }
    return TransactionList(provider.transactions);
  },
)
```

## 🎨 Design Patterns Used

1. **Provider Pattern**: State management with ChangeNotifier
2. **Repository Pattern**: Abstraction of data source (Hive)
3. **Adapter Pattern**: Serialization (TransactionAdapter)
4. **Observer Pattern**: Widget rebuilds on data changes
5. **Factory Pattern**: Category default initialization
6. **Immutable Objects**: All models use `copyWith()`
7. **Separation of Concerns**: UI/Logic/Data layers

## 📊 Class Diagram (Simplified)

```
┌─────────────────────────┐
│    ExpenseProvider      │
│   (ChangeNotifier)      │
├─────────────────────────┤
│ - List<Transaction>     │
│ - List<Category>        │
│ - double balance        │
├─────────────────────────┤
│ + addTransaction()      │
│ + updateTransaction()   │
│ + calculateBalance()    │
└────────────┬────────────┘
             │
             ├────────────────────────────────┐
             │                                │
     ┌───────▼──────────┐        ┌────────────▼────┐
     │ LocalRepository  │        │ ReportGenerator │
     ├──────────────────┤        ├─────────────────┤
     │ + readTx()       │        │ + generatePdf() │
     │ + createTx()     │        │ + generateCsv() │
     │ + updateTx()     │        └─────────────────┘
     │ + deleteTx()     │
     └────────┬─────────┘
              │
      ┌───────▼───────┐
      │   Hive Box    │
      │ (Persistence) │
      └───────────────┘
```

## 🚀 Performance Considerations

### 1. List Filtering
- **Current**: Filter on-the-fly in setState (O(n))
- **Future**: Use indexed collections for O(log n) lookup

### 2. Balance Calculation
- **Current**: Sum all incomes/expenses each time (O(n))
- **Future**: Cache calculation, invalidate on transaction change

### 3. Image Storage
- **Current**: Copy image to app directory, store path
- **Future**: Consider compression, thumbnail caching

### 4. Database Queries
- **Current**: Load all data into memory
- **Future**: Pagination for large datasets (10k+ transactions)

## 🔮 Future Extensibility

### Adding New Feature (Budget Management)

```
1. Add Budget model (✅ Done)
   lib/models/budget.dart

2. Add to Repository (✅ Done)
   lib/repositories/local_repository.dart
   + createBudget(), readBudgets(), deleteBudget()

3. Add to Provider (✅ Done in spec)
   lib/providers/expense_provider.dart
   + setBudget(), getBudget(), checkBudgetExceeded()

4. Create Service (✅ Done)
   lib/services/budget_notification.dart

5. Add UI Screens
   lib/screens/budget_screen.dart

6. Add Widgets
   lib/widgets/budget_card.dart

7. Update main.dart
   + Register BudgetAdapter
   + Open budgets box

8. Test
   test/budget_test.dart
   test/expense_provider_test.dart (update)
```

---

**This architecture enables easy testing, maintenance, and scaling of the Expense Tracker (Quản lý chi tiêu) application.**
