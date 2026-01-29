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
import '../cetak/cetak_siswa_halaman.dart';
import '../profil/profil_halaman.dart';
import '../kehadiran/kehadiran_halaman.dart';

/// Halaman Beranda Siswa - UI/UX Upgraded Version
class SiswaBeranda extends StatefulWidget {
  const SiswaBeranda({super.key});

  @override
  State<SiswaBeranda> createState() => _SiswaBerandaState();
}

class _SiswaBerandaState extends State<SiswaBeranda>
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
                                  auth.pengguna?.namaLengkap ?? 'Siswa',
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
                                    auth.pengguna is Siswa
                                        ? (auth.pengguna as Siswa).sekolah
                                        : 'SMK',
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
                                  (auth.pengguna?.namaLengkap ?? 'S')[0]
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
                        builder: (context, lapProv, _) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildHeaderStat(
                                  icon: Icons.description,
                                  value: '${lapProv.daftarLaporan.length}',
                                  label: 'Laporan',
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withAlpha(50),
                                ),
                                _buildHeaderStat(
                                  icon: Icons.check_circle,
                                  value: '${lapProv.laporanDisetujui.length}',
                                  label: 'Disetujui',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Status Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: pengajuan.pengajuanAktif != null
                  ? _buildModernStatusCard(pengajuan.pengajuanAktif)
                  : const EmptyState.pengajuan(),
            ),
          ),

          // Quick Menu
          SliverToBoxAdapter(
            child: _buildQuickMenuGrid(),
          ),

          // Activity
          SliverToBoxAdapter(
            child: _buildActivityList(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
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
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: WarnaAplikasi.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.business_center,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status PKL',
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
                    Icons.work_outline, 'Posisi', pengajuan.posisi ?? '-'),
              ),
              Expanded(
                child: _buildInfoItem(Icons.calendar_today, 'Periode',
                    '${pengajuan.durasiBulan} bulan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    if (status.toLowerCase().contains('disetujui') ||
        status.toLowerCase().contains('selesai')) {
      chipColor = WarnaAplikasi.success;
    } else if (status.toLowerCase().contains('ditolak')) {
      chipColor = WarnaAplikasi.error;
    } else {
      chipColor = WarnaAplikasi.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: chipColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: WarnaAplikasi.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Cepat',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceAround,
            children: [
              _buildModernQuickMenu(
                icon: Icons.list_alt,
                label: 'Daftar',
                color: WarnaAplikasi.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const PengajuanListHalaman(isMagang: false)),
                  );
                },
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
                            'Anda belum mengajukan PKL. Silakan daftar terlebih dahulu.'),
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
                            'Status PKL: ${aktif.statusPengajuan.label}. Laporan hanya tersedia setelah disetujui.'),
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
                            'Anda belum mengajukan PKL. Silakan daftar terlebih dahulu.'),
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
                            'Status PKL: ${aktif.statusPengajuan.label}. Bimbingan tersedia setelah disetujui.'),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CetakSiswaHalaman()),
                  );
                },
              ),
              _buildModernQuickMenu(
                icon: Icons.grade_outlined,
                label: 'Nilai',
                color: WarnaAplikasi.error,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas Terbaru',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RuteAplikasi.notifikasi);
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          Consumer<NotifikasiProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.daftarNotifikasi.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Belum ada aktivitas'),
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
          ),
        ],
      ),
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
              : WarnaAplikasi.primary.withAlpha(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: WarnaAplikasi.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WarnaAplikasi.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WarnaAplikasi.textLight,
                ),
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
            judul: 'Belum Ada PKL',
            deskripsi: 'Anda belum terdaftar dalam program PKL apapun.',
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
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: WarnaAplikasi.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Laporan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Nilai'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}
