/// Admin Fakultas Dashboard
/// UMPAR Magang & PKL System
///
/// Dashboard for faculty-level administrators

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/admin_roles.dart';
import '../../../provider/admin_roles_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../konfigurasi/rute.dart';

class AdminFakultasBeranda extends StatefulWidget {
  const AdminFakultasBeranda({super.key});

  @override
  State<AdminFakultasBeranda> createState() => _AdminFakultasBerandaState();
}

class _AdminFakultasBerandaState extends State<AdminFakultasBeranda> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<AdminRolesProvider>();
    await Future.wait([
      provider.fetchProfilFakultas(),
      provider.fetchStatistikFakultas(),
      provider.fetchPengajuanFakultas(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Fakultas'),
        backgroundColor: WarnaAplikasi.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, RuteAplikasi.notifikasi),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profil') {
                Navigator.pushNamed(context, RuteAplikasi.profil);
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profil', child: Text('Profil')),
              const PopupMenuItem(value: 'logout', child: Text('Keluar')),
            ],
          ),
        ],
      ),
      body: Consumer<AdminRolesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(provider.profilFakultas),
                  _buildStatisticsSection(provider.statistikFakultas),
                  _buildMenuGrid(),
                  _buildRecentPengajuan(provider.pengajuanFakultas),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(AdminFakultas? profil) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [WarnaAplikasi.primary, WarnaAplikasi.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              profil?.initials ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profil?.nama ?? 'Admin Fakultas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profil?.fakultas ?? 'Fakultas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                if (profil?.jabatan != null)
                  Text(
                    profil!.jabatan!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(StatistikFakultas? stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: WarnaAplikasi.primary),
              const SizedBox(width: 8),
              const Text(
                'Statistik Pengajuan Magang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'Total: ${stats?.totalPengajuan ?? 0}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Diajukan', stats?.diajukan ?? 0, Colors.orange),
              _buildStatCard('Disetujui', stats?.disetujui ?? 0, Colors.green),
              _buildStatCard('Ditolak', stats?.ditolak ?? 0, Colors.red),
              _buildStatCard('Selesai', stats?.selesai ?? 0, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.verified_user,
        'label': 'Verifikasi',
        'route': RuteAplikasi.verifikasiPengajuan
      },
      {
        'icon': Icons.description,
        'label': 'Pengajuan',
        'route': RuteAplikasi.pengajuanList
      },
      {'icon': Icons.people, 'label': 'Mahasiswa', 'route': null},
      {
        'icon': Icons.school,
        'label': 'Dosen',
        'route': RuteAplikasi.kelolaDosenFakultas
      },
      {
        'icon': Icons.event,
        'label': 'Kehadiran',
        'route': RuteAplikasi.monitoringList
      },
      {
        'icon': Icons.psychology,
        'label': 'Bimbingan',
        'route': RuteAplikasi.bimbinganEnhanced
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                if (item['route'] != null) {
                  Object? arguments;
                  if (item['route'] == RuteAplikasi.pengajuanList) {
                    arguments = {'isAdmin': true, 'isMagang': true};
                  } else if (item['route'] == RuteAplikasi.monitoringList &&
                      item['label'] == 'Kehadiran') {
                    arguments = {'destination': 'kehadiran'};
                  }

                  Navigator.pushNamed(
                    context,
                    item['route'] as String,
                    arguments: arguments,
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: WarnaAplikasi.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentPengajuan(List pengajuanList) {
    final recent = pengajuanList.take(5).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Pengajuan Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RuteAplikasi.pengajuanList),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          if (recent.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Belum ada pengajuan',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...recent.map((p) => _buildPengajuanItem(p)),
        ],
      ),
    );
  }

  Widget _buildPengajuanItem(dynamic pengajuan) {
    final status = pengajuan.statusPengajuan ?? 'Diajukan';
    final statusColor = status == 'Disetujui'
        ? Colors.green
        : status == 'Ditolak'
            ? Colors.red
            : status == 'Selesai'
                ? Colors.blue
                : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Text(
            (pengajuan.namaMahasiswa ?? 'M')[0].toUpperCase(),
            style: TextStyle(color: statusColor),
          ),
        ),
        title: Text(pengajuan.namaMahasiswa ?? 'Mahasiswa'),
        subtitle: Text(pengajuan.posisi ?? '-'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, RuteAplikasi.login, (route) => false);
      }
    }
  }
}
