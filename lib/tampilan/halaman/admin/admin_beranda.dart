import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../konfigurasi/rute.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/users_provider.dart';
import '../../../provider/notifikasi_provider.dart';
import '../../../provider/dashboard_provider.dart'; // Add
import 'package:fl_chart/fl_chart.dart'; // Add
import 'kelola_users/users_list_halaman.dart';
import 'kelola_users/aktivasi_user_halaman.dart';
import 'cetak/cetak_halaman.dart';
import '../profil/profil_halaman.dart';

/// Halaman Beranda Admin - UI/UX Upgraded
class AdminBeranda extends StatefulWidget {
  const AdminBeranda({super.key});

  @override
  State<AdminBeranda> createState() => _AdminBerandaState();
}

class _AdminBerandaState extends State<AdminBeranda>
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
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<DashboardProvider>().getAdminStats(token);
      }
      context.read<UsersProvider>().ambilSemuaUser();
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
          _buildVerifikasiContent(),
          _buildUsersContent(),
          _buildCetakContent(),
          _buildProfilContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBerandaContent() {
    final auth = context.watch<AuthProvider>();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // Modern Header
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
                                  auth.pengguna?.namaLengkap ?? 'Admin',
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
                                    'Administrator',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                child: const Icon(Icons.admin_panel_settings,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats in Header
                      Consumer<UsersProvider>(
                        builder: (context, prov, _) {
                          final totalUser = prov.daftarUsers.length;
                          final perluAktivasi =
                              prov.daftarUsers.where((u) => !u.isActive).length;
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
                                  icon: Icons.people,
                                  value: prov.isLoading ? '...' : '$totalUser',
                                  label: 'Total User',
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withAlpha(50),
                                ),
                                _buildHeaderStat(
                                  icon: Icons.person_add,
                                  value:
                                      prov.isLoading ? '...' : '$perluAktivasi',
                                  label: 'Perlu Aktivasi',
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

          // Stats Cards
          SliverToBoxAdapter(
            child: _buildStatsGrid(),
          ),

          // Chart Section
          SliverToBoxAdapter(
            child: _buildChartSection(),
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

  // --- NEW WIDGETS ---

  Widget _buildStatsGrid() {
    return Consumer<DashboardProvider>(builder: (context, provider, _) {
      final stats = provider.adminStats ?? {};
      final isLoading = provider.isLoading;

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Mahasiswa',
                        isLoading
                            ? '...'
                            : (stats['total_mahasiswa']?.toString() ?? '0'),
                        Icons.school,
                        Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        'Siswa',
                        isLoading
                            ? '...'
                            : (stats['total_siswa']?.toString() ?? '0'),
                        Icons.backpack,
                        Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Pengajuan Aktif',
                        isLoading
                            ? '...'
                            : (stats['pengajuan_aktif']?.toString() ?? '0'),
                        Icons.pending_actions,
                        Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        'Selesai',
                        isLoading
                            ? '...'
                            : (stats['pengajuan_selesai']?.toString() ?? '0'),
                        Icons.check_circle,
                        Colors.teal)),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withAlpha(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withAlpha(30), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Consumer<DashboardProvider>(builder: (context, provider, _) {
      final stats = provider.adminStats ?? {};
      final chartData = (stats['chart_data'] as List?) ?? [];

      if (chartData.isEmpty && !provider.isLoading)
        return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statistik Pengajuan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('6 Bulan Terakhir',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Icon(Icons.bar_chart, color: WarnaAplikasi.primary),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(chartData) + 2, // Dynamic Max Y
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(getTooltipItem:
                              (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.round().toString(),
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            );
                          }),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < chartData.length) {
                                  // Format: 2024-05 -> May
                                  final dateStr =
                                      chartData[value.toInt()]['bulan'];
                                  // Simple parser for month
                                  final month =
                                      dateStr.toString().split('-')[1];
                                  final mNames = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'Mei',
                                    'Jun',
                                    'Jul',
                                    'Agust',
                                    'Sept',
                                    'Okt',
                                    'Nov',
                                    'Des'
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(mNames[int.parse(month) - 1],
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false) // Clean look
                              ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withAlpha(50), strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(chartData.length, (index) {
                          final count = double.tryParse(
                                  chartData[index]['total'].toString()) ??
                              0;
                          return BarChartGroupData(x: index, barRods: [
                            BarChartRodData(
                              toY: count,
                              color: WarnaAplikasi.primary,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: _getMaxY(chartData) + 2, // Full height bg
                                color: Colors.grey.withAlpha(20),
                              ),
                            )
                          ]);
                        }),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  double _getMaxY(List<dynamic> data) {
    double max = 0;
    for (var item in data) {
      final val = double.tryParse(item['total'].toString()) ?? 0;
      if (val > max) max = val;
    }
    return max == 0 ? 5 : max;
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

  Widget _buildQuickMenuGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModernQuickMenu(
                icon: Icons.check_circle_outline,
                label: 'Aktivasi',
                color: WarnaAplikasi.success,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildModernQuickMenu(
                icon: Icons.people_outline,
                label: 'Users',
                color: WarnaAplikasi.primary,
                onTap: () =>
                    Navigator.pushNamed(context, RuteAplikasi.kelolaUser),
              ),
              _buildModernQuickMenu(
                icon: Icons.print_outlined,
                label: 'Cetak',
                color: WarnaAplikasi.warning,
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _buildModernQuickMenu(
                icon: Icons.person_outline,
                label: 'Profil',
                color: WarnaAplikasi.info,
                onTap: () => setState(() => _currentIndex = 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    icon: _getNotifIcon(n.judul),
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
    required IconData icon,
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
              color: WarnaAplikasi.info.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: WarnaAplikasi.info, size: 20),
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

  IconData _getNotifIcon(String judul) {
    if (judul.toLowerCase().contains('pengajuan')) return Icons.description;
    if (judul.toLowerCase().contains('akun') ||
        judul.toLowerCase().contains('registrasi')) {
      return Icons.person_add;
    }
    return Icons.info_outline;
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'Baru saja';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }

  Widget _buildVerifikasiContent() => const AktivasiUserHalaman();
  Widget _buildUsersContent() => const UsersListHalaman();
  Widget _buildCetakContent() => const CetakHalaman();
  Widget _buildProfilContent() => const ProfilHalaman();

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
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'Aktivasi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(Icons.print_outlined),
              activeIcon: Icon(Icons.print),
              label: 'Cetak'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}
