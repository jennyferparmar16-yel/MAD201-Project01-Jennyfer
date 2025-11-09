/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: homeScreen.dart
   Home dashboard: shows totals (income/expense/balance) and navigation
   buttons to Add, List, Reports, and Settings screens.
 */


import 'package:flutter/material.dart';
import '../services/dbHelper.dart';
import 'addTransactionScreen.dart';
import 'transactionListScreen.dart';
import 'modelAndSummaryScreen.dart';
import 'settingScreen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(bool) onThemeToggle;
  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, double> _totals = {'income': 0, 'expense': 0, 'balance': 0};

  Future<void> _load() async {
    final t = await DBHelper().computeTotals();
    setState(() => _totals = t);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    Widget metric(String title, double value, IconData icon) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icon),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(value.toStringAsFixed(2)),
              ]),
            ]),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Home Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          metric('Total Income', _totals['income'] ?? 0, Icons.trending_down),
          metric('Total Expense', _totals['expense'] ?? 0, Icons.trending_up),
          metric('Balance', _totals['balance'] ?? 0, Icons.account_balance_wallet),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
              _load();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionListScreen()));
              _load();
            },
            icon: const Icon(Icons.list),
            label: const Text('View Transactions'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingScreen(onThemeToggle: widget.onThemeToggle)),
              );
              _load();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}