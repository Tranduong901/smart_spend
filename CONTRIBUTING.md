# 🤝 Hướng Dẫn Đóng Góp (Contributing Guide)

## 👋 Chào Mừng!

Cảm ơn bạn muốn đóng góp cho **Smart Spend**! Tài liệu này hướng dẫn quy trình góp code, báo bug, và cải thiện dự án.

## 🐛 Báo Lỗi (Bug Reports)

### Trước Khi Báo
- Kiểm tra **Issues** đã có để tránh trùng lặp
- Test trên **phiên bản mới nhất** của code
- Chuẩn bị **thông tin chi tiết**

### Cách Báo Lỗi
Tạo Issue với template:

```markdown
## 📱 Mô Tả Lỗi
[Mô tả ngắn gọn lỗi]

## 🔄 Các Bước Tái Tạo
1. Làm gì trước
2. Làm gì
3. Kết quả không mong muốn

## ➗ Kết Quả Dự Kiến
[Điều gì nên xảy ra]

## 📸 Ảnh Chụp / Video
[Nếu có]

## 💻 Môi Trường
- Flutter version: flutter --version
- Device: iOS/Android, model
- OS: Windows/macOS/Linux version
```

## 💡 Đề Xuất Tính Năng (Feature Requests)

```markdown
## 📝 Tóm Tắt
[Mô tả tính năng]

## 📚 Ngữ Cảnh
[Tại sao bạn cần điều này?]

## 💪 Giải Pháp Đề Xuất
[Cách triển khai, mockup, v.v.]

## 🔄 Giải Pháp Thay Thế
[Có cách nào khác không?]
```

## 🔧 Quy Trình Phát Triển (Development)

### 1️⃣ Setup Môi Trường

```bash
# Clone repo
git clone <repo-url>
cd smart_spend

# Create feature branch
git checkout -b feature/your-feature-name

# Install dependencies
flutter pub get
```

### 2️⃣ Quy Tắc Naming Branch

```
feature/add-budget-screen          # New feature
feature/improve-search-performance  # Improvement
bugfix/fix-memory-leak             # Bug fix
docs/update-readme                 # Documentation
test/add-unit-tests               # Test addition
```

### 3️⃣ Viết Code

**Quy tắc Dart Style:**

```dart
// ✅ Good
class ExpenseProvider extends ChangeNotifier {
  final LocalRepository _repository;
  
  ExpenseProvider(this._repository);
  
  void addTransaction(Transaction tx) {
    // Logic here
    notifyListeners();
  }
}

// ❌ Bad
class expenseProvider extends ChangeNotifier {
  var repo;
  void add(t) { }
}
```

**File Organization:**
- Classes: PascalCase (`class ExpenseProvider`)
- Variables/Functions: camelCase (`final myVariable = 10`)
- Constants: camelCase (`const maxRetries = 3`)
- Imports: Group by type (dart, flutter, package, relative)

```dart
// Order imports properly
import 'dart:async';           // dart imports

import 'package:flutter/material.dart';  // flutter imports

import 'package:provider/provider.dart'; // package imports

import '../models/transaction.dart';     // relative imports
```

### 4️⃣ Commit Messages

Format: `<type>: <description>`

```bash
# ✅ Good
git commit -m "feat: add budget management screen"
git commit -m "fix: prevent balance calculation error on empty list"
git commit -m "docs: update installation guide"
git commit -m "test: increase provider test coverage to 85%"

# ❌ Bad
git commit -m "update"
git commit -m "fix bug"
git commit -m "changes made"
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Test addition/update
- `refactor`: Code refactor (no logic change)
- `perf`: Performance improvement
- `chore`: Build, deps, config, etc.

### 5️⃣ Test Requirements

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/expense_provider_test.dart

# Generate coverage report
flutter test --coverage

# View coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Minimum Coverage: 80%**

Test template:
```dart
void main() {
  group('ExpenseProvider', () {
    late ExpenseProvider provider;
    
    setUp(() {
      provider = ExpenseProvider();
    });
    
    test('should add transaction correctly', () {
      final tx = Transaction(...);
      provider.addTransaction(tx);
      expect(provider.transactions, contains(tx));
    });
  });
}
```

### 6️⃣ Code Analysis

```bash
# Run analyzer
flutter analyze

