import 'package:umpar_magang_dan_pkl/konfigurasi/konstanta.dart';

/// Model dasar untuk semua pengguna
class Pengguna {
  final int idUser;
  final String username;
  final String namaLengkap;
  final String? email; // Added email
  final RolePengguna role;
  final String? fotoProfil;
  final bool isActive;
  final DateTime? createdAt;

  Pengguna({
    required this.idUser,
    required this.username,
    required this.namaLengkap,
    this.email,
    required this.role,
    this.fotoProfil,
    this.isActive = true,
    this.createdAt,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      idUser: _parseInt(json['id_user']),
      username: json['username'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'],
      role: RolePengguna.fromString(json['role'] ?? ''),
      fotoProfil: json['foto_profil'],
      isActive: _parseBool(json['is_active']) ??
          _parseBool(json['status_aktif']) ??
          true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'nama_lengkap': namaLengkap,
      'email': email,
      'role': role.kode,
      'foto_profil': fotoProfil,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helpers for parsing
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value == 'true';
    return null;
  }
}

/// Model Mahasiswa
class Mahasiswa extends Pengguna {
  final int idMahasiswa;
  final String nim;
  final String prodi;
  final String fakultas;
  final int semester;
  final double ipk;

  Mahasiswa({
    required super.idUser,
    required super.username,
    required super.namaLengkap,
    super.email,
    super.fotoProfil,
    super.isActive,
    super.createdAt,
    required this.idMahasiswa,
    required this.nim,
    required this.prodi,
    required this.fakultas,
    required this.semester,
    this.ipk = 0.0,
  }) : super(role: RolePengguna.mahasiswa);

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      idUser: Pengguna._parseInt(json['id_user']),
      username: json['username'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'],
      fotoProfil: json['foto_profil'],
      isActive: Pengguna._parseBool(json['is_active']) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      idMahasiswa: Pengguna._parseInt(json['id_mahasiswa']),
      nim: json['nim'] ?? '',
      prodi: json['prodi'] ?? '',
      fakultas: json['fakultas'] ?? '',
      semester: Pengguna._parseInt(json['semester']),
      ipk: (json['ipk'] ?? 0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'id_mahasiswa': idMahasiswa,
      'nim': nim,
      'prodi': prodi,
      'fakultas': fakultas,
      'semester': semester,
      'ipk': ipk,
    });
    return map;
  }
}

/// Model Siswa
class Siswa extends Pengguna {
  final int idSiswa;
  final String nisn;
  final String jurusan;
  final String sekolah;
  final String kelas;

  Siswa({
    required super.idUser,
    required super.username,
    required super.namaLengkap,
    super.email,
    super.fotoProfil,
    super.isActive,
    super.createdAt,
    required this.idSiswa,
    required this.nisn,
    required this.jurusan,
    required this.sekolah,
    required this.kelas,
  }) : super(role: RolePengguna.siswa);

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      idUser: Pengguna._parseInt(json['id_user']),
      username: json['username'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'],
      fotoProfil: json['foto_profil'],
      isActive: Pengguna._parseBool(json['is_active']) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      idSiswa: Pengguna._parseInt(json['id_siswa']),
      nisn: json['nisn'] ?? '',
      jurusan: json['jurusan'] ?? '',
      sekolah: json['sekolah'] ?? '',
      kelas: json['kelas'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'id_siswa': idSiswa,
      'nisn': nisn,
      'jurusan': jurusan,
      'sekolah': sekolah,
      'kelas': kelas,
    });
    return map;
  }
}

/// Model Dosen Pembimbing
class DosenPembimbing extends Pengguna {
  final int idDosen;
  final String nidn;
  final String? jabatan;

  DosenPembimbing({
    required super.idUser,
    required super.username,
    required super.namaLengkap,
    super.email,
    super.fotoProfil,
    super.isActive,
    super.createdAt,
    required this.idDosen,
    required this.nidn,
    this.jabatan,
  }) : super(role: RolePengguna.dosen);

  factory DosenPembimbing.fromJson(Map<String, dynamic> json) {
    return DosenPembimbing(
      idUser: Pengguna._parseInt(json['id_user']),
      username: json['username'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'],
      fotoProfil: json['foto_profil'],
      isActive: Pengguna._parseBool(json['is_active']) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      idDosen: Pengguna._parseInt(json['id_dosen']),
      nidn: json['nidn'] ?? '',
      jabatan: json['jabatan'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'id_dosen': idDosen,
      'nidn': nidn,
      'jabatan': jabatan,
    });
    return map;
  }
}

/// Model Guru Pembimbing
class GuruPembimbing extends Pengguna {
  final int idGuru;
  final String nip;
  final String? mataPelajaran;

  GuruPembimbing({
    required super.idUser,
    required super.username,
    required super.namaLengkap,
    super.email,
    super.fotoProfil,
    super.isActive,
    super.createdAt,
    required this.idGuru,
    required this.nip,
    this.mataPelajaran,
  }) : super(role: RolePengguna.guru);

  factory GuruPembimbing.fromJson(Map<String, dynamic> json) {
    return GuruPembimbing(
      idUser: Pengguna._parseInt(json['id_user']),
      username: json['username'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'],
      fotoProfil: json['foto_profil'],
      isActive: Pengguna._parseBool(json['is_active']) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      idGuru: Pengguna._parseInt(json['id_guru']),
      nip: json['nip'] ?? '',
      mataPelajaran: json['mata_pelajaran'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'id_guru': idGuru,
      'nip': nip,
      'mata_pelajaran': mataPelajaran,
    });
    return map;
  }
}

/// Model Instansi
class Instansi extends Pengguna {
  final int idInstansi;
  final String namaInstansi;
  final String alamat;
  final String? bidang;
  final String? kontak;

  Instansi({
    required super.idUser,
    required super.username,
    required super.namaLengkap,
    super.email,
    super.fotoProfil,
    super.isActive,
    super.createdAt,
    required this.idInstansi,
    required this.namaInstansi,
    required this.alamat,
    this.bidang,
    this.kontak,
  }) : super(role: RolePengguna.instansi);

  factory Instansi.fromJson(Map<String, dynamic> json) {
    return Instansi(
      idUser: Pengguna._parseInt(json['id_user']),
      username: json['username'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'],
      fotoProfil: json['foto_profil'],
      isActive: Pengguna._parseBool(json['is_active']) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      idInstansi: Pengguna._parseInt(json['id_instansi']),
      namaInstansi: json['nama_instansi'] ?? '',
      alamat: json['alamat'] ?? '',
      bidang: json['bidang'],
      kontak: json['kontak'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'id_instansi': idInstansi,
      'nama_instansi': namaInstansi,
      'alamat': alamat,
      'bidang': bidang,
      'kontak': kontak,
    });
    return map;
  }
}
