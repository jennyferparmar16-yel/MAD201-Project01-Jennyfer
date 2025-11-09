/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: modelAndSummaryScreen.dart
   Text-only reports screen. Shows totals grouped by (type, category)
   for the selected month. Allows month navigation with arrow buttons.
 */

import 'package:flutter/material.dart';
import '../services/dbHelper.dart';

class ModelAndSummaryScreen extends StatefulWidget {
  const ModelAndSummaryScreen({super.key});
  @override
  State<ModelAndSummaryScreen> createState() => _ModelAndSummaryScreenState();
}

class _ModelAndSummaryScreenState extends State<ModelAndSummaryScreen> {
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  Map<String, double> _rows = {};

  Future<void> _load() async {
    final map = await DBHelper().totalsByCategory(year: _year, month: _month);
    setState(() => _rows = map);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _changeMonth(int delta) {
    setState(() {
      final d = DateTime(_year, _month + delta, 1);
      _year = d.year;
      _month = d.month;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final ym = "${_year}-${_month.toString().padLeft(2, '0')}";
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton(onPressed: () => _changeMonth(-1), child: const Icon(Icons.chevron_left)),
                  const SizedBox(width: 12),
                  Text('Month: $ym'),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: () => _changeMonth(1), child: const Icon(Icons.chevron_right)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: _rows.entries
                    .map((e) => ListTile(title: Text(e.key), trailing: Text(e.value.toStringAsFixed(2))))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}