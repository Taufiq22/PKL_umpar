import 'package:umpar_magang_dan_pkl/konfigurasi/konstanta.dart';

/// Model Pengajuan Magang/PKL
class Pengajuan {
  final int idPengajuan;
  final int? idMahasiswa;
  final int? idSiswa;
  final String? namaMahasiswa;
  final String? namaSiswa;
  final JenisPengajuan jenisPengajuan;
  final int? idInstansi;
  final String? namaInstansi;
  final String? posisi;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final int durasiBulan;
  final String? keterangan;
  final StatusPengajuan statusPengajuan;
  final int? idDosenPembimbing;
  final int? idGuruPembimbing;
  final String? namaDosenPembimbing;
  final String? namaGuruPembimbing;
  final String? suratBalasan;
  final DateTime? createdAt;

  Pengajuan({
    required this.idPengajuan,
    this.idMahasiswa,
    this.idSiswa,
    this.namaMahasiswa,
    this.namaSiswa,
    required this.jenisPengajuan,
    this.idInstansi,
    this.namaInstansi,
    this.posisi,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.durasiBulan = 1,
    this.keterangan,
    this.statusPengajuan = StatusPengajuan.diajukan,
    this.idDosenPembimbing,
    this.idGuruPembimbing,
    this.namaDosenPembimbing,
    this.namaGuruPembimbing,
    this.suratBalasan,
    this.createdAt,
  });

  factory Pengajuan.fromJson(Map<String, dynamic> json) {
    return Pengajuan(
      idPengajuan: json['id_pengajuan'] ?? 0,
      idMahasiswa: json['id_mahasiswa'],
      idSiswa: json['id_siswa'],
      namaMahasiswa: json['nama_mahasiswa'],
      namaSiswa: json['nama_siswa'],
      jenisPengajuan: JenisPengajuan.fromString(json['jenis_pengajuan'] ?? ''),
      idInstansi: json['id_instansi'],
      namaInstansi: json['nama_instansi'],
      posisi: json['posisi'],
      tanggalMulai: json['tanggal_mulai'] != null
          ? DateTime.tryParse(json['tanggal_mulai'])
          : null,
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.tryParse(json['tanggal_selesai'])
          : null,
      durasiBulan: json['durasi_bulan'] ?? 1,
      keterangan: json['keterangan'],
      statusPengajuan:
          StatusPengajuan.fromString(json['status_pengajuan'] ?? ''),
      idDosenPembimbing: json['id_dosen_pembimbing'],
      idGuruPembimbing: json['id_guru_pembimbing'],
      namaDosenPembimbing: json['nama_dosen_pembimbing'],
      namaGuruPembimbing: json['nama_guru_pembimbing'],
      suratBalasan: json['surat_balasan'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengajuan': idPengajuan,
      'id_mahasiswa': idMahasiswa,
      'id_siswa': idSiswa,
      'jenis_pengajuan': jenisPengajuan.label,
      'id_instansi': idInstansi,
      'posisi': posisi,
      'tanggal_mulai': tanggalMulai?.toIso8601String().split('T').first,
      'tanggal_selesai': tanggalSelesai?.toIso8601String().split('T').first,
      'durasi_bulan': durasiBulan,
      'keterangan': keterangan,
      'status_pengajuan': statusPengajuan.label,
      'id_dosen_pembimbing': idDosenPembimbing,
      'id_guru_pembimbing': idGuruPembimbing,
      'surat_balasan': suratBalasan,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Cek apakah pengajuan adalah magang (mahasiswa)
  bool get isMagang => jenisPengajuan == JenisPengajuan.magang;

  /// Cek apakah pengajuan adalah PKL (siswa)
  bool get isPKL => jenisPengajuan == JenisPengajuan.pkl;

  /// Cek apakah pengajuan sudah disetujui
  bool get isDisetujui => statusPengajuan == StatusPengajuan.disetujui;

  /// Cek apakah pengajuan masih menunggu
  bool get isDiajukan => statusPengajuan == StatusPengajuan.diajukan;

  /// Cek apakah pengajuan ditolak
  bool get isDitolak => statusPengajuan == StatusPengajuan.ditolak;

  /// Cek apakah pengajuan selesai
  bool get isSelesai => statusPengajuan == StatusPengajuan.selesai;

  Pengajuan copyWith({
    int? idPengajuan,
    int? idMahasiswa,
    int? idSiswa,
    JenisPengajuan? jenisPengajuan,
    int? idInstansi,
    String? namaInstansi,
    String? posisi,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    int? durasiBulan,
    String? keterangan,
    StatusPengajuan? statusPengajuan,
    int? idDosenPembimbing,
    int? idGuruPembimbing,
    String? namaDosenPembimbing,
    String? namaGuruPembimbing,
    String? suratBalasan,
    DateTime? createdAt,
  }) {
    return Pengajuan(
      idPengajuan: idPengajuan ?? this.idPengajuan,
      idMahasiswa: idMahasiswa ?? this.idMahasiswa,
      idSiswa: idSiswa ?? this.idSiswa,
      jenisPengajuan: jenisPengajuan ?? this.jenisPengajuan,
      idInstansi: idInstansi ?? this.idInstansi,
      namaInstansi: namaInstansi ?? this.namaInstansi,
      posisi: posisi ?? this.posisi,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      durasiBulan: durasiBulan ?? this.durasiBulan,
      keterangan: keterangan ?? this.keterangan,
      statusPengajuan: statusPengajuan ?? this.statusPengajuan,
      idDosenPembimbing: idDosenPembimbing ?? this.idDosenPembimbing,
      idGuruPembimbing: idGuruPembimbing ?? this.idGuruPembimbing,
      namaDosenPembimbing: namaDosenPembimbing ?? this.namaDosenPembimbing,
      namaGuruPembimbing: namaGuruPembimbing ?? this.namaGuruPembimbing,
      suratBalasan: suratBalasan ?? this.suratBalasan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
