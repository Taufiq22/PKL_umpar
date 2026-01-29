import 'package:flutter/foundation.dart';
import '../data/model/pengguna.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

/// Provider untuk manajemen user (Admin)
class UsersProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Pengguna> _daftarUsers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Pengguna> get daftarUsers => _daftarUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ambil semua user
  Future<void> ambilSemuaUser({String? role, int? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (status != null) queryParams['status'] = status.toString();

      final response = await _api.get<List<dynamic>>(
        ApiKonstanta.adminUsers,
        queryParams: queryParams,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _daftarUsers =
            response.data!.map((json) => Pengguna.fromJson(json)).toList();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create user baru (Admin)
  Future<bool> tambahUser(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiKonstanta.adminUsers,
        body: data,
      );

      if (response.success) {
        // Refresh list
        await ambilSemuaUser();
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

  /// Update user
  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put(
        '${ApiKonstanta.adminUsers}/$id',
        body: data,
      );

      if (response.success) {
        await ambilSemuaUser();
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

  /// Delete user
  Future<bool> hapusUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.delete(
        '${ApiKonstanta.adminUsers}/$id',
      );

      if (response.success) {
        _daftarUsers.removeWhere((user) => user.idUser == id);
        _isLoading = false;
        notifyListeners();
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

  /// Get status label
  String getStatusLabel(int status) {
    return status == 1 ? 'Aktif' : 'Nonaktif';
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
