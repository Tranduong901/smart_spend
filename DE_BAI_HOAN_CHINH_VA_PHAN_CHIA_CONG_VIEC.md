# 📱 Smart Spend - Đề bài hoàn chỉnh & Phân chia công việc 4 người

## 🎯 Mục Tiêu Dự Án
Xây dựng ứng dụng mobile (Flutter) quản lý chi tiêu cá nhân **100% offline** với đầy đủ chức năng theo dõi, phân tích, và sửa đổi giao dịch.

---

## 📋 Yêu Cầu Hoàn Chỉnh (Scope)

### A. Trang Chủ (Home Screen)
- ✅ Hiển thị số dư tổng = số dư ban đầu + tổng thu nhập - tổng chi tiêu
- ✅ Cho phép chỉnh sửa số dư ban đầu (nút edit + dialog)
- ✅ Danh sách giao dịch theo thời gian (mới nhất trước)
- ✅ Tìm kiếm giao dịch theo: tiêu đề, danh mục, ghi chú
- ✅ Lọc theo tháng/năm (mặc định tháng/năm hiện tại)
- ✅ Nút xóa và **nút sửa** (edit) cho mỗi giao dịch

### B. Trang Thêm/Sửa Giao Dịch (Add/Edit Screen)
- ✅ **Chế độ thêm mới**: Form trống, tiêu đề "Thêm giao dịch", nút "Lưu..."
- ✅ **Chế độ sửa**: Form điền sẵn dữ liệu, tiêu đề "Sửa giao dịch", nút "Cập nhật..."
- ✅ Chọn loại giao dịch: **Chi tiêu** / **Thu nhập** (dùng SegmentedButton)
- ✅ Validate: Tiêu đề, số tiền bắt buộc; số tiền > 0
- ✅ Nhập tiêu đề, số tiền, ghi chú, ngày
- ✅ **Mặc định ngày = hôm nay** (không cần click chọn)
- ✅ Chọn danh mục động theo loại giao dịch (tự chuyển khi đổi loại)
- ✅ Nút chụp/gắn hóa đơn (chỉ hiện với **Chi tiêu**, ẩn với **Thu nhập**)
- ✅ Lưu thành công → quay lại trang chủ + hiện thông báo

### C. Trang Phân Tích (Analysis Screen) & Thống Kê
#### C1. So Sánh Tháng
- ✅ So sánh chi tiêu tháng hiện tại vs tháng trước
- ✅ Tính % tăng/giảm (làm tròn 1 chữ số thập phân)
- ✅ Hiển thị icon (↑ đỏ = tăng, ↓ xanh = giảm, → xám = không đổi)
- ✅ Biểu đồ tròn chi tiêu theo danh mục (tháng hiện tại)
- ✅ Bảng breakdown danh mục: tên, số tiền, thanh progress %

#### C2. Dashboard Thống Kê Toàn Cộng
- ✅ Tổng thu nhập (từ đầu tháng / năm)
- ✅ Tổng chi tiêu (từ đầu tháng / năm)
- ✅ Số dư thực (actual balance hiện tại)
- ✅ Chi tiêu trung bình/ngày
- ✅ Thu nhập trung bình/ngày
- ✅ Top 3 danh mục chi tiêu (tháng này)
- ✅ Top 3 danh mục thu nhập (nếu có)

#### C3. Biểu Đồ Xu Hướng
- ✅ Line chart: Chi tiêu/Thu nhập theo tháng (12 tháng gần)
- ✅ Bar chart: Danh mục chi tiêu (so sánh tháng này vs trung bình)
- ✅ Tab chuyển đổi: Tháng/Quý/Năm

#### C4. Báo Cáo & Xuất Dữ Liệu
- ✅ Report tháng: Tổng thu/chi, danh mục breakdown, PDF preview
- ✅ Nút export PDF: Chi tiết giao dịch tháng (có table rõ)
- ✅ Nút export CSV: Dữ liệu giao dịch (để import Excel)

### D. Lưu Trữ Dữ Liệu (Persistence)
- ✅ Dùng **Hive** (SQLite local)
- ✅ Lưu: giao dịch, danh mục (chi/thu), số dư ban đầu
- ✅ Dữ liệu **giữ lại sau khi tắt/mở lại app**
- ✅ Hỗ trợ backward compatible (đọc dữ liệu cũ enum → string)
- ✅ Copy hình hóa đơn vào thư mục ứng dụng (isolation)

### E. Điều Hướng (Navigation)
- ✅ 2 tab chính ở thanh dưới: **Trang chủ** + **Phân tích**
- ✅ Floating Action Button (nút +) để mở form thêm giao dịch
- ✅ Click edit trên giao dịch → mở form sửa

