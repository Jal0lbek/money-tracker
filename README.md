# 💰 Money Tracker — Shaxsiy Moliya Kuzatuvchi

> Uzbek tilida to'liq ishlovchi shaxsiy moliya tracker ilovasi (Flutter / Android)

---

## 📱 Ilova Haqida

**Money Tracker** — bu kundalik moliyaviy operatsiyalarni kuzatish uchun mo'ljallangan Android ilovasi.
To'liq Uzbek tilida, zamonaviy dark/light dizayn, PIN qulf va diagrammalar bilan.

---

## ✨ Asosiy Imkoniyatlar

| Funksiya | Tavsif |
|---|---|
| 💚 Kirim | Daromad qo'shish (hisob, sabab, sana) |
| 🔴 Chiqim | Xarajat qo'shish (kategoriya, izoh) |
| 🔵 O'tkazma | Hisoblar orasida pul o'tkazish |
| 📊 Hisobot | Bugungi / Haftalik / Oylik statistika |
| 📈 Diagrammalar | Kategoriyalar bo'yicha Pie chart |
| 🔐 PIN Qulf | 4 xonali PIN himoyasi |
| 🌙 Dark Mode | Qorong'u / Yorug' rejim |
| 🗂 Tarix | Tranzaksiyalar tarixi (filter bilan) |
| 🗑 O'chirish | Swipe qilib tranzaksiyani o'chirish |

---

## 🏦 Hisob Turlari

```
Naqd     💵  — Naqd pul balansi
Karta    💳  — Bank kartasi balansi  
Bank     🏦  — Bank hisobi balansi
Valyuta  💲  — Chet el valyutasi (USD)
```

---

## 📂 Loyiha Strukturasi

```
money_tracker/
├── lib/
│   ├── main.dart                    # Asosiy kirish nuqtasi + navigatsiya
│   ├── models/
│   │   ├── account_model.dart       # Hisob modeli
│   │   ├── transaction_model.dart   # Tranzaksiya modeli
│   │   └── category_model.dart      # Kategoriya modeli
│   ├── database/
│   │   └── database_helper.dart     # SQLite ma'lumotlar bazasi
│   ├── providers/
│   │   ├── finance_provider.dart    # Moliya holati (ChangeNotifier)
│   │   └── theme_provider.dart      # Tema + PIN holati
│   ├── screens/
│   │   ├── home_screen.dart         # Asosiy ekran
│   │   ├── add_income_screen.dart   # Kirim qo'shish
│   │   ├── add_expense_screen.dart  # Chiqim qo'shish
│   │   ├── transfer_screen.dart     # O'tkazma
│   │   ├── history_screen.dart      # Tranzaksiyalar tarixi
│   │   ├── report_screen.dart       # Hisobotlar + grafik
│   │   ├── pin_screen.dart          # PIN qulf ekrani
│   │   └── settings_screen.dart    # Sozlamalar
│   ├── widgets/
│   │   ├── account_card.dart        # Hisob kartochkasi
│   │   ├── transaction_item.dart    # Tranzaksiya elementi
│   │   ├── summary_card.dart        # Kirim/Chiqim xulosasi
│   │   ├── amount_input.dart        # Summa kiritish (formatlangan)
│   │   ├── account_selector.dart    # Hisob tanlash
│   │   └── date_selector.dart       # Sana tanlash
│   ├── theme/
│   │   └── app_theme.dart           # Dark/Light tema ranglari
│   └── utils/
│       └── app_utils.dart           # Yordamchi funksiyalar
├── android/                         # Android platforma kodi
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/.../MainActivity.kt
│   │       └── res/
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
└── pubspec.yaml                     # Flutter bog'liqliklar
```

---

## 🗄 Ma'lumotlar Bazasi Strukturasi (SQLite)

### `accounts` jadvali
```sql
CREATE TABLE accounts (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  name     TEXT NOT NULL,
  balance  REAL NOT NULL DEFAULT 0,
  type     TEXT NOT NULL,     -- naqd | karta | bank | valyuta
  currency TEXT NOT NULL DEFAULT 'UZS',
  icon     TEXT,
  color    TEXT
);
```

### `transactions` jadvali
```sql
CREATE TABLE transactions (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  type         TEXT NOT NULL,   -- kirim | chiqim | otkazma
  amount       REAL NOT NULL,
  account_from INTEGER,         -- Chiqim/O'tkazma uchun
  account_to   INTEGER,         -- Kirim/O'tkazma uchun
  category_id  INTEGER,
  note         TEXT,
  date         TEXT NOT NULL,   -- YYYY-MM-DD
  created_at   TEXT NOT NULL    -- ISO 8601
);
```

### `categories` jadvali
```sql
CREATE TABLE categories (
  id    INTEGER PRIMARY KEY AUTOINCREMENT,
  name  TEXT NOT NULL,
  type  TEXT NOT NULL,   -- kirim | chiqim
  icon  TEXT,
  color TEXT
);
```

### `settings` jadvali
```sql
CREATE TABLE settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

---

## 🚀 O'rnatish va Ishga Tushirish

### Talablar

- Flutter SDK **3.0.0+**
- Dart **3.0.0+**
- Android Studio **yoki** VS Code
- Android SDK (API 21+)
- Java JDK 11+

### Flutter o'rnatish

```bash
# Flutter SDK yuklab olish
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Flutter versiyasini tekshirish
flutter --version

