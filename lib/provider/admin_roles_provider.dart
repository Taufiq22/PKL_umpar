/// Admin Roles Provider
/// UMPAR Magang & PKL System
///
/// State management for Admin Fakultas and Admin Sekolah

import 'package:flutter/foundation.dart';
import '../data/model/admin_roles.dart';
import '../data/model/pengajuan.dart';
import '../data/sumber/api/api_client.dart';

class AdminRolesProvider with ChangeNotifier {
  final ApiClient _apiClient;

  // State - Admin Fakultas
  AdminFakultas? _profilFakultas;
  StatistikFakultas? _statistikFakultas;
  List<Pengajuan> _pengajuanFakultas = [];
  List<Map<String, dynamic>> _mahasiswaList = [];
  List<Map<String, dynamic>> _dosenList = [];

  // State - Admin Sekolah
  AdminSekolah? _profilSekolah;
  StatistikSekolah? _statistikSekolah;
  List<Pengajuan> _pengajuanSekolah = [];
  List<Map<String, dynamic>> _siswaList = [];
  List<Map<String, dynamic>> _guruList = [];

  // Common state
  bool _isLoading = false;
  String? _error;

  // Getters - Fakultas
  AdminFakultas? get profilFakultas => _profilFakultas;
  StatistikFakultas? get statistikFakultas => _statistikFakultas;
  List<Pengajuan> get pengajuanFakultas => _pengajuanFakultas;
  List<Map<String, dynamic>> get mahasiswaList => _mahasiswaList;
  List<Map<String, dynamic>> get dosenList => _dosenList;

  // Getters - Sekolah
  AdminSekolah? get profilSekolah => _profilSekolah;
  StatistikSekolah? get statistikSekolah => _statistikSekolah;
  List<Pengajuan> get pengajuanSekolah => _pengajuanSekolah;
  List<Map<String, dynamic>> get siswaList => _siswaList;
  List<Map<String, dynamic>> get guruList => _guruList;

  // Common getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminRolesProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== ADMIN FAKULTAS ====================

  /// Fetch admin fakultas profile
  Future<bool> fetchProfilFakultas() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.get('/admin-fakultas/profil');

      if (response.success && response.data != null) {
        _profilFakultas = AdminFakultas.fromJson(response.data);
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

  /// Fetch fakultas statistics
  Future<bool> fetchStatistikFakultas() async {
    try {
      final response = await _apiClient.get('/admin-fakultas/statistik');

      if (response.success && response.data != null) {
        _statistikFakultas = StatistikFakultas.fromJson(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching statistik fakultas: $e');
      return false;
    }
  }

  /// Fetch pengajuan by fakultas
  Future<bool> fetchPengajuanFakultas({String? status}) async {
    _setLoading(true);
    _setError(null);

    try {
      String endpoint = '/admin-fakultas/pengajuan';
      if (status != null) {
        endpoint += '?status=$status';
      }

      final response = await _apiClient.get(endpoint);

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _pengajuanFakultas =
            data.map((json) => Pengajuan.fromJson(json)).toList();
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

  /// Fetch mahasiswa list
  Future<bool> fetchMahasiswa() async {
    try {
      final response = await _apiClient.get('/admin-fakultas/mahasiswa');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _mahasiswaList = data.cast<Map<String, dynamic>>();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching mahasiswa: $e');
      return false;
    }
  }

  /// Fetch dosen pembimbing list
  Future<bool> fetchDosenPembimbing() async {
    try {
      final response = await _apiClient.get('/admin-fakultas/dosen');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _dosenList = data.cast<Map<String, dynamic>>();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching dosen: $e');
      return false;
    }
  }

  /// Tambah Dosen (Admin Fakultas)
  Future<bool> tambahDosen(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response =
          await _apiClient.post('/admin-fakultas/dosen', body: data);

      if (response.success) {
        await fetchDosenPembimbing();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Gagal menambah dosen: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Hapus Dosen (Admin Fakultas)
  Future<bool> hapusDosen(int idUser) async {
    _setLoading(true);
    try {
      final response = await _apiClient.delete('/admin-fakultas/dosen/$idUser');

      if (response.success) {
        await fetchDosenPembimbing();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Gagal menghapus dosen: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==================== ADMIN SEKOLAH ====================

  /// Fetch admin sekolah profile
  Future<bool> fetchProfilSekolah() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiClient.get('/admin-sekolah/profil');

      if (response.success && response.data != null) {
        _profilSekolah = AdminSekolah.fromJson(response.data);
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

  /// Fetch sekolah statistics
  Future<bool> fetchStatistikSekolah() async {
    try {
      final response = await _apiClient.get('/admin-sekolah/statistik');

      if (response.success && response.data != null) {
        _statistikSekolah = StatistikSekolah.fromJson(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching statistik sekolah: $e');
      return false;
    }
  }

  /// Fetch pengajuan by sekolah
  Future<bool> fetchPengajuanSekolah({String? status}) async {
    _setLoading(true);
    _setError(null);

    try {
      String endpoint = '/admin-sekolah/pengajuan';
      if (status != null) {
        endpoint += '?status=$status';
      }

      final response = await _apiClient.get(endpoint);

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _pengajuanSekolah =
            data.map((json) => Pengajuan.fromJson(json)).toList();
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

  /// Fetch siswa list
  Future<bool> fetchSiswa() async {
    try {
      final response = await _apiClient.get('/admin-sekolah/siswa');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _siswaList = data.cast<Map<String, dynamic>>();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching siswa: $e');
      return false;
    }
  }

  /// Fetch guru pembimbing list
  Future<bool> fetchGuruPembimbing() async {
    try {
      final response = await _apiClient.get('/admin-sekolah/guru');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        _guruList = data.cast<Map<String, dynamic>>();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error fetching guru: $e');
      return false;
    }
  }

  /// Tambah Guru (Admin Sekolah)
  Future<bool> tambahGuru(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await _apiClient.post('/admin-sekolah/guru', body: data);

      if (response.success) {
        await fetchGuruPembimbing();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Gagal menambah guru: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Hapus Guru (Admin Sekolah)
  Future<bool> hapusGuru(int idUser) async {
    _setLoading(true);
    try {
      final response = await _apiClient.delete('/admin-sekolah/guru/$idUser');

      if (response.success) {
        await fetchGuruPembimbing();
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Gagal menghapus guru: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Clear all data
  void clear() {
    _profilFakultas = null;
    _statistikFakultas = null;
    _pengajuanFakultas = [];
    _mahasiswaList = [];
    _dosenList = [];
    _profilSekolah = null;
    _statistikSekolah = null;
    _pengajuanSekolah = [];
    _siswaList = [];
    _guruList = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
