/// Admin Fakultas Model
/// UMPAR Magang & PKL System
///
/// Represents faculty-level admin profile and data

/// Model for Admin Fakultas profile
class AdminFakultas {
  final int? idAdminFakultas;
  final int idUser;
  final String nama;
  final String? nip;
  final String fakultas;
  final String? programStudi;
  final String? jabatan;
  final String? email;
  final String? telepon;
  final String? foto;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminFakultas({
    this.idAdminFakultas,
    required this.idUser,
    required this.nama,
    this.nip,
    required this.fakultas,
    this.programStudi,
    this.jabatan,
    this.email,
    this.telepon,
    this.foto,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminFakultas.fromJson(Map<String, dynamic> json) {
    return AdminFakultas(
      idAdminFakultas: json['id_admin_fakultas'] != null
          ? int.tryParse(json['id_admin_fakultas'].toString())
          : null,
      idUser: int.parse(json['id_user'].toString()),
      nama: json['nama'] ?? '',
      nip: json['nip'],
      fakultas: json['fakultas'] ?? '',
      programStudi: json['program_studi'],
      jabatan: json['jabatan'],
      email: json['email'],
      telepon: json['telepon'],
      foto: json['foto'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idAdminFakultas != null) 'id_admin_fakultas': idAdminFakultas,
      'id_user': idUser,
      'nama': nama,
      if (nip != null) 'nip': nip,
      'fakultas': fakultas,
      if (programStudi != null) 'program_studi': programStudi,
      if (jabatan != null) 'jabatan': jabatan,
      if (email != null) 'email': email,
      if (telepon != null) 'telepon': telepon,
    };
  }

  /// Get initials for avatar
  String get initials {
    final parts = nama.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }
}

/// Model for faculty statistics
class StatistikFakultas {
  final int totalPengajuan;
  final Map<String, int> byStatus;
  final Map<String, int> byProdi;
  final String? fakultas;

  StatistikFakultas({
    required this.totalPengajuan,
    required this.byStatus,
    required this.byProdi,
    this.fakultas,
  });

  factory StatistikFakultas.fromJson(Map<String, dynamic> json) {
    // Parse by_status
    final statusList = json['by_status'] as List? ?? [];
    final byStatus = <String, int>{};
    for (final item in statusList) {
      byStatus[item['status_pengajuan'] ?? ''] =
          int.tryParse(item['jumlah'].toString()) ?? 0;
    }

    // Parse by_prodi
    final prodiList = json['by_prodi'] as List? ?? [];
    final byProdi = <String, int>{};
    for (final item in prodiList) {
      byProdi[item['prodi'] ?? ''] =
          int.tryParse(item['jumlah'].toString()) ?? 0;
    }

    return StatistikFakultas(
      totalPengajuan: int.tryParse(json['total_pengajuan'].toString()) ?? 0,
      byStatus: byStatus,
      byProdi: byProdi,
      fakultas: json['fakultas'],
    );
  }

  int get diajukan => byStatus['Diajukan'] ?? 0;
  int get disetujui => byStatus['Disetujui'] ?? 0;
  int get ditolak => byStatus['Ditolak'] ?? 0;
  int get selesai => byStatus['Selesai'] ?? 0;
}

/// Model for Admin Sekolah profile
class AdminSekolah {
  final int? idAdminSekolah;
  final int idUser;
  final String nama;
  final String? nip;
  final String namaSekolah;
  final String? alamatSekolah;
  final String jenisSekolah;
  final String? jabatan;
  final String? email;
  final String? telepon;
  final String? foto;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminSekolah({
    this.idAdminSekolah,
    required this.idUser,
    required this.nama,
    this.nip,
    required this.namaSekolah,
    this.alamatSekolah,
    required this.jenisSekolah,
    this.jabatan,
    this.email,
    this.telepon,
    this.foto,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminSekolah.fromJson(Map<String, dynamic> json) {
    return AdminSekolah(
      idAdminSekolah: json['id_admin_sekolah'] != null
          ? int.tryParse(json['id_admin_sekolah'].toString())
          : null,
      idUser: int.parse(json['id_user'].toString()),
      nama: json['nama'] ?? '',
      nip: json['nip'],
      namaSekolah: json['nama_sekolah'] ?? '',
      alamatSekolah: json['alamat_sekolah'],
      jenisSekolah: json['jenis_sekolah'] ?? 'SMK',
      jabatan: json['jabatan'],
      email: json['email'],
      telepon: json['telepon'],
      foto: json['foto'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idAdminSekolah != null) 'id_admin_sekolah': idAdminSekolah,
      'id_user': idUser,
      'nama': nama,
      if (nip != null) 'nip': nip,
      'nama_sekolah': namaSekolah,
      if (alamatSekolah != null) 'alamat_sekolah': alamatSekolah,
      'jenis_sekolah': jenisSekolah,
      if (jabatan != null) 'jabatan': jabatan,
      if (email != null) 'email': email,
      if (telepon != null) 'telepon': telepon,
    };
  }

  /// Get initials for avatar
  String get initials {
    final parts = nama.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }
}

/// Model for school statistics
class StatistikSekolah {
  final int totalPengajuan;
  final Map<String, int> byStatus;
  final Map<String, int> byKelas;
  final String? namaSekolah;

  StatistikSekolah({
    required this.totalPengajuan,
    required this.byStatus,
    required this.byKelas,
    this.namaSekolah,
  });

  factory StatistikSekolah.fromJson(Map<String, dynamic> json) {
    // Parse by_status
    final statusList = json['by_status'] as List? ?? [];
    final byStatus = <String, int>{};
    for (final item in statusList) {
      byStatus[item['status_pengajuan'] ?? ''] =
          int.tryParse(item['jumlah'].toString()) ?? 0;
    }

    // Parse by_kelas
    final kelasList = json['by_kelas'] as List? ?? [];
    final byKelas = <String, int>{};
    for (final item in kelasList) {
      byKelas[item['kelas'] ?? ''] =
          int.tryParse(item['jumlah'].toString()) ?? 0;
    }

    return StatistikSekolah(
      totalPengajuan: int.tryParse(json['total_pengajuan'].toString()) ?? 0,
      byStatus: byStatus,
      byKelas: byKelas,
      namaSekolah: json['nama_sekolah'],
    );
  }

  int get diajukan => byStatus['Diajukan'] ?? 0;
  int get disetujui => byStatus['Disetujui'] ?? 0;
  int get ditolak => byStatus['Ditolak'] ?? 0;
  int get selesai => byStatus['Selesai'] ?? 0;
}
