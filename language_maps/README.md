# Dart Language Map Generator

This script generates Dart localization maps from a CSV file (`translation.csv`) containing translation keys and values in different languages. The output is a Dart file (`language_maps.dart`) containing `Map<String, String>` for each language.

---

## 📝 Overview

- Input: A CSV file (`translation.csv`) with translation keys and values.
- Output: A Dart file with one map per language (e.g., `engToHi`, `engToEn`).
- Use case: For supporting multilingual UIs in a Flutter app using Dart code-based localization.

---

## 📂 Files

```
language_maps/
├── lang.csv                # Input CSV file with keys and translations
├── generate_maps.py        # Python script to generate Dart localization maps
├── language_maps.dart      # Output Dart file (generated)
└── README.md               # This file
```

---

## 📄 CSV Format (lang.csv)

The first column should be `key`, followed by one column for each language.

Example:

```
key,en,hi
greeting,Hello,नमस्ते
farewell,Goodbye,अलविदा
```

---

## 🚀 How to Use

### 1. Install dependencies

```bash
pip install pandas
```

### 2. Run the script

```bash
python generate_maps.py
```

If the `translation.csv` file is in the same directory, it will create `language_maps.dart` in the same folder.

---

## 🧪 Output Example (language_maps.dart)

```dart
Map<String, String> engToEn = {
  'greeting': 'Hello',
  'farewell': 'Goodbye',
};

Map<String, String> engToHi = {
  'greeting': 'नमस्ते',
  'farewell': 'अलविदा',
};
```

---

## 🔐 Notes

- The script escapes single quotes in translated values.
- Make sure `translation.csv` uses UTF-8 encoding to avoid character issues in non-English languages.
- Useful for hardcoded Dart localization in apps not using `.arb` files or `intl`.

---

## 📦 Requirements

- Python 3.x
- `pandas` library