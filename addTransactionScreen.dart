/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: addTransactionScreen.dart
    Add/Edit transaction screen. Uses TextFields, DropdownButtons,
    and a DatePicker. Persists to SQLite via DBHelper.
 */
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/transactionModel.dart';
import '../services/dbHelper.dart';


class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.existing});
  final TransactionModel? existing;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  // dropdowns
  String _type = 'Expense';
  String _category = 'General';
  DateTime _date = DateTime.now();
  bool _busy = false;

  final _types = <String>['Income', 'Expense'];
  final _cats = <String>['General', 'Food', 'Travel', 'Bills', 'Salary', 'Gift', 'Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _amountController.text = e.amount.toStringAsFixed(2);
      _type = e.type;
      _category = e.category;
      _date = e.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _norm(String s) => s.replaceAll(RegExp(r'[^\d,.\-]'), '').replaceAll(',', '.');

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_norm(_amountController.text.trim())) ?? 0.0;
    final tx = TransactionModel(
      id: widget.existing?.id,
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
    );

    setState(() => _busy = true);
    try {
      if (widget.existing == null) {
        await DBHelper().insertTransaction(tx).timeout(const Duration(seconds: 4));
      } else {
        await DBHelper().updateTransaction(tx).timeout(const Duration(seconds: 4));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      Navigator.pop(context);
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database timed out. Try again.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('DB error: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Title required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount (e.g. 123.45)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final val = double.tryParse(_norm((v ?? '').trim())) ?? 0.0;
                      return val > 0 ? null : 'Enter positive amount';
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _type,
                          items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _type = v ?? _type),
                          decoration: const InputDecoration(labelText: 'Type'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _category,
                          items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _category = v ?? _category),
                          decoration: const InputDecoration(labelText: 'Category'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 8),
                      Text("${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}"),
                      const SizedBox(width: 12),
                      ElevatedButton(onPressed: _pickDate, child: const Text('Pick Date')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _busy ? null : _saveTransaction,
                    icon: const Icon(Icons.save),
                    label: Text(isEdit ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_busy) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
      ],
    );
  }
}
