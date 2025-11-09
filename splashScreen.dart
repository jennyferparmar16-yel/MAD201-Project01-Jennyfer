/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: splashScreen.dart
  Simple splash / welcome screen. Shows app title and navigates to
  Home after a short delay. Receives theme toggle callback from root.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/dbHelper.dart';
import 'homeScreen.dart';


class SplashScreen extends StatefulWidget {
  final void Function(bool) onThemeToggle;
  const SplashScreen({super.key, required this.onThemeToggle});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing database...';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      // Limit the warmUp wait so splash never hangs.
      await DBHelper().warmUp().timeout(const Duration(seconds: 3));
      _status = 'Database ready';
    } on TimeoutException {
      _status = 'Database init timed out';
    } catch (_) {
      _status = 'Database init issue';
    }
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(onThemeToggle: widget.onThemeToggle)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.account_balance_wallet, size: 96),
              SizedBox(height: 12),
              Text('Smart Budget Tracker Lite'),
              SizedBox(height: 4),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(_status, textAlign: TextAlign.center),
        ),
      );
}