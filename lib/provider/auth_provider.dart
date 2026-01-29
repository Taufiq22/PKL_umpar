import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/model/pengguna.dart';
import '../data/sumber/api/api_client.dart';
import '../konfigurasi/konstanta.dart';

/// Provider untuk manajemen autentikasi
class AuthProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  Pengguna? _pengguna;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  Pengguna? get pengguna => _pengguna;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _pengguna != null && _token != null;
  RolePengguna? get role => _pengguna?.role;

  /// Login user
  Future<bool> login(String username, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post<Map<String, dynamic>>(
        ApiKonstanta.login,
        body: {
          'username': username,
          'password': password,
          'role': role,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        _token = response.data!['token'];
        _pengguna = Pengguna.fromJson(response.data!['user']);
        _api.setToken(_token);

        // Simpan ke local storage
        await _saveToPrefs();

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

  /// Register user baru
  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiKonstanta.register,
        body: data,
      );

      _isLoading = false;

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _error = response.message;
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

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.post(ApiKonstanta.logout);
    } catch (e) {
      // Ignore error, tetap logout
    }

    _pengguna = null;
    _token = null;
    _api.setToken(null);

    // Hapus dari local storage
    await _clearPrefs();

    _isLoading = false;
    notifyListeners();
  }

  /// Cek dan restore session dari local storage
  Future<bool> checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final savedUser = prefs.getString('user');

      if (savedToken != null && savedUser != null) {
        _token = savedToken;
        _api.setToken(_token);

        // Verifikasi token dengan server
        final response = await _api.get<Map<String, dynamic>>(
          ApiKonstanta.profil,
          fromJson: (data) => data as Map<String, dynamic>,
        );

        if (response.success && response.data != null) {
          _pengguna = Pengguna.fromJson(response.data!);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Session tidak valid
    }

    _pengguna = null;
    _token = null;
    _api.setToken(null);
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Update profil
  Future<bool> updateProfil(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put<Map<String, dynamic>>(
        ApiKonstanta.profil,
        body: data,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        _pengguna = Pengguna.fromJson(response.data!);
        await _saveToPrefs();
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

  /// Ubah password
  Future<bool> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put<Map<String, dynamic>>(
        '${ApiKonstanta.profil}/password',
        body: {
          'password_lama': passwordLama,
          'password_baru': passwordBaru,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _error = response.message;
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

  /// Simpan session ke SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('token', _token!);
    }
    if (_pengguna != null) {
      await prefs.setString('user', _pengguna!.toJson().toString());
    }
  }

  /// Hapus session dari SharedPreferences
  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
