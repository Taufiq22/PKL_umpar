import 'package:flutter/foundation.dart';
import '../data/model/laporan.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

/// Provider untuk manajemen laporan
class LaporanProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Laporan> _daftarLaporan = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Laporan> get daftarLaporan => _daftarLaporan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ambil daftar laporan
  Future<void> ambilLaporan({int? idPengajuan, JenisLaporan? jenis}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (idPengajuan != null) {
        queryParams['id_pengajuan'] = idPengajuan.toString();
      }
      if (jenis != null) queryParams['jenis'] = jenis.label;

      final response = await _api.get<List<dynamic>>(
        ApiKonstanta.laporan,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _daftarLaporan =
            response.data!.map((json) => Laporan.fromJson(json)).toList();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Upload laporan baru
  Future<bool> uploadLaporan(Map<String, dynamic> data,
      {String? filePath}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (filePath != null) {
        final response = await _api.upload(
          ApiKonstanta.laporan,
          filePath: filePath,
          fieldName: 'file_laporan',
          fields: data.map((k, v) => MapEntry(k, v.toString())),
        );

        if (response.success) {
          await ambilLaporan(idPengajuan: data['id_pengajuan']);
          return true;
        } else {
          _error = response.message;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        final response = await _api.post(
          ApiKonstanta.laporan,
          body: data,
        );

        if (response.success) {
          await ambilLaporan(idPengajuan: data['id_pengajuan']);
          return true;
        } else {
          _error = response.message;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Review laporan (untuk pembimbing)
  Future<bool> reviewLaporan(
    int id, {
    required String status,
    String? komentar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put(
        '${ApiKonstanta.laporan}/$id/review',
        body: {
          'status': status,
          if (komentar != null) 'komentar_pembimbing': komentar,
        },
      );

      if (response.success) {
        await ambilLaporan();
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

  /// Buat laporan baru (alias untuk uploadLaporan tanpa file)
  Future<bool> buatLaporan(Map<String, dynamic> data) async {
    return uploadLaporan(data);
  }

  /// Filter laporan berdasarkan jenis
  List<Laporan> filterByJenis(JenisLaporan jenis) {
    return _daftarLaporan.where((l) => l.jenisLaporan == jenis).toList();
  }

  /// Get laporan harian
  List<Laporan> get laporanHarian => filterByJenis(JenisLaporan.harian);

  /// Get laporan monitoring
  List<Laporan> get laporanMonitoring => filterByJenis(JenisLaporan.monitoring);

  /// Get laporan bimbingan
  List<Laporan> get laporanBimbingan => filterByJenis(JenisLaporan.bimbingan);

  /// Get laporan yang disetujui
  List<Laporan> get laporanDisetujui =>
      _daftarLaporan.where((l) => l.status == StatusLaporan.disetujui).toList();

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
