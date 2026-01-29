/// Tipe notifikasi
enum TipeNotifikasi {
  info('info'),
  sukses('sukses'),
  peringatan('peringatan'),
  error('error');

  final String kode;

  const TipeNotifikasi(this.kode);

  static TipeNotifikasi fromString(String tipe) {
    return TipeNotifikasi.values.firstWhere(
      (e) => e.kode == tipe,
      orElse: () => TipeNotifikasi.info,
    );
  }
}

/// Model Notifikasi
class Notifikasi {
  final int idNotifikasi;
  final int idUser;
  final String judul;
  final String pesan;
  final TipeNotifikasi tipe;
  final bool dibaca;
  final DateTime? createdAt;

  Notifikasi({
    required this.idNotifikasi,
    required this.idUser,
    required this.judul,
    required this.pesan,
    this.tipe = TipeNotifikasi.info,
    this.dibaca = false,
    this.createdAt,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      idNotifikasi: json['id_notifikasi'] ?? 0,
      idUser: json['id_user'] ?? 0,
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: TipeNotifikasi.fromString(json['tipe'] ?? ''),
      dibaca: json['dibaca'] == 1 || json['dibaca'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_notifikasi': idNotifikasi,
      'id_user': idUser,
      'judul': judul,
      'pesan': pesan,
      'tipe': tipe.kode,
      'dibaca': dibaca ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Notifikasi copyWith({
    int? idNotifikasi,
    int? idUser,
    String? judul,
    String? pesan,
    TipeNotifikasi? tipe,
    bool? dibaca,
    DateTime? createdAt,
  }) {
    return Notifikasi(
      idNotifikasi: idNotifikasi ?? this.idNotifikasi,
      idUser: idUser ?? this.idUser,
      judul: judul ?? this.judul,
      pesan: pesan ?? this.pesan,
      tipe: tipe ?? this.tipe,
      dibaca: dibaca ?? this.dibaca,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
