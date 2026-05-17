# 📝 NoteFlow – Flutter Notes Management App

A full-featured hybrid notes management app built with Flutter.

## ✅ Features
- Create, edit, delete notes
- Pin & favorite notes
- Category filtering (Work, Personal, Study, etc.)
- Tag support
- 10 color themes per note
- Search across title & content
- Grid & List view toggle
- SQLite local database (sqflite)
- Staggered masonry grid layout
- Dark-themed home UI with colorful note cards

## 📁 Project Structure
```
lib/
├── main.dart
├── models/
│   └── note.dart
├── services/
│   ├── database_service.dart
│   └── notes_provider.dart
├── screens/
│   ├── home_screen.dart
│   └── note_editor_screen.dart
└── widgets/
    ├── note_card.dart
    └── category_chip.dart
```

## 🚀 Setup in VS Code

### Step 1 – Install Flutter SDK
1. Go to https://docs.flutter.dev/get-started/install
2. Download Flutter SDK for your OS
3. Extract and add `flutter/bin` to your PATH

### Step 2 – Verify Installation
```bash
flutter doctor
```
Fix any issues shown (Android SDK, Xcode, etc.)

### Step 3 – Open in VS Code
1. Open VS Code
2. Install extensions: **Flutter** and **Dart** (search in Extensions panel)
3. Open Command Palette → `Flutter: New Project` OR just open this folder:
```bash
cd notes_app
code .
```

### Step 4 – Get Dependencies
```bash
flutter pub get
```

### Step 5 – Run the App
- Connect a device or start an emulator
- In VS Code: press **F5** or click Run → Start Debugging
- Or via terminal:
```bash
flutter run
```

### Step 6 – Build Release APK (Android)
```bash
flutter build apk --release
```

## 📦 Dependencies Used
| Package | Purpose |
|---|---|
| `sqflite` | SQLite local database |
| `provider` | State management |
| `google_fonts` | Beautiful typography |
| `flutter_staggered_grid_view` | Masonry grid layout |
| `intl` | Date formatting |
| `uuid` | Unique note IDs |
| `flutter_slidable` | Swipe-to-delete (optional) |
