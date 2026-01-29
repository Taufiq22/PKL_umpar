import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../konfigurasi/rute.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../../provider/laporan_provider.dart';
import '../../../provider/notifikasi_provider.dart';
import '../../../data/model/pengguna.dart';
import '../../komponen/empty_state.dart';
import '../laporan/laporan_list_halaman.dart';
import '../nilai/nilai_list_halaman.dart';
import '../bimbingan/bimbingan_list_halaman.dart';

import '../pengajuan/pengajuan_list_halaman.dart';
import '../cetak/cetak_mahasiswa_halaman.dart';
import '../profil/profil_halaman.dart';
import '../kehadiran/kehadiran_halaman.dart';

/// Halaman Beranda Mahasiswa - UI/UX Upgraded Version
class MahasiswaBeranda extends StatefulWidget {
  const MahasiswaBeranda({super.key});

  @override
  State<MahasiswaBeranda> createState() => _MahasiswaBerandaState();
}

class _MahasiswaBerandaState extends State<MahasiswaBeranda>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pengajuanProv = context.read<PengajuanProvider>();
      pengajuanProv.ambilPengajuan().then((_) {
        if (pengajuanProv.pengajuanAktif != null) {
          context.read<LaporanProvider>().ambilLaporan(
                idPengajuan: pengajuanProv.pengajuanAktif!.idPengajuan,
              );
        }
      });
      context.read<NotifikasiProvider>().ambilNotifikasi();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildBerandaContent(),
          _buildLaporanContent(),
          _buildNilaiContent(),
          _buildProfilContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBerandaContent() {
    final auth = context.watch<AuthProvider>();
    final pengajuan = context.watch<PengajuanProvider>();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // Modern Header with Gradient
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: WarnaAplikasi.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  auth.pengguna?.namaLengkap ?? 'Mahasiswa',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(40),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    auth.pengguna is Mahasiswa
                                        ? (auth.pengguna as Mahasiswa).fakultas
                                        : 'UMPAR',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Notification & Avatar
                          Row(
                            children: [
                              Consumer<NotifikasiProvider>(
                                builder: (context, notifProv, _) {
                                  final unreadCount =
                                      notifProv.jumlahBelumDibaca;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(30),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Badge(
                                      isLabelVisible: unreadCount > 0,
                                      label: Text('$unreadCount'),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, RuteAplikasi.notifikasi);
                                        },
                                        icon: const Icon(
                                            Icons.notifications_outlined,
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white.withAlpha(50),
                                child: Text(
                                  (auth.pengguna?.namaLengkap ?? 'M')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats Row in Header
                      Consumer<LaporanProvider>(
                        builder: (context, provider, _) {
                          return Row(
                            children: [
                              Expanded(
                                child: _buildHeaderStat(
                                  icon: Icons.description_outlined,
                                  value: provider.isLoading
                                      ? '...'
                                      : '${provider.daftarLaporan.length}',
                                  label: 'Total Laporan',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withAlpha(50),
                              ),
                              Expanded(
                                child: _buildHeaderStat(
                                  icon: Icons.calendar_today_outlined,
                                  value: provider.isLoading
                                      ? '...'
                                      : '${provider.laporanHarian.length}',
                                  label: 'Kehadiran',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status Card
                if (pengajuan.pengajuanAktif != null) ...[
                  _buildModernStatusCard(pengajuan.pengajuanAktif!),
                  const SizedBox(height: 24),
                ],

                // Quick Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menu Cepat',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildQuickMenuGrid(),

                const SizedBox(height: 24),

                // Aktivitas Terbaru
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aktivitas Terbaru',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RuteAplikasi.notifikasi),
                      child: const Text('Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActivityList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildModernStatusCard(dynamic pengajuan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: WarnaAplikasi.primary.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: WarnaAplikasi.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work_outline,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Magang',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: WarnaAplikasi.textSecondary,
                          ),
                    ),
                    Text(
                      pengajuan.namaInstansi ?? 'Instansi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(pengajuan.statusPengajuan.label),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.person_outline,
                  'Posisi',
                  pengajuan.posisi ?? '-',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today_outlined,
                  'Periode',
                  pengajuan.tanggalMulai != null
                      ? pengajuan.tanggalMulai
                          .toString()
                          .split(" ")
                          .first
                          .substring(5)
                      : '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'disetujui':
        chipColor = WarnaAplikasi.success;
        break;
      case 'ditolak':
        chipColor = WarnaAplikasi.error;
        break;
      case 'selesai':
        chipColor = WarnaAplikasi.info;
        break;
      default:
        chipColor = WarnaAplikasi.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: WarnaAplikasi.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: WarnaAplikasi.textSecondary,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickMenuGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceAround,
        children: [
          _buildModernQuickMenu(
            icon: Icons.list_alt,
            label: 'Daftar',
            color: WarnaAplikasi.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PengajuanListHalaman()),
            ),
          ),
          _buildModernQuickMenu(
            icon: Icons.description_outlined,
            label: 'Laporan',
            color: WarnaAplikasi.warning,
            onTap: () {
              final pengajuan = context.read<PengajuanProvider>();
              final aktif = pengajuan.pengajuanAktif;

              if (aktif == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Anda belum mengajukan magang. Silakan daftar terlebih dahulu.'),
                    backgroundColor: WarnaAplikasi.warning,
                  ),
                );
                return;
              }

              if (aktif.statusPengajuan != StatusPengajuan.disetujui &&
                  aktif.statusPengajuan != StatusPengajuan.selesai) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Status pengajuan: ${aktif.statusPengajuan.label}. Laporan hanya tersedia setelah disetujui.'),
                    backgroundColor: WarnaAplikasi.warning,
                  ),
                );
                return;
              }

              setState(() => _currentIndex = 1);
            },
          ),
          _buildModernQuickMenu(
            icon: Icons.people_outline,
            label: 'Bimbingan',
            color: Colors.purple,
            onTap: () {
              final pengajuan = context.read<PengajuanProvider>();
              final aktif = pengajuan.pengajuanAktif;

              if (aktif == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Anda belum mengajukan magang/PKL. Silakan daftar terlebih dahulu.'),
                    backgroundColor: WarnaAplikasi.warning,
                  ),
                );
                return;
              }

              if (aktif.statusPengajuan != StatusPengajuan.disetujui &&
                  aktif.statusPengajuan != StatusPengajuan.selesai) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Status pengajuan: ${aktif.statusPengajuan.label}. Bimbingan hanya tersedia setelah disetujui.'),
                    backgroundColor: WarnaAplikasi.warning,
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BimbinganListHalaman(
                    idPengajuan: aktif.idPengajuan,
                  ),
                ),
              );
            },
          ),
          _buildModernQuickMenu(
            icon: Icons.access_time,
            label: 'Kehadiran',
            color: Colors.teal,
            onTap: () {
              final pengajuan = context.read<PengajuanProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KehadiranHalaman(
                    idPengajuan: pengajuan.pengajuanAktif?.idPengajuan,
                  ),
                ),
              );
            },
          ),
          _buildModernQuickMenu(
            icon: Icons.print_outlined,
            label: 'Cetak',
            color: WarnaAplikasi.success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CetakMahasiswaHalaman()),
            ),
          ),
          _buildModernQuickMenu(
            icon: Icons.grade_outlined,
            label: 'Nilai',
            color: WarnaAplikasi.error,
            onTap: () => setState(() => _currentIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuickMenu({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withAlpha(180)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return Consumer<NotifikasiProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (provider.daftarNotifikasi.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Belum ada aktivitas',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        return Column(
          children: provider.daftarNotifikasi.take(3).map((n) {
            return _buildModernActivityCard(
              title: n.judul,
              subtitle: n.pesan,
              time: _formatTime(n.createdAt),
              isRead: n.dibaca,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildModernActivityCard({
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : WarnaAplikasi.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? Colors.grey.withAlpha(30)
              : WarnaAplikasi.primary.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: WarnaAplikasi.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: WarnaAplikasi.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WarnaAplikasi.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: WarnaAplikasi.textSecondary,
                    ),
              ),
              if (!isRead) ...[
                const SizedBox(height: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: WarnaAplikasi.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'Baru saja';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }

  Widget _buildLaporanContent() {
    return Consumer<PengajuanProvider>(
      builder: (context, provider, _) {
        final p = provider.pengajuanAktif;
        if (p == null) {
          return const EmptyState.pengajuan();
        }
        return LaporanListHalaman(idPengajuan: p.idPengajuan);
      },
    );
  }

  Widget _buildNilaiContent() {
    return Consumer<PengajuanProvider>(
      builder: (context, provider, _) {
        final p = provider.pengajuanAktif;
        if (p == null) {
          return const EmptyState(
            icon: Icons.school_outlined,
            judul: 'Belum Ada Magang/PKL',
            deskripsi:
                'Anda belum terdaftar dalam program magang atau PKL apapun.',
          );
        }
        return NilaiListHalaman(idPengajuan: p.idPengajuan);
      },
    );
  }

  Widget _buildProfilContent() {
    return const ProfilHalaman();
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: WarnaAplikasi.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Nilai',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
