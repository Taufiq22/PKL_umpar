import 'package:flutter/foundation.dart';
import '../data/model/nilai.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

/// Provider untuk manajemen nilai
class NilaiProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Nilai> _daftarNilai = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Nilai> get daftarNilai => _daftarNilai;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ambil semua nilai (untuk instansi)
  Future<void> ambilSemuaNilai() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get<List<dynamic>>(
        ApiKonstanta.nilai,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _daftarNilai =
            response.data!.map((json) => Nilai.fromJson(json)).toList();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ambil nilai berdasarkan id pengajuan
  Future<void> ambilNilai(int idPengajuan) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get<List<dynamic>>(
        '${ApiKonstanta.nilai}/$idPengajuan',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _daftarNilai =
            response.data!.map((json) => Nilai.fromJson(json)).toList();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Input nilai baru
  Future<bool> inputNilai({
    required int idPengajuan,
    required String aspekPenilaian,
    required double nilaiAngka,
    String? komentar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiKonstanta.nilai,
        body: {
          'id_pengajuan': idPengajuan,
          'aspek_penilaian': aspekPenilaian,
          'nilai_angka': nilaiAngka,
          'komentar': komentar,
        },
      );

      if (response.success) {
        await ambilNilai(idPengajuan);
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

  /// Update nilai
  Future<bool> updateNilai(
    int id, {
    String? aspekPenilaian,
    double? nilaiAngka,
    String? komentar,
    required int idPengajuan,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (aspekPenilaian != null) body['aspek_penilaian'] = aspekPenilaian;
      if (nilaiAngka != null) body['nilai_angka'] = nilaiAngka;
      if (komentar != null) body['komentar'] = komentar;

      final response = await _api.put(
        '${ApiKonstanta.nilai}/$id',
        body: body,
      );

      if (response.success) {
        await ambilNilai(idPengajuan);
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

  /// Get nilai dari pembimbing (Dosen/Guru)
  List<Nilai> get nilaiPembimbing {
    return _daftarNilai.where((n) => !n.isFromInstansi).toList();
  }

  /// Get nilai dari instansi
  List<Nilai> get nilaiInstansi {
    return _daftarNilai.where((n) => n.isFromInstansi).toList();
  }

  /// Hitung rata-rata nilai keseluruhan
  double get rataRataNilai {
    if (_daftarNilai.isEmpty) return 0;
    final total = _daftarNilai.fold<double>(
      0,
      (sum, n) => sum + n.nilaiAngka,
    );
    return total / _daftarNilai.length;
  }

  /// Alias untuk backward compatibility
  double get nilaiAkhirGabungan => rataRataNilai;

  double? hitungNilaiGabungan() {
    if (_daftarNilai.isEmpty) return null;
    return rataRataNilai;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
