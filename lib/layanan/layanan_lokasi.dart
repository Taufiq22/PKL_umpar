import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Layanan Lokasi untuk GPS Attendance
/// Menangani permission, ambil lokasi, dan validasi jarak
class LayananLokasi {
  /// Singleton instance
  static final LayananLokasi _instance = LayananLokasi._internal();
  factory LayananLokasi() => _instance;
  LayananLokasi._internal();

  /// Cek apakah layanan lokasi aktif
  Future<bool> cekLayananAktif() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request permission lokasi
  Future<bool> mintaIzinLokasi() async {
    // Cek status permission saat ini
    var status = await Permission.location.status;

    if (status.isDenied) {
      // Minta permission
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      // Buka settings jika permanently denied
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  /// Ambil lokasi saat ini
  Future<Position?> ambilLokasiSekarang({
    int timeoutDetik = 15,
    double akurasiMinimal = 100, // dalam meter
  }) async {
    try {
      // Cek layanan lokasi
      if (!await cekLayananAktif()) {
        debugPrint('Layanan lokasi tidak aktif');
        return null;
      }

      // Cek permission
      if (!await mintaIzinLokasi()) {
        debugPrint('Permission lokasi ditolak');
        return null;
      }

      // Ambil posisi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: timeoutDetik),
      );

      debugPrint('Lokasi: ${position.latitude}, ${position.longitude}');
      debugPrint('Akurasi: ${position.accuracy} meter');

      return position;
    } catch (e) {
      debugPrint('Error ambil lokasi: $e');
      return null;
    }
  }

  /// Hitung jarak antara 2 titik (Haversine formula)
  /// Return dalam meter
  double hitungJarak({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const double radiusBumi = 6371000; // meter

    final dLat = _derajatKeRadian(lat2 - lat1);
    final dLng = _derajatKeRadian(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_derajatKeRadian(lat1)) *
            cos(_derajatKeRadian(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radiusBumi * c;
  }

  double _derajatKeRadian(double derajat) {
    return derajat * pi / 180;
  }

  /// Cek apakah dalam radius yang diizinkan
  Future<HasilValidasiLokasi> validasiLokasi({
    required double targetLat,
    required double targetLng,
    double radiusMeter = 100,
  }) async {
    final posisi = await ambilLokasiSekarang();

    if (posisi == null) {
      return HasilValidasiLokasi(
        valid: false,
        pesan: 'Tidak dapat mengambil lokasi. Pastikan GPS aktif.',
      );
    }

    final jarak = hitungJarak(
      lat1: posisi.latitude,
      lng1: posisi.longitude,
      lat2: targetLat,
      lng2: targetLng,
    );

    final valid = jarak <= radiusMeter;

    return HasilValidasiLokasi(
      valid: valid,
      pesan: valid
          ? 'Lokasi valid'
          : 'Anda berada ${jarak.toStringAsFixed(0)}m dari lokasi instansi (maksimal ${radiusMeter.toStringAsFixed(0)}m)',
      latitude: posisi.latitude,
      longitude: posisi.longitude,
      akurasi: posisi.accuracy,
      jarakDariTarget: jarak,
    );
  }

  /// Stream lokasi untuk tracking real-time
  Stream<Position> streamLokasi() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update setiap 10 meter
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}

/// Model hasil validasi lokasi
class HasilValidasiLokasi {
  final bool valid;
  final String pesan;
  final double? latitude;
  final double? longitude;
  final double? akurasi;
  final double? jarakDariTarget;

  HasilValidasiLokasi({
    required this.valid,
    required this.pesan,
    this.latitude,
    this.longitude,
    this.akurasi,
    this.jarakDariTarget,
  });

  Map<String, dynamic> toJson() => {
        'valid': valid,
        'pesan': pesan,
        'latitude': latitude,
        'longitude': longitude,
        'akurasi': akurasi,
        'jarak_dari_target': jarakDariTarget,
      };
}
