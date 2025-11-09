/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: main.dart
  Entry point of the app. Sets up theme based on saved preference and
 launches the SplashScreen. Uses Navigator for screen transitions.

 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'services/prefsService.dart';
import 'screens/splashScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 if (kIsWeb) {
    // Use the web factory (no initWeb call needed)
    databaseFactory = databaseFactoryFfiWeb; 
    // If you specifically need to avoid a SharedWorker (e.g., some browsers),
    // use the basic worker version instead:
    // databaseFactory = databaseFactoryFfiWebNoWebWorker;
  } else {
    // Desktop (and optionally mobile if you use ffi there)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool(PrefsKeys.themeDark) ?? false;
  runApp(MyApp(isDark: isDark));
}

class MyApp extends StatefulWidget {
  final bool isDark;
  const MyApp({super.key, required this.isDark});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _dark = widget.isDark;
  Future<void> _toggleTheme(bool v) async {
    setState(() => _dark = v);
    await PrefsService().setThemeDark(v);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Budget Tracker Lite',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(onThemeToggle: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}








