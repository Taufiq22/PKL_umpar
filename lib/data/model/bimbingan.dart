/// Bimbingan (Guidance Session) Model
/// UMPAR Magang & PKL System
///
/// Represents guidance session requests and scheduling

import 'package:flutter/material.dart';

/// Enum untuk status bimbingan
enum StatusBimbingan {
  diajukan('Diajukan', 'Menunggu', Colors.orange),
  dijadwalkan('Dijadwalkan', 'Terjadwal', Colors.blue),
  selesai('Selesai', 'Selesai', Colors.green),
  dibatalkan('Dibatalkan', 'Batal', Colors.red);

  final String value;
  final String label;
  final Color color;

  const StatusBimbingan(this.value, this.label, this.color);

  /// Parse from string value
  static StatusBimbingan fromString(String value) {
    return StatusBimbingan.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => StatusBimbingan.diajukan,
    );
  }

  /// Get icon for status
  IconData get icon {
    switch (this) {
      case StatusBimbingan.diajukan:
        return Icons.pending;
      case StatusBimbingan.dijadwalkan:
        return Icons.event;
      case StatusBimbingan.selesai:
        return Icons.check_circle;
      case StatusBimbingan.dibatalkan:
        return Icons.cancel;
    }
  }
}

/// Model untuk data bimbingan
class Bimbingan {
  final int? idBimbingan;
  final int idPengajuan;
  final String topikBimbingan;
  final String deskripsiMasalah;
  final DateTime tanggalPengajuan;
  final StatusBimbingan statusBimbingan;
  final DateTime? tanggalBimbingan;
  final String? lokasiBimbingan;
  final String? catatanMahasiswa;
  final String? feedbackPembimbing;
  final int? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined fields
  final String? jenisPengajuan;
  final String? namaPeserta;
  final String? nomorInduk;
  final String? namaPembimbing;
  final String? namaInstansi;

  Bimbingan({
    this.idBimbingan,
    required this.idPengajuan,
    required this.topikBimbingan,
    required this.deskripsiMasalah,
    required this.tanggalPengajuan,
    required this.statusBimbingan,
    this.tanggalBimbingan,
    this.lokasiBimbingan,
    this.catatanMahasiswa,
    this.feedbackPembimbing,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.jenisPengajuan,
    this.namaPeserta,
    this.nomorInduk,
    this.namaPembimbing,
    this.namaInstansi,
  });

  /// Factory constructor from JSON
  factory Bimbingan.fromJson(Map<String, dynamic> json) {
    return Bimbingan(
      idBimbingan: json['id_bimbingan'] != null
          ? int.tryParse(json['id_bimbingan'].toString())
          : null,
      idPengajuan: int.parse(json['id_pengajuan'].toString()),
      topikBimbingan: json['topik_bimbingan'] ?? '',
      deskripsiMasalah: json['deskripsi_masalah'] ?? '',
      tanggalPengajuan: DateTime.parse(json['tanggal_pengajuan']),
      statusBimbingan:
          StatusBimbingan.fromString(json['status_bimbingan'] ?? 'Diajukan'),
      tanggalBimbingan: json['tanggal_bimbingan'] != null
          ? DateTime.tryParse(json['tanggal_bimbingan'])
          : null,
      lokasiBimbingan: json['lokasi_bimbingan'],
      catatanMahasiswa: json['catatan_mahasiswa'],
      feedbackPembimbing: json['feedback_pembimbing'],
      rating: json['rating'] != null
          ? int.tryParse(json['rating'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      jenisPengajuan: json['jenis_pengajuan'],
      namaPeserta: json['nama_peserta'],
      nomorInduk: json['nomor_induk'],
      namaPembimbing: json['nama_pembimbing'],
      namaInstansi: json['nama_instansi'],
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      if (idBimbingan != null) 'id_bimbingan': idBimbingan,
      'id_pengajuan': idPengajuan,
      'topik_bimbingan': topikBimbingan,
      'deskripsi_masalah': deskripsiMasalah,
      if (catatanMahasiswa != null) 'catatan_mahasiswa': catatanMahasiswa,
    };
  }

  /// Get formatted tanggal pengajuan
  String get tanggalPengajuanFormatted {
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
    return '${tanggalPengajuan.day} ${months[tanggalPengajuan.month]} ${tanggalPengajuan.year}';
  }

  /// Get formatted tanggal bimbingan
  String get tanggalBimbinganFormatted {
    if (tanggalBimbingan == null) return '-';
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
    return '${tanggalBimbingan!.day} ${months[tanggalBimbingan!.month]} ${tanggalBimbingan!.year}';
  }

  /// Get formatted jam bimbingan
  String get jamBimbinganFormatted {
    if (tanggalBimbingan == null) return '-';
    return '${tanggalBimbingan!.hour.toString().padLeft(2, '0')}:${tanggalBimbingan!.minute.toString().padLeft(2, '0')}';
  }

  /// Check if can be cancelled
  bool get canBeCancelled {
    return statusBimbingan != StatusBimbingan.selesai &&
        statusBimbingan != StatusBimbingan.dibatalkan;
  }

  /// Check if can give rating
  bool get canGiveRating {
    return statusBimbingan == StatusBimbingan.selesai && rating == null;
  }

  /// Get rating stars widget
  List<Widget> getRatingStars() {
    if (rating == null) return [];
    return List.generate(5, (index) {
      return Icon(
        index < rating! ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 20,
      );
    });
  }

  /// CopyWith method
  Bimbingan copyWith({
    int? idBimbingan,
    int? idPengajuan,
    String? topikBimbingan,
    String? deskripsiMasalah,
    DateTime? tanggalPengajuan,
    StatusBimbingan? statusBimbingan,
    DateTime? tanggalBimbingan,
    String? lokasiBimbingan,
    String? catatanMahasiswa,
    String? feedbackPembimbing,
    int? rating,
  }) {
    return Bimbingan(
      idBimbingan: idBimbingan ?? this.idBimbingan,
      idPengajuan: idPengajuan ?? this.idPengajuan,
      topikBimbingan: topikBimbingan ?? this.topikBimbingan,
      deskripsiMasalah: deskripsiMasalah ?? this.deskripsiMasalah,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      statusBimbingan: statusBimbingan ?? this.statusBimbingan,
      tanggalBimbingan: tanggalBimbingan ?? this.tanggalBimbingan,
      lokasiBimbingan: lokasiBimbingan ?? this.lokasiBimbingan,
      catatanMahasiswa: catatanMahasiswa ?? this.catatanMahasiswa,
      feedbackPembimbing: feedbackPembimbing ?? this.feedbackPembimbing,
      rating: rating ?? this.rating,
      createdAt: createdAt,
      updatedAt: updatedAt,
      jenisPengajuan: jenisPengajuan,
      namaPeserta: namaPeserta,
      nomorInduk: nomorInduk,
      namaPembimbing: namaPembimbing,
      namaInstansi: namaInstansi,
    );
  }
}
