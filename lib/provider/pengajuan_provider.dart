import 'package:flutter/foundation.dart';
import '../data/model/pengajuan.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

/// Provider untuk manajemen pengajuan
class PengajuanProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Pengajuan> _daftarPengajuan = [];
  Pengajuan? _pengajuanAktif;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Pengajuan> get daftarPengajuan => _daftarPengajuan;
  Pengajuan? get pengajuanAktif => _pengajuanAktif;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ambil daftar pengajuan user
  Future<void> ambilPengajuan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get<List<dynamic>>(
        ApiKonstanta.pengajuan,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _daftarPengajuan =
            response.data!.map((json) => Pengajuan.fromJson(json)).toList();

        // Set pengajuan aktif (yang terakhir disetujui dan belum selesai)
        _pengajuanAktif = _daftarPengajuan.firstWhere(
          (p) => p.isDisetujui,
          orElse: () => _daftarPengajuan.isNotEmpty
              ? _daftarPengajuan.first
              : Pengajuan(
                  idPengajuan: 0, jenisPengajuan: JenisPengajuan.magang),
        );
        if (_pengajuanAktif?.idPengajuan == 0) _pengajuanAktif = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ambil detail pengajuan
  Future<Pengajuan?> ambilDetailPengajuan(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get<Map<String, dynamic>>(
        '${ApiKonstanta.pengajuan}/$id',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      _isLoading = false;
      notifyListeners();

      if (response.success && response.data != null) {
        return Pengajuan.fromJson(response.data!);
      } else {
        _error = response.message;
        return null;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Buat pengajuan baru
  Future<bool> buatPengajuan(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post<Map<String, dynamic>>(
        ApiKonstanta.pengajuan,
        body: data,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        await ambilPengajuan(); // Refresh daftar
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update pengajuan
  Future<bool> updatePengajuan(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put(
        '${ApiKonstanta.pengajuan}/$id',
        body: data,
      );

      if (response.success) {
        await ambilPengajuan(); // Refresh daftar
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verifikasi pengajuan (untuk pembimbing)
  Future<bool> verifikasiPengajuan(
    int id, {
    required bool disetujui,
    String? catatan,
    int? idPembimbing,
    String? tipePembimbing,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put(
        '${ApiKonstanta.pengajuan}/$id/verifikasi',
        body: {
          'disetujui': disetujui,
          if (catatan != null) 'catatan': catatan,
          if (idPembimbing != null) 'id_pembimbing': idPembimbing,
          if (tipePembimbing != null) 'tipe_pembimbing': tipePembimbing,
        },
      );

      if (response.success) {
        await ambilPengajuan(); // Refresh daftar
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Filter pengajuan berdasarkan status
  List<Pengajuan> filterByStatus(StatusPengajuan status) {
    return _daftarPengajuan.where((p) => p.statusPengajuan == status).toList();
  }

  /// Filter pengajuan berdasarkan jenis
  List<Pengajuan> filterByJenis(JenisPengajuan jenis) {
    return _daftarPengajuan.where((p) => p.jenisPengajuan == jenis).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Approval by Admin Fakultas (for Magang)
  Future<bool> approveByFakultas(
    int id, {
    required bool approved,
    String? catatan,
    int? idPembimbing,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put(
        '${ApiKonstanta.pengajuan}/$id/approve-fakultas',
        body: {
          'approved': approved,
          if (catatan != null) 'catatan': catatan,
          if (idPembimbing != null) 'id_pembimbing': idPembimbing,
        },
      );

      if (response.success) {
        await ambilPengajuan(); // Refresh daftar
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Approval by Admin Sekolah (for PKL)
  Future<bool> approveBySekolah(
    int id, {
    required bool approved,
    String? catatan,
    int? idPembimbing,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put(
        '${ApiKonstanta.pengajuan}/$id/approve-sekolah',
        body: {
          'approved': approved,
          if (catatan != null) 'catatan': catatan,
          if (idPembimbing != null) 'id_pembimbing': idPembimbing,
        },
      );

      if (response.success) {
        await ambilPengajuan(); // Refresh daftar
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get workflow status for a pengajuan
  Future<Map<String, dynamic>?> getWorkflowStatus(int id) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '${ApiKonstanta.pengajuan}/$id/workflow',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting workflow status: $e');
      return null;
    }
  }
}
