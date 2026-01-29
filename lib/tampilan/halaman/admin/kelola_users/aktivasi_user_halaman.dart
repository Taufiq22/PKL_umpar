import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../konfigurasi/konstanta.dart';
import '../../../../provider/users_provider.dart';
import '../../../komponen/empty_state.dart';
import '../../../komponen/shimmer_loading.dart';

/// Halaman untuk aktivasi akun user (khusus admin)
class AktivasiUserHalaman extends StatefulWidget {
  const AktivasiUserHalaman({super.key});

  @override
  State<AktivasiUserHalaman> createState() => _AktivasiUserHalamanState();
}

class _AktivasiUserHalamanState extends State<AktivasiUserHalaman> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingUsers();
    });
  }

  void _loadPendingUsers() {
    // Load users with is_active = 0
    context.read<UsersProvider>().ambilSemuaUser(status: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivasi Akun'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingUsers,
          ),
        ],
      ),
      body: Consumer<UsersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(UkuranAplikasi.paddingSedang),
              child: ShimmerListPengajuan(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: WarnaAplikasi.error),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: WarnaAplikasi.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPendingUsers,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // Filter only inactive users
          final pendingUsers =
              provider.daftarUsers.where((u) => !u.isActive).toList();

          if (pendingUsers.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              judul: 'Semua Akun Sudah Aktif',
              deskripsi: 'Tidak ada akun yang menunggu aktivasi',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
            itemCount: pendingUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = pendingUsers[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                WarnaAplikasi.warning.withAlpha(51),
                            child: Text(
                              user.namaLengkap.isNotEmpty
                                  ? user.namaLengkap[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: WarnaAplikasi.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.namaLengkap,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  user.email ?? user.username,
                                  style: const TextStyle(
                                    color: WarnaAplikasi.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: WarnaAplikasi.info.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role.label,
                              style: const TextStyle(
                                color: WarnaAplikasi.info,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showRejectDialog(user.idUser),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Tolak'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: WarnaAplikasi.error,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _activateUser(user.idUser),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Aktifkan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WarnaAplikasi.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _activateUser(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aktifkan Akun'),
        content: const Text('Apakah Anda yakin ingin mengaktifkan akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.success,
            ),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<UsersProvider>();
      final success = await provider.updateUser(userId, {'status_aktif': 1});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Akun berhasil diaktifkan'
                : 'Gagal mengaktifkan akun'),
            backgroundColor:
                success ? WarnaAplikasi.success : WarnaAplikasi.error,
          ),
        );

        if (success) {
          _loadPendingUsers();
        }
      }
    }
  }

  Future<void> _showRejectDialog(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Aktivasi'),
        content: const Text(
            'Apakah Anda yakin ingin menolak aktivasi akun ini? Akun akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.error,
            ),
            child: const Text('Tolak & Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<UsersProvider>();
      final success = await provider.hapusUser(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? 'Akun berhasil dihapus' : 'Gagal menghapus akun'),
            backgroundColor:
                success ? WarnaAplikasi.success : WarnaAplikasi.error,
          ),
        );

        if (success) {
          _loadPendingUsers();
        }
      }
    }
  }
}
