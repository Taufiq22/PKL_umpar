/// Jenis penilai
enum JenisPenilai {
  dosen('Dosen'),
  guru('Guru'),
  instansi('Instansi');

  final String label;

  const JenisPenilai(this.label);

  static JenisPenilai fromString(String jenis) {
    return JenisPenilai.values.firstWhere(
      (e) => e.label.toLowerCase() == jenis.toLowerCase(),
      orElse: () => JenisPenilai.dosen,
    );
  }
}

/// Model Nilai - Disesuaikan dengan database magang_umpar.sql
class Nilai {
  final int idNilai;
  final int idPengajuan;
  final JenisPenilai jenisPenilai;
  final String? aspekPenilaian;
  final double nilaiAngka;
  final String? komentar;
  final bool isFromInstansi;
  final DateTime? createdAt;

  // Untuk JOIN data
  final String? namaMahasiswa;
  final String? namaSiswa;
  final String? jenisPengajuan;
  final String? posisi;

  Nilai({
    required this.idNilai,
    required this.idPengajuan,
    required this.jenisPenilai,
    this.aspekPenilaian,
    this.nilaiAngka = 0,
    this.komentar,
    this.isFromInstansi = false,
    this.createdAt,
    this.namaMahasiswa,
    this.namaSiswa,
    this.jenisPengajuan,
    this.posisi,
  });

  factory Nilai.fromJson(Map<String, dynamic> json) {
    return Nilai(
      idNilai: json['id_nilai'] ?? 0,
      idPengajuan: json['id_pengajuan'] ?? 0,
      jenisPenilai: JenisPenilai.fromString(json['jenis_penilai'] ?? ''),
      aspekPenilaian: json['aspek_penilaian'],
      nilaiAngka: (json['nilai_angka'] ?? 0).toDouble(),
      komentar: json['komentar'],
      isFromInstansi: (json['is_from_instansi'] ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      namaMahasiswa: json['nama_mahasiswa'],
      namaSiswa: json['nama_siswa'],
      jenisPengajuan: json['jenis_pengajuan'],
      posisi: json['posisi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_nilai': idNilai,
      'id_pengajuan': idPengajuan,
      'jenis_penilai': jenisPenilai.label,
      'aspek_penilaian': aspekPenilaian,
      'nilai_angka': nilaiAngka,
      'komentar': komentar,
      'is_from_instansi': isFromInstansi ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Mendapatkan grade berdasarkan nilai
  String get grade {
    if (nilaiAngka >= 85) return 'A';
    if (nilaiAngka >= 75) return 'B';
    if (nilaiAngka >= 65) return 'C';
    if (nilaiAngka >= 55) return 'D';
    return 'E';
  }

  /// Alias untuk backward compatibility
  double get nilaiAkhir => nilaiAngka;

  /// Nama penilai (dari label jenis penilai)
  String get namaPenilai => jenisPenilai.label;

  /// Nama peserta (mahasiswa atau siswa)
  String get namaPeserta => namaMahasiswa ?? namaSiswa ?? 'Tidak diketahui';

  /// Cek apakah nilai dari instansi
  bool get isPenilaianInstansi => isFromInstansi;

  Nilai copyWith({
    int? idNilai,
    int? idPengajuan,
    JenisPenilai? jenisPenilai,
    String? aspekPenilaian,
    double? nilaiAngka,
    String? komentar,
    bool? isFromInstansi,
    DateTime? createdAt,
    String? namaMahasiswa,
    String? namaSiswa,
    String? jenisPengajuan,
    String? posisi,
  }) {
    return Nilai(
      idNilai: idNilai ?? this.idNilai,
      idPengajuan: idPengajuan ?? this.idPengajuan,
      jenisPenilai: jenisPenilai ?? this.jenisPenilai,
      aspekPenilaian: aspekPenilaian ?? this.aspekPenilaian,
      nilaiAngka: nilaiAngka ?? this.nilaiAngka,
      komentar: komentar ?? this.komentar,
      isFromInstansi: isFromInstansi ?? this.isFromInstansi,
      createdAt: createdAt ?? this.createdAt,
      namaMahasiswa: namaMahasiswa ?? this.namaMahasiswa,
      namaSiswa: namaSiswa ?? this.namaSiswa,
      jenisPengajuan: jenisPengajuan ?? this.jenisPengajuan,
      posisi: posisi ?? this.posisi,
    );
  }
}
