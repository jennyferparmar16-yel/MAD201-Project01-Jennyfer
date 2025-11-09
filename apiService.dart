/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: apiService.dart
   Minimal HTTP service to fetch currency conversion rate using a free
   public API. For coursework/demo only (no API key handling here).
 */
// File: lib/services/apiService.dart


import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Returns USD -> target conversion rate, or null on error.
  Future<double?> usdTo(String target) async {
    try {
      // Example endpoint; response contains { rates: { "EUR": 0.9, ... } }
      final uri = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
      final res = await http.get(uri);

      // Parse JSON if success.
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final rates = (data['rates'] ?? {}) as Map<String, dynamic>;
        final val = rates[target.toUpperCase()];
        if (val is num) return val.toDouble();
      }
      return null;
    } catch (_) {
      // Network/parse error; return null so UI can show fallback.
      return null;
    }
  }
}
