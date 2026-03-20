# 🔤 Hướng Dẫn Cấu Hình Font Unicode Cho PDF (Tiếng Việt)

## 📥 Bước 1: Tải Font Files

Anh/chị cần tải 2 file font sau và đặt vào thư mục `assets/fonts/`:

### Option A: Roboto Font (Được khuyên dùng) ⭐
1. Truy cập: https://fonts.google.com/download?family=Roboto
2. Tải file `Roboto-Regular.ttf`
3. Đặt vào: `d:\Android\smart_spend\assets\fonts\Roboto-Regular.ttf`

**Hoặc** 

1. Tải trực tiếp từ: https://github.com/google/roboto/raw/main/fonts/Roboto-Regular.ttf
2. Đặt vào folder `assets/fonts/`

### Option B: NotoSans CJK Font (Backup)
Nếu Roboto không hoạt động:
1. Truy cập: https://fonts.google.com/download?family=Noto%20Sans%20CJK%20JP
2. Tải `NotoSansCJK-Regular.ttf`
3. Đặt vào: `d:\Android\smart_spend\assets\fonts\NotoSansCJK-Regular.ttf`

---

## 📂 Cấu Trúc Folder Sau Khi Tải

```
smart_spend/
├── assets/
│   └── fonts/
│       ├── Roboto-Regular.ttf          ← Font chính (BẮTBUỘC)
│       └── NotoSansCJK-Regular.ttf     ← Font backup (tuỳ chọn)
├── lib/
├── pubspec.yaml                        ← Đã cấu hình sẵn
└── ...
```

---

## ✅ Bước 2: Xác Nhận pubspec.yaml

Kiểm tra file `pubspec.yaml` đã có:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  pdf: ^3.12.0
  # ... các dependency khác

flutter:
  uses-material-design: true
  
  assets:
    - assets/fonts/
    - assets/
```

---

## 🔄 Bước 3: Chạy Flutter Pub Get

Mở Terminal và chạy:

```bash
flutter pub get
```

---

## 🧪 Bước 4: Test Chức Năng

Phần code sẽ tự động:
1. Load font Roboto từ `assets/fonts/Roboto-Regular.ttf`
2. Áp dụng cho **TẤT CẢ** text trong PDF
3. Hỗ trợ đầy đủ ký tự Việt:
   - Dấu huyền: á, à, ả, ã, ạ
   - Dấu sắc: é, ế
   - Dấu hỏi: ỏ
   - Dấu tilde: õ, ũ
   - Ký tự đặc biệt: đ, ơ, ư
   - **Ký tự tiền tệ: ₫ (U+20AB)**

---

## 🛠️ Xử Lý Lỗi

### Lỗi: "Unable to find a font to draw"
```
→ Kiểm tra file font `.ttf` có tồn tại trong `assets/fonts/`
→ Chắc chắn `pubspec.yaml` đã cấu hình `assets: - assets/fonts/`
→ Chạy `flutter pub get` lại
→ Clean & rebuild: `flutter clean && flutter pub get`
```

### Lỗi: "⚠️ font file not found"
```
→ Tên file phải chính xác: `Roboto-Regular.ttf`
→ Không dùng spaces hoặc ký tự đặc biệt trong tên file
→ Kiểm tra phần mở rộng file có đúng `.ttf`
```

### PDF vẫn hiển thị sai tiếng Việt
```
→ Chắc chắn đã load font TRƯỚC khi generate PDF
→ Xem console log: "✓ Font loaded" hay lỗi nào?
→ Thử dùng NotoSans CJK thay vì Roboto
```

---

## 📖 Tài Liệu Tham Khảo

- **PDF Package Docs**: https://pub.dev/packages/pdf
- **Google Fonts TTF Files**: https://fonts.google.com/
- **Unicode Character Reference**: https://unicode-table.com/
- **Vietnamese Diacritics**: https://en.wikipedia.org/wiki/Vietnamese_alphabet

---

## ⚙️ Chi Tiết Technical

### Tại sao Roboto?
- Hỗ trợ 1000+ ký tự Unicode ✓
- File size nhỏ (~180KB) ✓
- Hỗ trợ Bold, Italic ✓
- Tương thích với PDF specification ✓

### Ký Tự ₫ (U+20AB) - Đồng Việt
```
Unicode:     U+20AB
Decimal:     8363
Tên:         DONG SIGN
Được hỗ trợ: Roboto ✓, NotoSans ✓, DejaVu ✓
Không hỗ trợ: Helvetica ✗, Times Roman ✗
```

---

## 🎯 Kết Quả Mong Đợi

Sau khi áp dụng các bước trên:
✅ PDF hiển thị tiếng Việt không lỗi
✅ Ký tự ₫ xuất hiện đúng
✅ Không còn "Unable to find a font" warning
✅ Tất cả dấu thanh được render chính xác

---

**Chúc anh/chị thành công! 🎉**
