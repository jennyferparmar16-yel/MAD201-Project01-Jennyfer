# MAD201-Project01-Jennyfer
A lightweight Flutter-based personal finance manager that helps users track daily expenses and incomes across devices — supporting both mobile and web platforms. Built with SQLite (sqflite) for offline data storage and analytics, and Material 3 design for a clean, modern UI.

Overview

Smart Budget Tracker Lite allows users to:
- Record transactions with details like title, amount, type, category, and date.  
- View a summary of spending categorized by income and expense.  
- Switch between **light and dark mode**, with preferences saved locally.  
- Use an offline-first experience powered by **SQLite** (with `sqflite_common_ffi_web` for the web version).

- Features

Add / Edit / Delete Transactions  
Categorize income and expenses (e.g., Food, Travel, Bills)  
Monthly summaries — auto-calculated per category  
Offline storage — powered by `sqflite` on mobile and `sqflite_common_ffi_web` on web  
Dark & Light mode — persisted with `shared_preferences`  
Cross-platform — works on Android, Windows, macOS, and Web  
Material 3 UI— clean and minimal interface

Technologies used:
Flutter, Dart, SQLite, sqflite, sqflite_common_ffi_web, path, shared_preferences

