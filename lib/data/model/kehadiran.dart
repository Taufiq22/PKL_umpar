/// Kehadiran (Attendance) Model
/// UMPAR Magang & PKL System
///
/// Represents daily attendance records for mahasiswa and siswa

import 'package:flutter/material.dart';

/// Enum untuk status kehadiran
enum StatusKehadiran {
  hadir('Hadir', 'Hadir', Colors.green),
  izin('Izin', 'Izin', Colors.orange),
  sakit('Sakit', 'Sakit', Colors.blue),
  alpha('Alpha', 'Alpha', Colors.red);

  final String value;
  final String label;
  final Color color;

  const StatusKehadiran(this.value, this.label, this.color);

  /// Parse from string value
  static StatusKehadiran fromString(String value) {
    return StatusKehadiran.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => StatusKehadiran.alpha,
    );
  }

  /// Get icon for status
  IconData get icon {
    switch (this) {
      case StatusKehadiran.hadir:
        return Icons.check_circle;
      case StatusKehadiran.izin:
        return Icons.event_busy;
      case StatusKehadiran.sakit:
        return Icons.local_hospital;
      case StatusKehadiran.alpha:
        return Icons.cancel;
    }
  }
}

/// Model untuk data kehadiran
class Kehadiran {
  final int? idKehadiran;
  final int idPengajuan;
  final DateTime tanggal;
  final StatusKehadiran statusKehadiran;
  final TimeOfDay? jamMasuk;
  final TimeOfDay? jamKeluar;
  final String? keterangan;
  final String? lokasiCheckin;
  final String? fotoBukti;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Kehadiran({
    this.idKehadiran,
    required this.idPengajuan,
    required this.tanggal,
    required this.statusKehadiran,
    this.jamMasuk,
    this.jamKeluar,
    this.keterangan,
    this.lokasiCheckin,
    this.fotoBukti,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor from JSON
  factory Kehadiran.fromJson(Map<String, dynamic> json) {
    return Kehadiran(
      idKehadiran: json['id_kehadiran'] != null
          ? int.tryParse(json['id_kehadiran'].toString())
          : null,
      idPengajuan: int.parse(json['id_pengajuan'].toString()),
      tanggal: DateTime.parse(json['tanggal']),
      statusKehadiran:
          StatusKehadiran.fromString(json['status_kehadiran'] ?? 'Alpha'),
      jamMasuk: _parseTimeOfDay(json['jam_masuk']),
      jamKeluar: _parseTimeOfDay(json['jam_keluar']),
      keterangan: json['keterangan'],
      lokasiCheckin: json['lokasi_checkin'],
      fotoBukti: json['foto_bukti'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      if (idKehadiran != null) 'id_kehadiran': idKehadiran,
      'id_pengajuan': idPengajuan,
      'tanggal': tanggal.toIso8601String().split('T').first,
      'status_kehadiran': statusKehadiran.value,
      if (jamMasuk != null) 'jam_masuk': _formatTimeOfDay(jamMasuk!),
      if (jamKeluar != null) 'jam_keluar': _formatTimeOfDay(jamKeluar!),
      if (keterangan != null) 'keterangan': keterangan,
      if (lokasiCheckin != null) 'lokasi_checkin': lokasiCheckin,
    };
  }

  /// Parse time string to TimeOfDay
  static TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  /// Format TimeOfDay to string
  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  /// Get formatted date string
  String get tanggalFormatted {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${tanggal.day} ${months[tanggal.month]} ${tanggal.year}';
  }

  /// Get formatted jam masuk
  String get jamMasukFormatted {
    if (jamMasuk == null) return '-';
    return '${jamMasuk!.hour.toString().padLeft(2, '0')}:${jamMasuk!.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted jam keluar
  String get jamKeluarFormatted {
    if (jamKeluar == null) return '-';
    return '${jamKeluar!.hour.toString().padLeft(2, '0')}:${jamKeluar!.minute.toString().padLeft(2, '0')}';
  }

  /// Calculate work duration
  Duration? get durasi {
    if (jamMasuk == null || jamKeluar == null) return null;
    final masuk = Duration(hours: jamMasuk!.hour, minutes: jamMasuk!.minute);
    final keluar = Duration(hours: jamKeluar!.hour, minutes: jamKeluar!.minute);
    return keluar - masuk;
  }

  /// Get formatted duration
  String get durasiFormatted {
    final d = durasi;
    if (d == null) return '-';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return '${hours}j ${minutes}m';
  }

  /// Check if today
  bool get isToday {
    final now = DateTime.now();
    return tanggal.year == now.year &&
        tanggal.month == now.month &&
        tanggal.day == now.day;
  }

  /// CopyWith method
  Kehadiran copyWith({
    int? idKehadiran,
    int? idPengajuan,
    DateTime? tanggal,
    StatusKehadiran? statusKehadiran,
    TimeOfDay? jamMasuk,
    TimeOfDay? jamKeluar,
    String? keterangan,
    String? lokasiCheckin,
    String? fotoBukti,
  }) {
    return Kehadiran(
      idKehadiran: idKehadiran ?? this.idKehadiran,
      idPengajuan: idPengajuan ?? this.idPengajuan,
      tanggal: tanggal ?? this.tanggal,
      statusKehadiran: statusKehadiran ?? this.statusKehadiran,
      jamMasuk: jamMasuk ?? this.jamMasuk,
      jamKeluar: jamKeluar ?? this.jamKeluar,
      keterangan: keterangan ?? this.keterangan,
      lokasiCheckin: lokasiCheckin ?? this.lokasiCheckin,
      fotoBukti: fotoBukti ?? this.fotoBukti,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Model untuk statistik kehadiran
class StatistikKehadiran {
  final int total;
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;
  final double persentaseHadir;

  StatistikKehadiran({
    required this.total,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
    required this.persentaseHadir,
  });

  factory StatistikKehadiran.fromJson(Map<String, dynamic> json) {
    return StatistikKehadiran(
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      hadir: int.tryParse(json['hadir']?.toString() ?? '0') ?? 0,
      izin: int.tryParse(json['izin']?.toString() ?? '0') ?? 0,
      sakit: int.tryParse(json['sakit']?.toString() ?? '0') ?? 0,
      alpha: int.tryParse(json['alpha']?.toString() ?? '0') ?? 0,
      persentaseHadir:
          double.tryParse(json['persentase_hadir']?.toString() ?? '0') ?? 0.0,
    );
  }

  /// Calculate from list of kehadiran
  factory StatistikKehadiran.fromList(List<Kehadiran> list) {
    final total = list.length;
    final hadir =
        list.where((k) => k.statusKehadiran == StatusKehadiran.hadir).length;
    final izin =
        list.where((k) => k.statusKehadiran == StatusKehadiran.izin).length;
    final sakit =
        list.where((k) => k.statusKehadiran == StatusKehadiran.sakit).length;
    final alpha =
        list.where((k) => k.statusKehadiran == StatusKehadiran.alpha).length;

    return StatistikKehadiran(
      total: total,
      hadir: hadir,
      izin: izin,
      sakit: sakit,
      alpha: alpha,
      persentaseHadir: total > 0 ? (hadir / total * 100) : 0.0,
    );
  }

  /// Empty statistics
  factory StatistikKehadiran.empty() {
    return StatistikKehadiran(
      total: 0,
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
      persentaseHadir: 0.0,
    );
  }
}
