import 'package:flutter/material.dart';
import '../tampilan/halaman/auth/auth_halaman.dart';
import '../tampilan/halaman/admin/admin_beranda.dart';
import '../tampilan/halaman/admin/kelola_user_halaman.dart';
import '../tampilan/halaman/mahasiswa/mahasiswa_beranda.dart';
import '../tampilan/halaman/siswa/siswa_beranda.dart';
import '../tampilan/halaman/dosen/dosen_beranda.dart';
import '../tampilan/halaman/guru/guru_beranda.dart';
import '../tampilan/halaman/instansi/instansi_beranda.dart';
import '../tampilan/halaman/profil/profil_halaman.dart';
import '../tampilan/halaman/notifikasi/notifikasi_list_halaman.dart';
import '../tampilan/halaman/cetak/surat_permohonan_halaman.dart';
import '../tampilan/halaman/cetak/surat_balasan_halaman.dart';
import '../tampilan/halaman/pengajuan/pengajuan_list_halaman.dart';
import '../tampilan/halaman/pengajuan/pengajuan_form_halaman.dart';
import '../tampilan/halaman/pengajuan/pengajuan_detail_halaman.dart';
import '../tampilan/halaman/laporan/laporan_list_halaman.dart';
import '../tampilan/halaman/laporan/laporan_review_halaman.dart';
import '../tampilan/halaman/bimbingan/bimbingan_list_halaman.dart';
import '../tampilan/halaman/nilai/nilai_list_halaman.dart';
import '../tampilan/halaman/nilai/penilaian_list_halaman.dart';
import '../tampilan/halaman/monitoring/monitoring_list_halaman.dart';
import '../tampilan/halaman/kehadiran/kehadiran_halaman.dart';
import '../tampilan/halaman/kehadiran/input_kehadiran_halaman.dart';
import '../tampilan/halaman/bimbingan/bimbingan_enhanced_halaman.dart';
import '../tampilan/halaman/admin_fakultas/admin_fakultas_beranda.dart';
import '../tampilan/halaman/admin_fakultas/kelola_dosen_halaman.dart';
import '../tampilan/halaman/admin_sekolah/admin_sekolah_beranda.dart';
import '../tampilan/halaman/admin_sekolah/kelola_guru_halaman.dart';
import '../tampilan/halaman/verifikasi/verifikasi_pengajuan_halaman.dart';
import '../data/model/pengajuan.dart';

/// Konfigurasi routing aplikasi
class RuteAplikasi {
  RuteAplikasi._();

  // Nama rute
  static const String login = '/login';
  static const String daftar = '/daftar';
  // Admin routes
  static const String berandaAdmin = '/admin/beranda';
  static const String kelolaUser = '/admin/kelola-user';
  static const String berandaMahasiswa = '/mahasiswa';
  static const String berandaSiswa = '/siswa';
  static const String berandaDosen = '/dosen';
  static const String berandaGuru = '/guru';
  static const String berandaInstansi = '/instansi';
  static const String berandaAdminFakultas = '/admin-fakultas';
  static const String kelolaDosenFakultas = '/admin-fakultas/dosen';
  static const String berandaAdminSekolah = '/admin-sekolah';
  static const String kelolaGuruSekolah = '/admin-sekolah/guru';
  static const String profil = '/profil';

  // Pengajuan
  static const String pengajuanList = '/pengajuan';
  static const String pengajuanMagang = '/mahasiswa/pengajuan';
  static const String pengajuanPkl = '/siswa/pengajuan';
  static const String pengajuanForm = '/pengajuan/form';
  static const String pengajuanDetail = '/pengajuan/detail';

  // Laporan
  static const String laporanMahasiswa = '/mahasiswa/laporan';
  static const String laporanSiswa = '/siswa/laporan';
  static const String laporanReview = '/laporan/review';

