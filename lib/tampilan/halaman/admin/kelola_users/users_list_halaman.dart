import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umpar_magang_dan_pkl/provider/users_provider.dart';
import '../../../../konfigurasi/konstanta.dart';

import '../../../komponen/empty_state.dart';
import '../../../komponen/shimmer_loading.dart';
import '../../../komponen/kartu_status.dart';
import 'user_form_halaman.dart';

class UsersListHalaman extends StatefulWidget {
  const UsersListHalaman({super.key});

  @override
  State<UsersListHalaman> createState() => _UsersListHalamanState();
}

class _UsersListHalamanState extends State<UsersListHalaman>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _roles = [
    'Semua',
    'Mahasiswa',
    'Siswa',
    'Dosen',
    'Guru',
    'Instansi'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _roles.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadData();
    }
  }

  void _loadData() {
    final roleIndex = _tabController.index;
    final role = roleIndex == 0 ? null : _roles[roleIndex].toLowerCase();
    context.read<UsersProvider>().ambilSemuaUser(role: role);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _roles.map((role) => Tab(text: role)).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<UsersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const ShimmerListPengajuan(); // Fixed: Use correct Shimmer widget
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!,
                      style: const TextStyle(color: WarnaAplikasi.error)),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.daftarUsers.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              judul: 'Belum ada data user',
              deskripsi: 'Silakan tambah user baru',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
            itemCount: provider.daftarUsers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = provider.daftarUsers[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        WarnaAplikasi.primary.withValues(alpha: 0.1),
                    backgroundImage: user.fotoProfil != null
                        ? NetworkImage(user.fotoProfil!)
                        : null,
                    child: user.fotoProfil == null
                        ? Text(
                            user.namaLengkap.isNotEmpty
                                ? user.namaLengkap[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: WarnaAplikasi.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    user.namaLengkap,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email ?? user.username),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          KartuStatus(
                            status: user.role
                                .label, // Use label for user friendly display
                            tipe: TipeStatus.info,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            user.isActive ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: user.isActive
                                ? WarnaAplikasi
                                    .success // Fixed: successGreen -> success
                                : WarnaAplikasi.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.isActive ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 12,
                              color: user.isActive
                                  ? WarnaAplikasi
                                      .success // Fixed: successGreen -> success
                                  : WarnaAplikasi.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenuAction(value, user.idUser, user.isActive),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: user.isActive ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(
                              user.isActive
                                  ? Icons.block
                                  : Icons.check_circle_outline,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormHalaman()),
          );
          if (result == true) _loadData();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _handleMenuAction(String action, int userId, bool currentStatus) async {
    final provider = context.read<UsersProvider>();

    if (action == 'activate') {
      await provider.updateUser(
          userId, {'status_aktif': 1}); // Helper handles bool/int mapping
    } else if (action == 'deactivate') {
      await provider.updateUser(
          userId, {'status_aktif': 0}); // Helper handles bool/int mapping
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus User'),
          content: const Text('Apakah Anda yakin ingin menghapus user ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await provider.hapusUser(userId);
      }
    } else if (action == 'edit') {
      final user = provider.daftarUsers.firstWhere((u) => u.idUser == userId);
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserFormHalaman(user: user)),
      );
      if (result == true) _loadData();
    }
  }
}
