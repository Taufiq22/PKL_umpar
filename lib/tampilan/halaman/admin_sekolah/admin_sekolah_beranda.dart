/// Admin Sekolah Dashboard
/// UMPAR Magang & PKL System
///
/// Dashboard for school-level administrators

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/admin_roles.dart';
import '../../../provider/admin_roles_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../konfigurasi/rute.dart';

class AdminSekolahBeranda extends StatefulWidget {
  const AdminSekolahBeranda({super.key});

  @override
  State<AdminSekolahBeranda> createState() => _AdminSekolahBerandaState();
}

class _AdminSekolahBerandaState extends State<AdminSekolahBeranda> {
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
      provider.fetchProfilSekolah(),
      provider.fetchStatistikSekolah(),
      provider.fetchPengajuanSekolah(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Sekolah'),
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
                  _buildHeaderCard(provider.profilSekolah),
                  _buildStatisticsSection(provider.statistikSekolah),
                  _buildMenuGrid(),
                  _buildRecentPengajuan(provider.pengajuanSekolah),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(AdminSekolah? profil) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
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
                  profil?.nama ?? 'Admin Sekolah',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profil?.namaSekolah ?? 'Sekolah',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (profil?.jabatan != null)
                  Text(
                    profil!.jabatan!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              profil?.jenisSekolah ?? 'SMK',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(StatistikSekolah? stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              const Icon(Icons.analytics, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Statistik Pengajuan PKL',
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
            color: color.withOpacity(0.1),
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
      {'icon': Icons.people, 'label': 'Siswa', 'route': null},
      {
        'icon': Icons.school,
        'label': 'Guru',
        'route': RuteAplikasi.kelolaGuruSekolah
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
                    arguments = {'isAdmin': true, 'isMagang': false};
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
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.teal,
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
          backgroundColor: statusColor.withOpacity(0.1),
          child: Text(
            (pengajuan.namaSiswa ?? 'S')[0].toUpperCase(),
            style: TextStyle(color: statusColor),
          ),
        ),
        title: Text(pengajuan.namaSiswa ?? 'Siswa'),
        subtitle: Text(pengajuan.posisi ?? '-'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
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