  // Bimbingan
  static const String bimbinganMahasiswa = '/mahasiswa/bimbingan';
  static const String bimbinganSiswa = '/siswa/bimbingan';
  static const String bimbinganEnhanced = '/bimbingan/enhanced';

  // Nilai
  static const String nilaiMahasiswa = '/mahasiswa/nilai';
  static const String nilaiSiswa = '/siswa/nilai';

  // Verifikasi
  static const String verifikasiDosen = '/dosen/verifikasi';
  static const String verifikasiGuru = '/guru/verifikasi';

  // Penilaian
  static const String penilaianDosen = '/dosen/penilaian';
  static const String penilaianGuru = '/guru/penilaian';
  static const String penilaianInstansi = '/instansi/penilaian';

  // Monitoring
  static const String monitoringList = '/monitoring';
  static const String monitoringDetail = '/monitoring/detail';

  // Kehadiran
  static const String kehadiranList = '/kehadiran';
  static const String kehadiranInput = '/kehadiran/input';

  // Notifikasi
  static const String notifikasi = '/notifikasi';

  // Cetak Surat
  static const String suratPermohonan = '/cetak/surat-permohonan';
  static const String suratBalasan = '/cetak/surat-balasan';

  // Verifikasi
  static const String verifikasiPengajuan = '/verifikasi/pengajuan';

  /// Rute awal aplikasi
  static String get ruteAwal => login;

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Root route - redirect to auth
      case '/':
        return _buildRoute(const AuthHalaman(), settings);

      // Auth
      case login:
        return _buildRoute(const AuthHalaman(initialTab: 0), settings);
      case daftar:
        return _buildRoute(const AuthHalaman(initialTab: 1), settings);

      // Beranda per role
      case berandaAdmin:
        return _buildRoute(const AdminBeranda(), settings);
      case kelolaUser:
        return _buildRoute(const KelolaUserHalaman(), settings);
      case berandaMahasiswa:
        return _buildRoute(const MahasiswaBeranda(), settings);
      case berandaSiswa:
        return _buildRoute(const SiswaBeranda(), settings);
      case berandaDosen:
        return _buildRoute(const DosenBeranda(), settings);
      case berandaGuru:
        return _buildRoute(const GuruBeranda(), settings);
      case berandaInstansi:
        return _buildRoute(const InstansiBeranda(), settings);
      case berandaAdminFakultas:
        return _buildRoute(const AdminFakultasBeranda(), settings);
      case kelolaDosenFakultas:
        return _buildRoute(const KelolaDosenHalaman(), settings);
      case berandaAdminSekolah:
        return _buildRoute(const AdminSekolahBeranda(), settings);
      case kelolaGuruSekolah:
        return _buildRoute(const KelolaGuruHalaman(), settings);

      // Profil
      case profil:
        return _buildRoute(const ProfilHalaman(showAppBar: true), settings);

      // Pengajuan
      case pengajuanList:
        final args = settings.arguments as Map<String, dynamic>?;
        final isAdmin = args?['isAdmin'] ?? false;
        final isMagang = args?['isMagang'] ?? true;
        return _buildRoute(
            PengajuanListHalaman(isAdmin: isAdmin, isMagang: isMagang),
            settings);
      case pengajuanMagang:
        return _buildRoute(
            const PengajuanFormHalaman(isMagang: true), settings);
      case pengajuanPkl:
        return _buildRoute(
            const PengajuanFormHalaman(isMagang: false), settings);
      case pengajuanForm:
        final isMagang = settings.arguments as bool? ?? true;
        return _buildRoute(PengajuanFormHalaman(isMagang: isMagang), settings);
      case pengajuanDetail:
        final pengajuan = settings.arguments as Pengajuan;
        return _buildRoute(
            PengajuanDetailHalaman(pengajuan: pengajuan), settings);

