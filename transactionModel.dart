/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: transactionModel.dart
   Data model for a budget transaction. Includes helpers to convert to
   and from Map for SQLite persistence.
 */

class TransactionModel {
  final int? id;                // null for new rows
  final String title;           // short description
  final double amount;          // positive number
  final String type;            // 'Income' or 'Expense'
  final String category;        // e.g., Food/Travel/etc.
  final DateTime date;          // transaction date

  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  // Convert object -> DB row.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date.toIso8601String(),
      };

  // Convert DB row -> object.
  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'] as int?,
        title: (m['title'] ?? '') as String,
        amount: (m['amount'] as num).toDouble(),
        type: (m['type'] ?? 'Expense') as String,
        category: (m['category'] ?? 'General') as String,
        date: DateTime.parse(m['date'] as String),
      );
}

