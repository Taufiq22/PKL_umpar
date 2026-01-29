import 'package:flutter/material.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

/// Provider untuk menangani data cetak laporan (Admin)
class CetakProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ambil rekap data mahasiswa
  Future<List<dynamic>> getRekapMahasiswa() async {
    return _fetchData('${ApiKonstanta.cetak}/mahasiswa');
  }

  /// Ambil rekap data siswa
  Future<List<dynamic>> getRekapSiswa() async {
    return _fetchData('${ApiKonstanta.cetak}/siswa');
  }

  /// Ambil rekap nilai
  Future<List<dynamic>> getRekapNilai() async {
    return _fetchData('${ApiKonstanta.cetak}/nilai');
  }

  Future<List<dynamic>> _fetchData(String endpoint) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(endpoint);
      if (response.success) {
        return (response.data as List<dynamic>?) ?? [];
      } else {
        _error = response.message;
        return [];
      }
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ambil data surat permohonan
  Future<Map<String, dynamic>?> getSuratPermohonan(int idPengajuan) async {
    return _fetchSingleData(
        '${ApiKonstanta.cetak}/surat-permohonan/$idPengajuan');
  }

  /// Ambil data surat balasan
  Future<Map<String, dynamic>?> getSuratBalasan(int idPengajuan) async {
    return _fetchSingleData('${ApiKonstanta.cetak}/surat-balasan/$idPengajuan');
  }

  Future<Map<String, dynamic>?> _fetchSingleData(String endpoint) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        fromJson: (data) => data as Map<String, dynamic>,
      );
      if (response.success && response.data != null) {
        return response.data;
      } else {
        _error = response.message;
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ambil nilai pengajuan untuk Mahasiswa/Siswa
  Future<Map<String, dynamic>?> getNilaiPengajuan(int idPengajuan) async {
    return _fetchSingleData('${ApiKonstanta.nilai}/$idPengajuan');
  }
}