# Must have 0 issues before PR
# Fix with: dart fix --apply
```

### 7️⃣ Format Code

```bash
# Format dart files
dart format lib/ test/

# Or use the analyzer with --fix
flutter analyze --watch
```

## 📤 Gửi Pull Request (PR)

### Checklist Pre-PR

- [ ] Code follows Dart style guide
- [ ] `flutter analyze` returns 0 issues
- [ ] `flutter test` passes all tests
- [ ] Test coverage >= 80%
- [ ] Code is formatted with `dart format`
- [ ] Commit messages follow convention
- [ ] No merge conflicts with main
- [ ] Documentation updated (if needed)

### PR Template

```markdown
## 📝 Description
[Brief description of changes]

## 🔗 Related Issues
Closes #123

## 🧪 Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## 📸 Screenshots / Video
[If UI changes]

## 🔍 Code Review Checklist
- [ ] Follows project conventions
- [ ] No breaking changes
- [ ] Error handling implemented
- [ ] Performance considered
```

### PR Guidelines

**Do:**
- Keep PR focused on single feature/fix
- Write clear commit messages
- Reference related issues
- Request specific reviewers
- Update documentation

**Don't:**
- Change unrelated code
- Mix multiple features in one PR
- Ignore CI failures
- Rush the review process

## 🎓 Architecture Guidelines

### File Structure
```
lib/
├── models/              # Data models (no business logic)
├── screens/             # Full-page screens
├── widgets/             # Reusable UI components
├── providers/           # State management (ChangeNotifier)
├── repositories/        # Data access abstraction
├── services/            # Business logic services
├── adapters/            # Serialization (Hive, JSON, etc.)
└── main.dart           # App entry point
```

### State Management Pattern

```dart
// ✅ Provider with ChangeNotifier
class ExpenseProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  
  List<Transaction> get transactions => _transactions;
  
  void addTransaction(Transaction tx) {
    _transactions.add(tx);
    notifyListeners();  // UI rebuilds
  }
}

// Usage in Widget:
Consumer<ExpenseProvider>(
  builder: (context, provider, child) {
    return ListView(
      children: provider.transactions.map(...).toList(),
    );
  },
)
```

### Error Handling

```dart
// ✅ Good error handling
Future<void> loadData() async {
  try {
    final data = await repository.fetch();
    _data = data;
    notifyListeners();
  } catch (e) {
    _error = 'Failed to load data: $e';
    notifyListeners();
  }
}

// In UI:
if (provider.error != null) {
  return ErrorWidget(message: provider.error);
}
```

## 📚 Documentation Standards

### Dart Docs

```dart
/// Calculates total balance for the month.
/// 
/// Returns the sum of [startingBalance] plus all income
/// transactions minus all expense transactions.
/// 
/// Throws [StateError] if no starting balance is set.
double calculateTotalBalance() {
  // implementation
}
```

### File Headers

```dart
/// Service for managing expense calculations.
/// 
/// This service handles:
/// - Balance calculations
/// - Transaction aggregations
/// - Statistics generation
/// 
/// Example:
/// ```dart
/// final service = ExpenseService(repository);
/// final balance = service.calculateBalance();
/// ```
library expense_service;
```

## 🚀 Release Process

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Create release branch: `release/v1.0.0`
4. Build APK/IPA
5. Tag: `git tag v1.0.0`
6. Merge to main
7. Upload to store

## 📞 Communication

- **Slack/Discord**: For quick questions
- **Issues**: For bugs & features
- **Discussions**: For design decisions
- **Code Review**: Questions on PR

## 💰 Acknowledgments

Mỗi contributor sẽ được:
- Công nhận trong CONTRIBUTORS.md
- Mention trong release notes
- Credits tại documentation

---

**Cảm ơn bạn đã đóng góp! 🙌**

Nếu có câu hỏi, hãy tạo Discussion hoặc hỏi tại Issues.
