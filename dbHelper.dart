/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: dbHelper.dart
  SQLite helper using sqflite. Encapsulates DB open, schema creation,
  and CRUD queries. Provides simple aggregations for dashboard/report.
 */

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transactionModel.dart';

class DBHelper {
  // --- Singleton (one DB connection for the whole app) ---
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  // --- DB metadata ---
  static const _dbName = 'smart_budget.db';
  static const _dbVersion = 1;
  static const table = 'transactions';

  Database? _db;

  /// Lazily open database (creates on first use).
  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      singleInstance: true, // avoids duplicate openings (important on web)
      onCreate: (db, version) async {
        // Main table used across the app
        await db.execute('''
          CREATE TABLE $table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,        -- 'Income' | 'Expense'
            category TEXT NOT NULL,    -- e.g. Food/Travel/...
            date TEXT NOT NULL         -- ISO8601 string
          )
        ''');
      },
      onOpen: (db) => debugPrint('DB opened @ $path (web=$kIsWeb)'),
    );
    return _db!;
  }

  /// Quick ping so first DB call never blocks splash indefinitely.
  Future<void> warmUp() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT name FROM sqlite_master LIMIT 1');
    } catch (e) {
      // Do not crash splash; just log.
      debugPrint('DB warmUp error: $e');
    }
  }

  // -----------------------------
  // CRUD
  // -----------------------------

  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return db.insert(
      table,
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await database;
    return db.update(
      table,
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> allTransactions() async {
    final db = await database;
    final rows = await db.query(table, orderBy: 'date DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  // -----------------------------
  // Aggregations for UI
  // -----------------------------

  /// Returns {'income': x, 'expense': y, 'balance': x - y}
  Future<Map<String, double>> computeTotals() async {
    final db = await database;

    final incomeResult = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM $table
      WHERE type = 'Income'
    ''');

    final expenseResult = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM $table
      WHERE type = 'Expense'
    ''');

    final income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final expense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  /// Category totals for a given month (e.g., {'Food': 120.0, 'Travel': 80.0})
  Future<Map<String, double>> totalsByCategory({
    required int year,
    required int month,
  }) async {
    final db = await database;

    // First day (inclusive) and last moment of month (exclusive next month day 1)
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final result = await db.rawQuery('''
      SELECT category, SUM(amount) AS total
      FROM $table
      WHERE date >= ? AND date < ?
      GROUP BY category
    ''', [start, end]);

    final Map<String, double> data = {};
    for (final row in result) {
      final cat = row['category'] as String? ?? 'Unknown';
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      data[cat] = total;
    }
    return data;
  }
}






