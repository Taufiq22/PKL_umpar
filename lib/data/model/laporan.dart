import 'package:umpar_magang_dan_pkl/konfigurasi/konstanta.dart';

/// Status laporan
enum StatusLaporan {
  pending('Pending'),
  disetujui('Disetujui'),
  ditolak('Ditolak'),
  sesuai('Sesuai'),
  perluPerbaikan('Perlu Perbaikan'),
  selesai('Selesai'),
  revisi('Revisi');

  final String label;

  const StatusLaporan(this.label);

  static StatusLaporan fromString(String status) {
    return StatusLaporan.values.firstWhere(
      (e) => e.label == status,
      orElse: () => StatusLaporan.pending,
    );
  }
}

/// Model Laporan (Harian, Monitoring, Bimbingan)
class Laporan {
  final int idLaporan;
  final int idPengajuan;
  final JenisLaporan jenisLaporan;
  final String? fileLaporan;
  final DateTime tanggal;
  final String kegiatan;
  final StatusLaporan status;
  final String? komentarPembimbing;
  final DateTime? createdAt;

  Laporan({
    required this.idLaporan,
    required this.idPengajuan,
    this.jenisLaporan = JenisLaporan.harian,
    this.fileLaporan,
    required this.tanggal,
    required this.kegiatan,
    this.status = StatusLaporan.pending,
    this.komentarPembimbing,
    this.createdAt,
  });

  factory Laporan.fromJson(Map<String, dynamic> json) {
    return Laporan(
      idLaporan: json['id_laporan'] ?? 0,
      idPengajuan: json['id_pengajuan'] ?? 0,
      jenisLaporan: JenisLaporan.fromString(json['jenis_laporan'] ?? ''),
      fileLaporan: json['file_laporan'],
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'])
          : DateTime.now(),
      kegiatan: json['kegiatan'] ?? '',
      status: StatusLaporan.fromString(json['status'] ?? ''),
      komentarPembimbing: json['komentar_pembimbing'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_laporan': idLaporan,
      'id_pengajuan': idPengajuan,
      'jenis_laporan': jenisLaporan.label,
      'file_laporan': fileLaporan,
      'tanggal': tanggal.toIso8601String().split('T').first,
      'kegiatan': kegiatan,
      'status': status.label,
      'komentar_pembimbing': komentarPembimbing,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Cek status laporan
  bool get isPending => status == StatusLaporan.pending;
  bool get isDisetujui => status == StatusLaporan.disetujui;
  bool get isSesuai => status == StatusLaporan.sesuai;
  bool get perluRevisi =>
      status == StatusLaporan.perluPerbaikan || status == StatusLaporan.revisi;
  bool get isApproved =>
      status == StatusLaporan.disetujui ||
      status == StatusLaporan.sesuai ||
      status == StatusLaporan.selesai;

  Laporan copyWith({
    int? idLaporan,
    int? idPengajuan,
    JenisLaporan? jenisLaporan,
    String? fileLaporan,
    DateTime? tanggal,
    String? kegiatan,
    StatusLaporan? status,
    String? komentarPembimbing,
    DateTime? createdAt,
  }) {
    return Laporan(
      idLaporan: idLaporan ?? this.idLaporan,
      idPengajuan: idPengajuan ?? this.idPengajuan,
      jenisLaporan: jenisLaporan ?? this.jenisLaporan,
      fileLaporan: fileLaporan ?? this.fileLaporan,
      tanggal: tanggal ?? this.tanggal,
      kegiatan: kegiatan ?? this.kegiatan,
      status: status ?? this.status,
      komentarPembimbing: komentarPembimbing ?? this.komentarPembimbing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