### F. Danh Mục (Categories)
- ✅ Category model: id, name, isIncome, colorValue, iconCodePoint
- ✅ Danh mục chi tiêu mặc định: Ăn uống, Di chuyển, Shopping, ...
- ✅ Danh mục thu nhập mặc định: Lương, Thưởng, Khác, ...
- ✅ Hỗ trợ thêm danh mục mới động (trong form thêm giao dịch)

### H. Budget & Mục Tiêu Tiết Kiệm (Optional nhưng recommended)
- ✅ Tạo budget cho từng danh mục chi tiêu (tháng)
- ✅ So sánh chi tiêu hiện tại vs budget
- ✅ Progress bar: Đã dùng bao nhiêu % budget
- ✅ Cảnh báo: Nếu vượt budget → bật flag đỏ
- ✅ Mục tiêu tiết kiệm: Người dùng đặt target số tiền cần tiết kiệm/tháng
- ✅ Hiển thị progress tiết kiệm

### I. Cài Đặt (Settings) - Optional
- ✅ Thay đổi loại tiền (VND, USD, v.v.)
- ✅ Chế độ tối/sáng
- ✅ Thông báo cảnh báo (toggle on/off)
- ✅ Backup dữ liệu (export/import)
- ✅ Xóa toàn bộ dữ liệu

### G. Models & APIs
- ✅ **Transaction**: id, title, amount, categoryName, date, note, imagePath?, isIncome
- ✅ **Category**: id, name, isIncome, colorValue, iconCodePoint
- ✅ **Budget** (nếu có): categoryName, limitAmount, month, year
- ✅ **ExpenseProvider** (ChangeNotifier):
  - Transaction: addTransaction, deleteTransaction, updateTransaction, loadTransactions
  - Category: loadCategories, addCategory
  - Balance: calculateTotalBalance, setStartingBalance
  - Statistics: getTotalIncome, getTotalExpense, getByCategory, getByMonth
  - Budget: setBudget, getBudget, checkBudgetExceeded
- ✅ **LocalRepository**: Tất cả CRUD cho Hive (transactions, categories, budgets, preferences)
- ✅ **TransactionAdapter**: Serialize/deserialize kèm backward compatibility
- ✅ **ReportGenerator**: Generate PDF/CSV report từ dữ liệu giao dịch

---

## 📊 Phân Chia Công Việc 4 Người (Cân Bằng)

### Tiêu Chí Cân Bằng
- **Mỗi người ~10-12 điểm phức tạp** (testing + polish bao gồm) ← Tăng do scope mở rộng
- **Mỗi mảng là một feature hoàn chỉnh** (UI + logic + test)
- **Độ khó ngang nhau**: Dễ vừa, không quá đơn/phức tạp

### ⚠️ Lưu Ý
Scope app đã mở rộng để đạt yêu cầu "Expense Tracker" hoàn chỉnh. Nếu 4 người cảm thấy quá tải, **đề xuất tăng lên 5-6 người** hoặc giảm scope (loại bỏ Budget/Report).

---

## 👤 Người 1 - Home Screen & Search/Filter (~9 điểm)

### Trách Nhiệm
- Xây dựng & tối ưu trang chủ (Home Screen)
- Hiển thị số dư, danh sách giao dịch
- Tìm kiếm giao dịch (title, category, note)
- Lọc theo tháng/năm
- Nút edit/delete trên mỗi giao dịch

### Deliverables
- Trang Home render bình thường, dữ liệu chính xác
- Search hoạt động fluently (không lag)
- Filter tháng/năm chính xác 100%
- Nút edit mở form sửa đúng
- Nút delete xoá giao dịch, confirm trước xoá

### Code Files
- `lib/screens/home_screen.dart` (refactor + optimize)
- `lib/widgets/transaction_tile.dart` (thêm onEdit callback)
- Test: `test/home_screen_test.dart`

### Definition of Done
- Search tìm được theo 3 tiêu chí (title/category/note)
- Filter tháng/năm match dữ liệu thực
- Không crash khi dữ liệu trống/rất lớn
- UI không vỡ trên màn hình nhỏ
- Edit button click → chuyển sang form sửa

---

## 👤 Người 2 - Add/Edit Transaction Form (~9 điểm)

### Trách Nhiệm
- Xây dựng form Thêm/Sửa giao dịch (chế độ dual)
- Chuyển đổi loại giao dịch (Chi tiêu ↔ Thu nhập)
- Validate input, xử lý lỗi
- Default ngày = hôm nay
- Ẩn/hiện receipt button theo loại giao dịch

