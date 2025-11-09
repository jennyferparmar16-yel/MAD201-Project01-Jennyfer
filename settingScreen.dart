/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: settingScreen.dart
    currency code to persist. Also demonstrates a simple API call that
    fetches a USD -> currency rate and shows it as text.
 */

import 'package:flutter/material.dart';
import '../services/prefsService.dart';
import '../services/apiService.dart';

class SettingScreen extends StatefulWidget {
  final void Function(bool) onThemeToggle;
  const SettingScreen({super.key, required this.onThemeToggle});
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _dark = false;
  String _currency = 'USD';
  final _currencies = <String>['USD', 'CAD', 'EUR', 'GBP', 'JPY'];
  double? _rate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final p = PrefsService();
    _dark = await p.getThemeDark();
    _currency = await p.getCurrency();
    setState(() {});
  }

  Future<void> _toggleTheme() async {
    _dark = !_dark;
    await PrefsService().setThemeDark(_dark);
    widget.onThemeToggle(_dark);
    setState(() {});
  }

  Future<void> _saveCurrency(String v) async {
    _currency = v;
    await PrefsService().setCurrency(v);
    setState(() {});
  }

  Future<void> _fetchRate() async {
    setState(() {
      _loading = true;
      _rate = null;
    });
    _rate = await ApiService().usdTo(_currency);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeLabel = _dark ? 'Dark' : 'Light';
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(children: [
                    const Icon(Icons.color_lens),
                    const SizedBox(width: 8),
                    const Text('Theme'),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: _toggleTheme, child: Text('Toggle ($themeLabel)')),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.attach_money),
                    const SizedBox(width: 8),
                    const Text('Currency'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _currency,
                        items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) {
                          if (v != null) _saveCurrency(v);
                        },
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: const [
                  Icon(Icons.public),
                  SizedBox(width: 8),
                  Text('USD → Selected Currency (via API)'),
                ]),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _fetchRate, child: const Text('Fetch Conversion Rate')),
                const SizedBox(height: 8),
                if (_loading) const Text('Loading...'),
                if (!_loading && _rate != null) Text("1 USD = ${_rate!.toStringAsFixed(4)} $_currency"),
                if (!_loading && _rate == null) const Text('No rate available'),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}






