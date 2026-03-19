# 📱 Expense Tracker (Quản lý chi tiêu) - Hướng Dẫn Cài Đặt

## 🎯 Yêu Cầu Hệ Thống

- **Flutter**: >= 3.3.0
- **Dart**: >= 3.0
- **Android SDK**: API level 21+ (hoặc SDK 25+ nếu sử dụng emulator)
- **iOS**: iOS 12.0+ (nếu build cho iOS)
- **RAM**: Tối thiểu 4GB
- **Dung lượng**: ~100MB cho build

## 🛠️ Bước 1: Cài Đặt Flutter

### Windows
1. Download Flutter SDK từ [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extract vào thư mục (ví dụ: `C:\flutter` hoặc `D:\flutter`)
3. Thêm `C:\flutter\bin` vào PATH:
   - Mở `Environment Variables`
   - Thêm Flutter bin path vào `PATH`
4. Mở PowerShell và chạy:
   ```bash
   flutter doctor
   ```
5. Cài đặt các dependencies còn thiếu theo hướng dẫn của `flutter doctor`

### macOS
```bash
# Using Homebrew
brew install flutter

# Or download from flutter.dev and add to PATH
export PATH="$PATH:[FLUTTER_INSTALL_PATH]/flutter/bin"
```

### Linux
```bash
# Download and extract
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter doctor
```

## 📦 Bước 2: Clone & Setup Project

```bash
# Clone repository
git clone <repository-url> smart_spend
cd smart_spend

# Get dependencies
flutter pub get

# (Optional) Generate code if using code generation
# flutter pub run build_runner build --delete-conflicting-outputs
```

## ✅ Bước 3: Verify Installation

```bash
# Check environment
flutter doctor

# Run analysis
flutter analyze

# Run tests
flutter test

# (Optional) Check web build
flutter doctor -v
```

## 🚀 Bước 4: Chạy Ứng Dụng

### Android (Emulator)
```bash
# List available devices
flutter devices

# Run trên emulator
flutter run

# Run trên device cụ thể
flutter run -d <device_id>

# Run release build
flutter run --release
```

### Android (Device thực)
1. Bật USB Debugging trên device
2. Kết nối device qua USB cable
3. Chạy:
   ```bash
   flutter devices
   flutter run
   ```

### iOS (macOS only)
```bash
# Run trên simulator
flutter run

# Run trên device thực
flutter run -d <device_id>

# Build release
flutter build ios --release
```

### Web (Nếu cần)
```bash
# Enable web support
flutter config --enable-web

# Run web version
flutter run -d web-server

# Build web
flutter build web --release
```

## 📝 Bước 5: Cấu Hình (Optional)

### Thay đổi Application ID
File: `android/app/build.gradle.kts`
```kotlin
namespace = "com.example.smart_spend"  // Thay đổi thành unique ID của bạn
```

### Cài Đặt API Keys (Nếu dùng)
Hiện tại ứng dụng **100% offline** không cần API keys.

### Custom Theme
File: `lib/main.dart`
```dart
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,  // Thay đổi color seed của bạn
  ),
)
```

## 🐛 Troubleshooting

### Lỗi: "Flutter not found"
```bash
# Thêm Flutter vào PATH hoặc chạy:
[FLUTTER_PATH]\flutter\bin\flutter doctor
```

### Lỗi: "Gradle build failed"
```bash
# Clean gradle cache
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Lỗi: "Android SDK not found"
```bash
# Install Android SDK
flutter pub get
flutter doctor --android-licenses
# Chấp nhận tất cả licenses
```

### Lỗi: "Hive database error"
```bash
# Xóa app data và rebuild
flutter clean
rm -rf build ios android
flutter pub get
flutter run
```

### Chậm lần đầu chạy?
- Chuyên biệt lần đầu build, Flutter compile code (mất 2-5 phút)
- Lần chạy thứ 2+ sẽ nhanh hơn (hot reload ~1 giây)

## 📱 Default Test Data

Ứng dụng khởi tạo với:
- **Số dư ban đầu**: 0 ₫ (người dùng có thể chỉnh sửa)
- **Danh mục chi tiêu**: Ăn uống, Di chuyển, Shopping, v.v.
- **Danh mục thu nhập**: Lương, Thưởng, Khác, v.v.

Không có pre-loaded transactions - người dùng cần add thủ công.

## 🔄 Hot Reload vs Hot Restart

```bash
# Trong khi chạy:
# Press 'r' để hot reload (giữ state)
# Press 'R' để hot restart (reset state)
# Press 'q' để quit
```

- **Hot Reload**: Nhanh (~1s), giữ application state
- **Hot Restart**: Chậm hơn (~3s), reset app thành trạng thái ban đầu

## 📚 Build Release

### Android APK
```bash
# Build APK
flutter build apk --release

# Build AAB (cho Google Play)
flutter build appbundle --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS IPA
```bash
# Build IPA
flutter build ipa --release

# Output: build/ios/ipa/
```

## 🗂️ Cấu Trúc Thư Mục Quan Trọng

```
smart_spend/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   ├── screens/               # UI screens
│   ├── widgets/               # Reusable widgets
│   ├── providers/             # State management
│   ├── repositories/          # Data access
│   ├── services/              # Business logic
│   └── adapters/              # Serialization
├── android/                   # Android native code
├── ios/                       # iOS native code
├── pubspec.yaml               # Dependencies
├── analysis_options.yaml      # Linter config
└── test/                      # Unit & widget tests
```

## 🤝 Hỗ Trợ

- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Dart Packages**: https://pub.dev
- **Documentation**: https://flutter.dev/docs

---

**Chúc bạn cài đặt thành công! 🎉**