### Deliverables
- Form **Thêm**: Tiêu đề, số tiền, ghi chú, ngày (default today), loại, danh mục, receipt
- Form **Sửa**: Load dữ liệu cũ, cho chỉnh sửa, cập nhật vào DB
- Validate: Tiêu đề + số tiền bắt buộc, số tiền > 0
- Chuyển loại → danh mục tự reset phù hợp
- Receipt button ẩn khi Thu nhập, hiện khi Chi tiêu
- Nút submit: "Lưu chi tiêu/thu nhập" hoặc "Cập nhật chi tiêu/thu nhập"

### Code Files
- `lib/screens/add_transaction_screen.dart` (refactor + dual mode)
- `lib/widgets/dynamic_category_selector.dart` (optimize)
- Test: `test/add_transaction_test.dart`

### Definition of Done
- Form validate đúng mọi case (thiếu tiêu đề, tiền âm, v.v.)
- Lưu/cập nhật giao dịch vào DB thành công
- Default ngày = hôm nay
- Chuyển Chi tiêu ↔ Thu nhập mượt, category reset đúng
- Receipt button ẩn/hiện chính xác
- Quay lại Home sau khi lưu/cập nhật

---

## 👤 Người 3 - Analysis & Dashboard & Statistics (~11 điểm)

### Trách Nhiệm
- Xây dựng trang phân tích (Analysis Screen) - tăng tính năng
- Xây dựng dashboard thống kê toàn cộng (Overview)
- So sánh chi tiêu hiện tại vs trước
- Tính % tăng/giảm, xử lý edge case
- Biểu đồ xu hướng (line chart)
- Generate báo cáo PDF/CSV

### Deliverables
- **Analysis Screen (mở rộng)**:
  - Expense Change Card (so sánh tháng)
  - Pie Chart (chi tiêu theo danh mục)
  - Category Breakdown (tiền + %)
  
- **Dashboard/Overview Widget**:
  - Tổng thu nhập/chi tiêu (tháng/năm)
  - Trung bình chi tiêu/ngày
  - Top 3 danh mục chi/thu
  
- **Biểu Đồ Xu Hướng**:
  - Line chart: 12 tháng gần
  - Bar chart: Danh mục so sánh
  - Tab: Tháng/Quý/Năm
  
- **Report & Export**:
  - PDF report tháng (chi tiết giao dịch + summary)
  - CSV export (data để import Excel)
  - Nút export trong Analysis screen

### Code Files
- `lib/screens/analysis_screen.dart` (mở rộng)
- `lib/widgets/dashboard_overview.dart` (NEW)
- `lib/widgets/expense_pie_chart.dart` (optimize)
- `lib/widgets/category_breakdown.dart` (cải thiện)
- `lib/widgets/trend_chart.dart` (NEW - line/bar chart)
- `lib/widgets/report_preview.dart` (NEW)
- `lib/services/report_generator.dart` (NEW - PDF/CSV)
- Test: `test/analysis_screen_test.dart`, `test/report_test.dart`

### Definition of Done
- ✅ Dashboard hiển thị đúng: tổng, trung bình, top categories
- ✅ Biểu đồ xu hướng render đúng (line chart 12 tháng)
- ✅ % tăng/giảm tính chính xác
- ✅ PDF report xuất thành công (có chi tiết + summary)
- ✅ CSV xuất đúng format (tiêu đề + dữ liệu)
- ✅ Không crash edge case (0 giao dịch, dữ liệu lớn)

---

## 👤 Người 4 - Data Persistence, State Management, Budget & QA (~11 điểm)

### Trách Nhiệm
- Đảm bảo Hive lưu/tải dữ liệu ổn định
- ExpenseProvider logic chính xác (add/update/delete, statistics)
- Budget model & CRUD
- Test data persistence (tắt/mở app vẫn OK)
- QA regression, report lỗi, final polish

### Deliverables
- **LocalRepository**: CRUD cho Transaction, Category, **Budget** (NEW)
- **Budget Model**: categoryName, limitAmount, month, year, createdAt
- **ExpenseProvider**: 
  - Transaction: addTransaction, updateTransaction, deleteTransaction
  - Category: loadCategories, addCategory
  - Budget: setBudget, getBudget, checkBudgetExceeded (return bool)
  - Statistics: getTotalIncome, getTotalExpense, getByCategory, getByMonth
  - calculateTotalBalance + setStartingBalance
- **BudgetNotification Service** (optional): Cảnh báo khi vượt budget (local notification)
- **TransactionAdapter**: Backward compatible
- Test:
  - `test/local_repository_test.dart` (CRUD + Budget)
  - `test/expense_provider_test.dart` (logic + statistics)
  - `test/budget_test.dart` (budget logic)
  - `test/data_persistence_test.dart` (tắt/mở app)
- Regression Checklist: 25+ case test

### Code Files
- `lib/repositories/local_repository.dart` (thêm budget table)
- `lib/models/budget.dart` (NEW)
- `lib/providers/expense_provider.dart` (thêm budget + statistics methods)
- `lib/services/budget_notification.dart` (optional)
- `lib/adapters/transaction_adapter.dart` (verify)
- `test/` (viết test suite)