      // Laporan
      case laporanMahasiswa:
      case laporanSiswa:
        final idPengajuan = settings.arguments as int?;
        return _buildRoute(
          LaporanListHalaman(idPengajuan: idPengajuan ?? 0),
          settings,
        );
      case laporanReview:
        final idPengajuan = settings.arguments as int?;
        return _buildRoute(
          LaporanReviewHalaman(idPengajuan: idPengajuan),
          settings,
        );

      // Bimbingan
      case bimbinganMahasiswa:
      case bimbinganSiswa:
        return _buildRoute(const BimbinganListHalaman(), settings);
      case bimbinganEnhanced:
        final args = settings.arguments as Map<String, dynamic>?;
        final idPengajuan = args?['id_pengajuan'] as int?;
        return _buildRoute(
            BimbinganEnhancedHalaman(idPengajuan: idPengajuan), settings);

      // Nilai
      case nilaiMahasiswa:
      case nilaiSiswa:
        final idPengajuan = settings.arguments as int?;
        return _buildRoute(
          NilaiListHalaman(idPengajuan: idPengajuan ?? 0),
          settings,
        );

      // Verifikasi (Dosen/Guru)
      case verifikasiDosen:
      case verifikasiGuru:
        return _buildRoute(const PengajuanListHalaman(isAdmin: true), settings);

      // Penilaian
      case penilaianDosen:
      case penilaianGuru:
      case penilaianInstansi:
        return _buildRoute(const PenilaianListHalaman(), settings);

      // Monitoring
      case monitoringList:
        final args = settings.arguments as Map<String, dynamic>?;
        final destination = args?['destination'] as String? ?? 'laporan';
        return _buildRoute(
            MonitoringListHalaman(destination: destination), settings);
      case monitoringDetail:
        // This case was provided as 'monitoringDetail:diran' in the instruction.
        // Assuming 'diran' was a typo and it should be an empty case or lead to a specific page.
        // For now, it's left as an empty case as per the instruction's structure.
        // If it's meant to route to a page, that page and its arguments would need to be defined.
        return _buildRoute(
            const Text('Monitoring Detail Page'), settings); // Placeholder
      case kehadiranList:
        final args = settings.arguments as Map<String, dynamic>?;
        final idPengajuan = args?['id_pengajuan'] as int?;
        return _buildRoute(
            KehadiranHalaman(idPengajuan: idPengajuan), settings);
      case kehadiranInput:
        final args = settings.arguments as Map<String, dynamic>;
        final idPengajuan = args['id_pengajuan'] as int;
        return _buildRoute(
            InputKehadiranHalaman(idPengajuan: idPengajuan), settings);

      // Notifikasi
      case notifikasi:
        return _buildRoute(const NotifikasiListHalaman(), settings);

      // Verifikasi
      case verifikasiPengajuan:
        return _buildRoute(const VerifikasiPengajuanHalaman(), settings);

      // Cetak Surat
      case suratPermohonan:
        final idPengajuan = settings.arguments as int;
        return _buildRoute(
          SuratPermohonanHalaman(idPengajuan: idPengajuan),
          settings,
        );
      case suratBalasan:
        final idPengajuan = settings.arguments as int;
        return _buildRoute(
          SuratBalasanHalaman(idPengajuan: idPengajuan),
          settings,
        );

      // Default - halaman tidak ditemukan
      default:
        return _buildRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Halaman "${settings.name}" tidak ditemukan',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
          settings,
        );
    }
  }

  /// Helper untuk membuat MaterialPageRoute dengan animasi
  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  /// Navigasi ke beranda berdasarkan role
  static String getBerandaByRole(String role) {
    switch (role) {
      case 'admin':
        return berandaAdmin;
      case 'admin_fakultas':
        return berandaAdminFakultas;
      case 'admin_sekolah':
        return berandaAdminSekolah;
      case 'mahasiswa':
        return berandaMahasiswa;
      case 'siswa':
        return berandaSiswa;
      case 'dosen':
        return berandaDosen;
      case 'guru':
        return berandaGuru;
      case 'instansi':
        return berandaInstansi;
      default:
        return login;
    }
  }
}
