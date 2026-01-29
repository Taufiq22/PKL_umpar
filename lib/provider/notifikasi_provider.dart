import 'package:flutter/foundation.dart';
import '../data/model/notifikasi.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

/// Provider untuk manajemen notifikasi
class NotifikasiProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Notifikasi> _daftarNotifikasi = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Notifikasi> get daftarNotifikasi => _daftarNotifikasi;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Jumlah notifikasi belum dibaca
  int get jumlahBelumDibaca => _daftarNotifikasi.where((n) => !n.dibaca).length;

  /// Notifikasi belum dibaca
  List<Notifikasi> get belumDibaca =>
      _daftarNotifikasi.where((n) => !n.dibaca).toList();

  /// Ambil daftar notifikasi
  Future<void> ambilNotifikasi() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get<List<dynamic>>(
        ApiKonstanta.notifikasi,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _daftarNotifikasi =
            response.data!.map((json) => Notifikasi.fromJson(json)).toList();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Tandai notifikasi sudah dibaca
  Future<bool> tandaiDibaca(int id) async {
    try {
      final response = await _api.put(
        '${ApiKonstanta.notifikasi}/$id/baca',
      );

      if (response.success) {
        final index = _daftarNotifikasi.indexWhere((n) => n.idNotifikasi == id);
        if (index != -1) {
          _daftarNotifikasi[index] =
              _daftarNotifikasi[index].copyWith(dibaca: true);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Tandai semua notifikasi sudah dibaca
  Future<void> tandaiSemuaDibaca() async {
    for (final notif in belumDibaca) {
      await tandaiDibaca(notif.idNotifikasi);
    }
  }

  /// Hapus notifikasi
  Future<bool> hapusNotifikasi(int id) async {
    try {
      final response = await _api.delete(
        '${ApiKonstanta.notifikasi}/$id',
      );

      if (response.success) {
        _daftarNotifikasi.removeWhere((n) => n.idNotifikasi == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
