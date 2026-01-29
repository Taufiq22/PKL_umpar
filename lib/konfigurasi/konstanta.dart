import 'package:flutter/material.dart';

/// Konstanta warna aplikasi MagangKu
/// Berdasarkan design reference dengan color scheme biru-putih
class WarnaAplikasi {
  WarnaAplikasi._();

  // Warna Utama
  static const Color primary = Color(0xFF3B5EE8);
  static const Color primaryLight = Color(0xFF6B8AFF);
  static const Color primaryDark = Color(0xFF2A4BC4);

  // Background
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Teks
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Status Pengajuan
  static const Color statusDiajukan = Color(0xFFF59E0B);
  static const Color statusDisetujui = Color(0xFF10B981);
  static const Color statusDitolak = Color(0xFFEF4444);
  static const Color statusSelesai = Color(0xFF6366F1);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF3B5EE8), Color(0xFF6B8AFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Konstanta ukuran dan spacing
class UkuranAplikasi {
  UkuranAplikasi._();

  // Padding
  static const double paddingKecil = 8.0;
  static const double paddingSedang = 16.0;
  static const double paddingBesar = 24.0;
  static const double paddingEkstraBesar = 32.0;

  // Margin
  static const double marginKecil = 8.0;
  static const double marginSedang = 16.0;
  static const double marginBesar = 24.0;

  // Border Radius
  static const double radiusKecil = 8.0;
  static const double radiusSedang = 12.0;
  static const double radiusBesar = 16.0;
  static const double radiusCard = 16.0;
  static const double radiusButton = 12.0;

  // Elevation
  static const double elevasiKecil = 2.0;
  static const double elevasiSedang = 4.0;
  static const double elevasiBesar = 8.0;

  // Icon Size
  static const double iconKecil = 16.0;
  static const double iconSedang = 24.0;
  static const double iconBesar = 32.0;
  static const double iconEkstraBesar = 48.0;

  // Font Size
  static const double fontKecil = 12.0;
  static const double fontSedang = 14.0;
  static const double fontNormal = 16.0;
  static const double fontBesar = 18.0;
  static const double fontJudul = 20.0;
  static const double fontHeader = 24.0;

  // Tinggi komponen
  static const double tinggiButton = 48.0;
  static const double tinggiTextField = 56.0;
  static const double tinggiAppBar = 56.0;
  static const double tinggiBottomNav = 60.0;
}

/// Konstanta API
class ApiKonstanta {
  ApiKonstanta._();

  // Base URL - ganti dengan URL Laragon Anda
  static const String baseUrl = 'http://localhost/umpar_magang_dan_pkl/api';

  // Endpoints Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profil = '/auth/profil';

  // Endpoints Admin
  static const String adminUsers = '/users';
  // Admin memverifikasi via endpoint pengajuan biasa dengan method PUT

  // Endpoints Cetak
  static const String cetak = '/cetak';

  // Endpoints Pengajuan
  static const String pengajuan = '/pengajuan';

  // Endpoints Laporan
  static const String laporan = '/laporan';

  // Endpoints Nilai
  static const String nilai = '/nilai';

  // Endpoints Notifikasi
  static const String notifikasi = '/notifikasi';

  // Endpoints Instansi
  static const String instansi = '/instansi';

  // Endpoints Pembimbing
  static const String pembimbing = '/pembimbing';

  // Endpoints Kehadiran
  static const String kehadiran = '/kehadiran';

  // Endpoints Bimbingan
  static const String bimbingan = '/bimbingan';

  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}

/// Konstanta teks aplikasi (untuk i18n di masa depan)
class TeksAplikasi {
  TeksAplikasi._();

  // App
  static const String namaAplikasi = 'Welcome';
  static const String tagline = 'Sistem Informasi Manajemen PKL & Magang';
  static const String universitas = 'Universitas Muhammadiyah Parepare';

  // Auth
  static const String masuk = 'Masuk';
  static const String daftar = 'Daftar';
  static const String keluar = 'Keluar';
  static const String lupaPassword = 'Lupa Password?';

  // Menu
  static const String beranda = 'Beranda';
  static const String pengajuanMenu = 'Pengajuan';
  static const String laporanMenu = 'Laporan';
  static const String bimbinganMenu = 'Bimbingan';
  static const String nilaiMenu = 'Nilai';
  static const String profilMenu = 'Profil';
  static const String notifikasiMenu = 'Notifikasi';

  // Status
  static const String diajukan = 'Diajukan';
  static const String disetujui = 'Disetujui';
  static const String ditolak = 'Ditolak';
  static const String selesai = 'Selesai';

  // Pesan
  static const String loading = 'Memuat...';
  static const String berhasilDisimpan = 'Berhasil disimpan';
  static const String gagalMemuat = 'Gagal memuat data';
  static const String tidakAdaData = 'Tidak ada data';
}

/// Role pengguna - Sesuai UML (8 Aktor)
enum RolePengguna {
  admin('admin', 'Administrator'),
  adminFakultas('admin_fakultas', 'Admin Fakultas'),
  adminSekolah('admin_sekolah', 'Admin Sekolah'),
  mahasiswa('mahasiswa', 'Mahasiswa'),
  siswa('siswa', 'Siswa'),
  dosen('dosen', 'Dosen Pembimbing'),
  guru('guru', 'Guru Pembimbing'),
  instansi('instansi', 'Instansi');

  final String kode;
  final String label;

  const RolePengguna(this.kode, this.label);

  static RolePengguna fromString(String role) {
    return RolePengguna.values.firstWhere(
      (e) => e.kode == role,
      orElse: () => RolePengguna.mahasiswa,
    );
  }

  /// Check if role is admin type
  bool get isAdmin =>
      this == admin || this == adminFakultas || this == adminSekolah;

  /// Check if role is pembimbing type
  bool get isPembimbing => this == dosen || this == guru;

  /// Check if role is peserta type
  bool get isPeserta => this == mahasiswa || this == siswa;
}

/// Status pengajuan
enum StatusPengajuan {
  diajukan('Diajukan', WarnaAplikasi.statusDiajukan),
  disetujui('Disetujui', WarnaAplikasi.statusDisetujui),
  ditolak('Ditolak', WarnaAplikasi.statusDitolak),
  selesai('Selesai', WarnaAplikasi.statusSelesai);

  final String label;
  final Color warna;

  const StatusPengajuan(this.label, this.warna);

  static StatusPengajuan fromString(String status) {
    return StatusPengajuan.values.firstWhere(
      (e) => e.label == status,
      orElse: () => StatusPengajuan.diajukan,
    );
  }
}

/// Jenis pengajuan
enum JenisPengajuan {
  magang('Magang'),
  pkl('PKL');

  final String label;

  const JenisPengajuan(this.label);

  static JenisPengajuan fromString(String jenis) {
    return JenisPengajuan.values.firstWhere(
      (e) => e.label == jenis,
      orElse: () => JenisPengajuan.magang,
    );
  }
}

/// Jenis laporan
enum JenisLaporan {
  harian('Harian'),
  monitoring('Monitoring'),
  bimbingan('Bimbingan');

  final String label;

  const JenisLaporan(this.label);

  static JenisLaporan fromString(String jenis) {
    return JenisLaporan.values.firstWhere(
      (e) => e.label == jenis,
      orElse: () => JenisLaporan.harian,
    );
  }
}
