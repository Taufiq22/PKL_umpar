import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../konfigurasi/konstanta.dart'; // Ensure this path is correct

class DashboardProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _adminStats;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get adminStats => _adminStats;

  Future<void> getAdminStats(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiKonstanta.baseUrl}/dashboard/admin/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _adminStats = data;
      } else {
        print('Gagal mengambil statistik: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getAdminStats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
