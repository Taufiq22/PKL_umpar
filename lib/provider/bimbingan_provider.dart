/// Bimbingan Provider
/// UMPAR Magang & PKL System
///
/// State management for guidance session tracking

import 'package:flutter/foundation.dart';
import '../data/model/bimbingan.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

class BimbinganProvider with ChangeNotifier {
  final ApiClient _apiClient;

  // State
  List<Bimbingan> _daftarBimbingan = [];
  Bimbingan? _selectedBimbingan;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Bimbingan> get daftarBimbingan => _daftarBimbingan;
  Bimbingan? get selectedBimbingan => _selectedBimbingan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<Bimbingan> get bimbinganDiajukan => _daftarBimbingan
      .where((b) => b.statusBimbingan == StatusBimbingan.diajukan)
      .toList();
  List<Bimbingan> get bimbinganDijadwalkan => _daftarBimbingan
      .where((b) => b.statusBimbingan == StatusBimbingan.dijadwalkan)
      .toList();
  List<Bimbingan> get bimbinganSelesai => _daftarBimbingan
      .where((b) => b.statusBimbingan == StatusBimbingan.selesai)
      .toList();

  BimbinganProvider({ApiClient? apiClient})
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

  /// Fetch all bimbingan
  Future<bool> fetchBimbingan({String? status}) async {
    _setLoading(true);
    _setError(null);

    try {
      String endpoint = ApiKonstanta.bimbingan;
      if (status != null) {
        endpoint += '?status=$status';
      }

      final response = await _apiClient.get(endpoint);

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _daftarBimbingan =
            data.map((json) => Bimbingan.fromJson(json)).toList();
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

  /// Fetch bimbingan by pengajuan ID
  Future<bool> fetchByPengajuan(int idPengajuan) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.get(
        '${ApiKonstanta.bimbingan}/pengajuan/$idPengajuan',
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _daftarBimbingan =
            data.map((json) => Bimbingan.fromJson(json)).toList();
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

  /// Get bimbingan detail by ID
  Future<Bimbingan?> getBimbinganById(int id) async {
    try {
      final response = await _apiClient.get('${ApiKonstanta.bimbingan}/$id');

      if (response.success && response.data != null) {
        _selectedBimbingan = Bimbingan.fromJson(response.data);
        notifyListeners();
        return _selectedBimbingan;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching bimbingan: $e');
      return null;
    }
  }

  /// Create new bimbingan request
  Future<bool> createBimbingan(Bimbingan bimbingan) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.post(
        ApiKonstanta.bimbingan,
        body: bimbingan.toJson(),
      );

      if (response.success) {
        await fetchBimbingan();
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

  /// Schedule bimbingan (pembimbing only)
  Future<bool> setJadwal(int id, DateTime tanggal, {String? lokasi}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.put(
        '${ApiKonstanta.bimbingan}/$id/jadwal',
        body: {
          'tanggal_bimbingan': tanggal.toIso8601String(),
          if (lokasi != null) 'lokasi_bimbingan': lokasi,
        },
      );

      if (response.success) {
        await fetchBimbingan();
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

  /// Complete bimbingan with feedback (pembimbing only)
  Future<bool> selesaikanBimbingan(int id, {String? feedback}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.put(
        '${ApiKonstanta.bimbingan}/$id/selesai',
        body: {
          if (feedback != null) 'feedback_pembimbing': feedback,
        },
      );

      if (response.success) {
        await fetchBimbingan();
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

  /// Give rating (student only)
  Future<bool> giveRating(int id, int rating) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.put(
        '${ApiKonstanta.bimbingan}/$id/rating',
        body: {'rating': rating},
      );

      if (response.success) {
        // Update local data
        final index = _daftarBimbingan.indexWhere((b) => b.idBimbingan == id);
        if (index != -1) {
          _daftarBimbingan[index] =
              _daftarBimbingan[index].copyWith(rating: rating);
        }
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

  /// Cancel bimbingan
  Future<bool> cancelBimbingan(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.put(
        '${ApiKonstanta.bimbingan}/$id/batal',
      );

      if (response.success) {
        await fetchBimbingan();
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

  /// Get bimbingan by status
  List<Bimbingan> getByStatus(StatusBimbingan status) {
    return _daftarBimbingan.where((b) => b.statusBimbingan == status).toList();
  }

  /// Clear all data
  void clear() {
    _daftarBimbingan = [];
    _selectedBimbingan = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
