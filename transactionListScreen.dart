/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: transactionListScreen.dart
   Displays all transactions from SQLite in a ListView. Allows editing
   and deletion. Adds new transactions via FAB button.
 */

import 'package:flutter/material.dart';
import '../models/transactionModel.dart';
import '../services/dbHelper.dart';
import 'addTransactionScreen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<TransactionModel> _items = [];

  Future<void> _load() async {
    final data = await DBHelper().allTransactions();
    setState(() => _items = data);
  }

  Future<void> _delete(int id) async {
    await DBHelper().deleteTransaction(id);
    _load();
  }

  Future<void> _edit(TransactionModel tx) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(existing: tx)));
    _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Color _amountColor(String type) => type == 'Income' ? Colors.green : Colors.red;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Transactions')),
        body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, i) {
            final tx = _items[i];
            return Card(
              child: ListTile(
                leading: Icon(tx.type == 'Income' ? Icons.trending_down : Icons.trending_up, color: _amountColor(tx.type)),
                title: Text(tx.title),
                subtitle: Text("${tx.type} • ${tx.category} • ${tx.date.toLocal().toString().split(' ').first}"),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(tx.amount.toStringAsFixed(2), style: TextStyle(color: _amountColor(tx.type), fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _edit(tx)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(tx.id!)),
                ]),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
            _load();
          },
          child: const Icon(Icons.add),
        ),
      );
}