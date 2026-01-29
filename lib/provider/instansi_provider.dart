import 'package:flutter/foundation.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

/// Model untuk data instansi (simple version for dropdown)
class InstansiItem {
  final int idInstansi;
  final String namaInstansi;
  final String alamat;
  final String? bidang;
  final String? kontak;
  final String? email;

  InstansiItem({
    required this.idInstansi,
    required this.namaInstansi,
    required this.alamat,
    this.bidang,
    this.kontak,
    this.email,
  });

  factory InstansiItem.fromJson(Map<String, dynamic> json) {
    return InstansiItem(
      idInstansi: _parseInt(json['id_instansi']),
      namaInstansi: json['nama_instansi'] ?? '',
      alamat: json['alamat'] ?? '',
      bidang: json['bidang'],
      kontak: json['kontak'],
      email: json['email'],
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// Provider untuk mengambil daftar instansi
class InstansiProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<InstansiItem> _daftarInstansi = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<InstansiItem> get daftarInstansi => _daftarInstansi;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ambil semua instansi
  Future<void> ambilDaftarInstansi() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get<List<dynamic>>(
        ApiKonstanta.instansi,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _daftarInstansi = response.data!
            .map((json) => InstansiItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get instansi by ID
  InstansiItem? getById(int id) {
    try {
      return _daftarInstansi.firstWhere((i) => i.idInstansi == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