### Definition of Done
- ✅ `flutter analyze` sạch 100%
- ✅ CRUD giao dịch/danh mục/budget đúng
- ✅ updateTransaction → data thay đổi UI
- ✅ Statistics API trả kết quả chính xác
- ✅ budgetExceeded logic chính xác
- ✅ Tắt app → mở lại: dữ liệu, budget, setting vẫn OK
- ✅ Test coverage >= 80%
- ✅ Báo cáo 3-5 lỗi/polish + cách fix

---

## 📅 Timeline Gợi Ý (1 Sprint = 5 ngày)

| Ngày | Mục Tiêu |
|------|----------|
| **Ngày 1** | Chốt yêu cầu, chia branch Git, setup environment |
| **Ngày 2-3** | Mỗi người code feature riêng + test nội bộ |
| **Ngày 4** | Merge code, fix conflict, QA chéo chéo |
| **Ngày 5** | Final polish, demo, release |

---

## ✅ Tiêu Chí Hoàn Thành (Definition of Done)

### Code Quality
- ✅ `flutter analyze` không lỗi
- ✅ Code follow Dart style guide
- ✅ Comment documenting complex logic
- ✅ Không có unused imports/variables

### Functionality
- ✅ Tất cả tính năng hoạt động đúng theo spec
- ✅ Edge case xử lý (trống, lỗi, dữ liệu lớn)
- ✅ Performance OK (không lag, load < 2s)
- ✅ Persistence: tắt/mở app vẫn OK

### Testing
- ✅ Unit test: >= 80% code coverage
- ✅ Widget test: Main screens & flows
- ✅ Manual regression test: Checklist 20+ case

### UX/UI
- ✅ Responsive trên màn hình 5-6 inch
- ✅ Message feedback rõ ràng (snackbar/dialog)
- ✅ Không crash, xử lý lỗi graceful
- ✅ Thai hóa (Tiếng Việt) 100%

---

## 🛠️ Tech Stack (Đã Setup)
- **Flutter 3.x** + **Dart 3.0+**
- **Provider 6.1.2** (state management)
- **Hive 2.2.3** (local database)
- **FL_Chart 0.69.0** (charts)
- **Material Design 3**

---

## 🎓 Kỳ Vọng Output - Expense Tracker Hoàn Chỉnh

Sau sprint này, app sẽ là một **Expense Tracker chuyên nghiệp** với:

1. ✅ **Ghi chép đầy đủ**: Add/edit/delete transaction, phân loại theo danh mục
2. ✅ **Theo dõi về dư**: Dashboard số dư + tính toán tự động
3. ✅ **Thống kê tài chính cá nhân**:
   - Dashboard: Tổng thu/chi, trung bình, top categories
   - Biểu đồ xu hướng: 12 tháng, quý, năm
   - Report: PDF/CSV chi tiết giao dịch
4. ✅ **Quản lý budget**: Đặt limit/danh mục, cảnh báo vượt budget
5. ✅ **100% offline** - không cần internet
6. ✅ **Data persistence** - tắt/mở app vẫn OK
7. ✅ **Code clean** - dễ maintain, mở rộng
8. ✅ **Có test** - coverage >= 80%
9. ✅ **UI/UX tốt** - responsive, feedback rõ, tiếng Việt

---

## 📌 Option: Phân Chia 5-6 Người (Nếu muốn tránh quá tải)

Nếu 4 người cảm thấy scope quá nặng, đây là cách chia cho **5-6 người** (mỗi người ~8 điểm):

| Người | Mảng | Trách Nhiệm |
|-------|------|------------|
| **1** | **Home** | Home Screen, search, filter, edit/delete |
| **2** | **Add/Edit Form** | Form dual-mode, validate, default date, receipt |
| **3** | **Analysis** | Analysis screen, comparison, pie chart, breakdown |
| **4** | **Dashboard & Reports** | Overview stats, trend chart, PDF/CSV export |
| **5** | **Budget & Notifications** | Budget model, CRUD, cảnh báo, settings |
| **6** | **Persistence & QA** | LocalRepository, ExpenseProvider, test suite, regression |

Tuy nhiên, **phân chia 4 người vẫn khả thi** nếu mỗi người:
- Làm việc hiệu quả (code nhanh, test đầy đủ)
- Nhờ support tiền vị khi cần
- Tập trung vào core feature trước (ignore optional: Settings, Budget notification)

---
- Mỗi người là **owner** của mảng riêng (commit/review/QA)
- Tương tác qua **Pull Request** (code review)
- **Main branch** là released version (protect)
- Mỗi person hoàn thành → demo + checklist DoD trước merge
