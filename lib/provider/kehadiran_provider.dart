/// Kehadiran Provider
/// UMPAR Magang & PKL System
///
/// State management for attendance tracking

import 'package:flutter/foundation.dart';
import '../data/model/kehadiran.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

class KehadiranProvider with ChangeNotifier {
  final ApiClient _apiClient;

  // State
  List<Kehadiran> _daftarKehadiran = [];
  StatistikKehadiran? _statistik;
  Kehadiran? _kehadiranHariIni;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Kehadiran> get daftarKehadiran => _daftarKehadiran;
  StatistikKehadiran? get statistik => _statistik;
  Kehadiran? get kehadiranHariIni => _kehadiranHariIni;
  bool get isLoading => _isLoading;
  String? get error => _error;

  KehadiranProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error state
  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetch attendance list for a pengajuan
  Future<bool> fetchKehadiran(int idPengajuan) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.get(
        '${ApiKonstanta.kehadiran}/$idPengajuan',
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _daftarKehadiran =
            data.map((json) => Kehadiran.fromJson(json)).toList();

        // Calculate statistics from list
        _statistik = StatistikKehadiran.fromList(_daftarKehadiran);

        // Find today's attendance
        _kehadiranHariIni = _daftarKehadiran.cast<Kehadiran?>().firstWhere(
              (k) => k?.isToday ?? false,
              orElse: () => null,
            );

        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Fetch statistics only
  Future<bool> fetchStatistik(int idPengajuan) async {
    try {
      final response = await _apiClient.get(
        '${ApiKonstanta.kehadiran}/$idPengajuan/statistik',
      );

      if (response.success && response.data != null) {
        _statistik = StatistikKehadiran.fromJson(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching statistik: $e');
      return false;
    }
  }

  /// Get today's attendance status
  Future<Kehadiran?> fetchKehadiranHariIni(int idPengajuan) async {
    try {
      final response = await _apiClient.get(
        '${ApiKonstanta.kehadiran}/today/$idPengajuan',
      );

      if (response.success && response.data != null) {
        _kehadiranHariIni = Kehadiran.fromJson(response.data);
        notifyListeners();
        return _kehadiranHariIni;
      }
      _kehadiranHariIni = null;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error fetching kehadiran hari ini: $e');
      return null;
    }
  }

  /// Input new attendance
  Future<bool> inputKehadiran(Kehadiran kehadiran) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.post(
        ApiKonstanta.kehadiran,
        body: kehadiran.toJson(),
      );

      if (response.success) {
        // Refresh list
        await fetchKehadiran(kehadiran.idPengajuan);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Check-in for today with GPS support
  Future<Map<String, dynamic>?> checkin(
    int idPengajuan, {
    double? latitude,
    double? longitude,
    double? akurasi,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.post(
        '${ApiKonstanta.kehadiran}/checkin',
        body: {
          'id_pengajuan': idPengajuan,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (akurasi != null) 'akurasi': akurasi.round(),
        },
      );

      if (response.success) {
        // Refresh today's attendance
        await fetchKehadiranHariIni(idPengajuan);
        _setLoading(false);
        return response.data;
      } else {
        _setError(response.message);
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      _setLoading(false);
      return null;
    }
  }

  /// Update attendance
  Future<bool> updateKehadiran(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.put(
        '${ApiKonstanta.kehadiran}/$id',
        body: data,
      );

      if (response.success) {
        // Update local data
        final index = _daftarKehadiran.indexWhere((k) => k.idKehadiran == id);
        if (index != -1 && _daftarKehadiran.isNotEmpty) {
          await fetchKehadiran(_daftarKehadiran.first.idPengajuan);
        }
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete attendance (admin only)
  Future<bool> deleteKehadiran(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.delete(
        '${ApiKonstanta.kehadiran}/$id',
      );

      if (response.success) {
        _daftarKehadiran.removeWhere((k) => k.idKehadiran == id);
        _statistik = StatistikKehadiran.fromList(_daftarKehadiran);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Get attendance by date range
  List<Kehadiran> getByDateRange(DateTime start, DateTime end) {
    return _daftarKehadiran.where((k) {
      return k.tanggal.isAfter(start.subtract(const Duration(days: 1))) &&
          k.tanggal.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get attendance by status
  List<Kehadiran> getByStatus(StatusKehadiran status) {
    return _daftarKehadiran.where((k) => k.statusKehadiran == status).toList();
  }

  /// Clear all data
  void clear() {
    _daftarKehadiran = [];
    _statistik = null;
    _kehadiranHariIni = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