# Muhitni tekshirish
flutter doctor
```

### Loyihani yuklab olish va ishga tushirish

```bash
# 1. Loyihani klonlash yoki papkaga o'tish
cd money_tracker

# 2. Bog'liqliklarni o'rnatish
flutter pub get

# 3. Qurilmaga ulash (USB yoki emulator)
flutter devices

# 4. Debug rejimida ishga tushirish
flutter run

# 5. Muayyan qurilmaga ishga tushirish
flutter run -d <device_id>
```

---

## 📦 APK Yaratish (Release)

### 1. Imzolash kaliti yaratish (bir marta)

```bash
keytool -genkey -v \
  -keystore ~/money_tracker_keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias money_tracker \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=MoneyTracker, OU=App, O=Company, L=Tashkent, S=Tashkent, C=UZ"
```

### 2. `key.properties` fayl yaratish

`android/` papkasida `key.properties` faylini yarating:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=money_tracker
storeFile=/Users/yourname/money_tracker_keystore.jks
```

### 3. `android/app/build.gradle` ga qo'shish

```groovy
// android blokidan oldin:
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 4. APK yaratish

```bash
# Debug APK (test uchun)
flutter build apk --debug

# Release APK (tarqatish uchun)
flutter build apk --release

# Split APK (kichikroq hajm)
flutter build apk --split-per-abi --release

# App Bundle (Google Play uchun)
flutter build appbundle --release
```

### 5. APK joylashuvi

```
build/app/outputs/
├── flutter-apk/
│   ├── app-debug.apk          # Debug APK
│   ├── app-release.apk        # Release APK (universal)
│   ├── app-arm64-v8a-release.apk   # 64-bit ARM
│   ├── app-armeabi-v7a-release.apk # 32-bit ARM
│   └── app-x86_64-release.apk      # x86_64
└── bundle/
    └── release/
        └── app-release.aab    # App Bundle
```

### 6. Qurilmaga o'rnatish

```bash
# ADB orqali o'rnatish
adb install build/app/outputs/flutter-apk/app-release.apk

# Yoki flutter orqali
flutter install
```

---

## 🛠 Muammolarni Hal Qilish

### `flutter doctor` xatolari

```bash
# Android lisenziyalarini qabul qilish
flutter doctor --android-licenses

# Gradle cache tozalash
cd android && ./gradlew clean && cd ..

# Flutter cache tozalash
flutter clean
flutter pub get
```

### Build xatolari

```bash
# Barcha cache tozalash
flutter clean
rm -rf ~/.gradle/caches/
flutter pub get
flutter build apk --release
```

### SQLite xatolari

Agar "database locked" xatosi chiqsa:
```bash
# Ilova ma'lumotlarini o'chirish
adb shell pm clear com.example.money_tracker
```

---

## 📦 Ishlatilgan Kutubxonalar

| Kutubxona | Versiya | Maqsad |
|---|---|---|
| `sqflite` | ^2.3.2 | SQLite ma'lumotlar bazasi |
| `provider` | ^6.1.2 | Holat boshqaruvi |
| `fl_chart` | ^0.68.0 | Diagrammalar (Pie, Bar) |
| `intl` | ^0.19.0 | Raqam va sana formatlash |
| `shared_preferences` | ^2.2.3 | PIN va sozlamalar saqlash |
| `flutter_animate` | ^4.5.0 | Animatsiyalar |
| `google_fonts` | ^6.2.1 | Space Grotesk shrift |
| `path_provider` | ^2.1.2 | Fayl yo'llari |
| `local_auth` | ^2.1.8 | Biometrik autentifikatsiya |

---

## 🎨 Dizayn Tizimi

### Ranglar

```dart
primaryGreen  = #00D4AA   // Asosiy yashil (Kirim, Jami)
primaryBlue   = #0066FF   // Ko'k (Karta)
accentOrange  = #FF6B35   // To'q sariq (Valyuta)
accentPurple  = #7C3AED   // Binafsha (Bank)
errorRed      = #FF4757   // Qizil (Chiqim, Xato)
```

### Dark Mode Fonlar

```dart
background    = #0A0E1A   // Asosiy fon
card          = #131929   // Karta foni
input         = #1A2332   // Input foni
border        = #1A2332   // Chegara
```

---

## 🔐 Xavfsizlik

- **PIN qulf**: 4 xonali raqamli PIN
- **SharedPreferences**: PIN xavfsiz saqlash
- **Lokal saqlash**: Barcha ma'lumotlar faqat qurilmada (serverga jo'natilmaydi)

---

## 📋 Kelajakdagi Rejalashtirilgan Imkoniyatlar

- [ ] Valyuta kurslari (real-time)
- [ ] Ma'lumotlarni eksport qilish (CSV/Excel)
- [ ] Bujetlash va limitlar
- [ ] Takroriy tranzaksiyalar
- [ ] Bulut sinxronizatsiya
- [ ] Barmoq izi bilan kirish
- [ ] Widget (uy ekranida balans)
- [ ] Bir nechta valyuta hisobi
- [ ] Grafik (kunlik trend)

---

## 👤 Muallif

**Money Tracker** — Flutter bilan yaratilgan  
Toshkent, O'zbekiston 🇺🇿

---

## 📄 Litsenziya

MIT License — erkin foydalanishingiz mumkin.
