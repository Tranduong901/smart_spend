# Smart Spend 💰

Ứng dụng quản lý chi tiêu cá nhân được xây dựng với Flutter. Theo dõi thu nhập, chi tiêu, phân tích xu hướng chi tiêu và quản lý ngân sách của bạn một cách dễ dàng.

## ✨ Tính Năng Chính

### 📊 Dashboard
- Xem tổng số dư hiện tại
- Nhập số dư ban đầu và chỉnh sửa bất kỳ lúc nào
- Biểu đồ chi tiêu theo danh mục (pie chart)
- Xem các giao dịch gần đây
- Tỷ giá USD → VND cập nhật

### ➕ Thêm Giao Dịch
- Chọn loại: **Chi tiêu** hoặc **Thu nhập**
- Chọn danh mục (hỗ trợ thêm danh mục mới)
- Nhập tiêu đề, số tiền, ngày, ghi chú
- Tải ảnh hoặc chụp biên lai (tính năng OCR)
- Số dư được cập nhật tự động

### 📜 Lịch Sử Giao Dịch
- Xem danh sách tất cả giao dịch
- Lọc theo tháng/năm
- Xóa giao dịch không cần thiết

### 📈 Phân Tích Chi Tiêu
- Xem chi tiêu tháng hiện tại vs tháng trước
- Chỉ số phần trăm tăng/giảm chi tiêu
- Biểu đồ hình tròn chi tiêu theo danh mục
- Phân tích chi tiết từng danh mục

## 🛠️ Công Nghệ Sử Dụng

- **Flutter 3.x** - Framework UI
- **Material Design 3** - Thiết kế giao diện
- **Provider 6.1.2** - State Management
- **Hive 2.2.3** - Lưu trữ dữ liệu cục bộ
- **FL_Chart 0.69.0** - Biểu đồ và thống kê
- **path_provider 2.1.5** - Quản lý file hệ thống

## 🚀 Cách Chạy

### Yêu Cầu
- Flutter SDK 3.0+
- Dart 3.0+
- Android SDK 21+ hoặc iOS 11+

### Cài Đặt
```bash
flutter pub get
flutter run
```

### Chọn Thiết Bị
```bash
# Chạy trên Android Emulator
flutter run -d emulator-5554

# Chạy trên iOS Simulator
flutter run -d iphone

# Chạy trên tất cả thiết bị
flutter devices
flutter run -d <device-id>
```

## 📂 Cấu Trúc Dự Án

```
lib/
├── main.dart                  # Entry point, navigation
├── screens/
│   ├── dashboard_screen.dart     # Trang tổng quan
│   ├── add_transaction_screen.dart # Thêm giao dịch
│   ├── history_screen.dart       # Lịch sử
│   └── analysis_screen.dart      # Phân tích chi tiêu
├── widgets/
│   ├── balance_card.dart         # Thẻ số dư (có chỉnh sửa)
│   ├── category_selector.dart    # Chọn danh mục
│   ├── expense_pie_chart.dart    # Biểu đồ hình tròn
│   ├── history_filter_bar.dart   # Lọc theo tháng/năm
│   ├── recent_transactions_list.dart
│   ├── transaction_tile.dart
│   └── receipt_capture_button.dart
├── providers/
│   └── expense_provider.dart     # State management
├── repositories/
│   ├── local_repository.dart     # Hive operations
│   └── exchange_rate_repository.dart
├── models/
│   └── transaction.dart
└── adapters/
    └── transaction_adapter.dart  # Serialization
```

## 💾 Lưu Trữ Dữ Liệu

Tất cả dữ liệu được lưu trữ **cục bộ** trên thiết bị sử dụng Hive:
- **Giao dịch** - Danh sách chi tiêu/thu nhập
- **Danh mục** - Danh mục chi tiêu và thu nhập
- **Sở thích** - Số dư ban đầu, thiết lập người dùng

❌ **Không có đình lạc nào lên cloud** - Dữ liệu 100% cục bộ

## 📝 Công Thức Tính Số Dư

```
Số dư hiện tại = Số dư ban đầu + Tổng thu nhập - Tổng chi tiêu
```

## 🐛 Gỡ Lỗi

### Kiểm Tra Lỗi
```bash
flutter analyze
```

### Chạy Test
```bash
flutter test
```

### Xóa Build Cache
```bash
flutter clean
flutter pub get
flutter run
```

## 📄 Giấy Phép

Dự án này được tạo cho mục đích quản lý chi tiêu cá nhân.
