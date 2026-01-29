import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../komponen/shimmer_loading.dart';
import '../../komponen/empty_state.dart';
import 'bimbingan_enhanced_halaman.dart';
import '../../../provider/auth_provider.dart';

/// Halaman Daftar Bimbingan - UML Compliant
/// Menampilkan daftar mahasiswa/siswa yang bisa dibimbing
/// Navigasi ke BimbinganEnhancedHalaman untuk fitur bimbingan yang proper
class BimbinganListHalaman extends StatefulWidget {
  final int? idPengajuan;

  const BimbinganListHalaman({super.key, this.idPengajuan});

  @override
  State<BimbinganListHalaman> createState() => _BimbinganListHalamanState();
}

class _BimbinganListHalamanState extends State<BimbinganListHalaman> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanProvider>().ambilPengajuan();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<PengajuanProvider>().ambilPengajuan();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    // If idPengajuan is provided (User is Student), show Enhanced page directly
    if (widget.idPengajuan != null) {
      return BimbinganEnhancedHalaman(idPengajuan: widget.idPengajuan!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bimbingan'),
        backgroundColor: WarnaAplikasi.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PengajuanProvider>(
        builder: (context, provider, _) {
          // Logic baru: Jika Mahasiswa/Siswa punya pengajuan aktif, langsung tampilkan enhanced page
          final authProvider = context.read<AuthProvider>();
          final isStudent = authProvider.role?.isPeserta ?? false;

          if (isStudent && provider.pengajuanAktif != null) {
            return BimbinganEnhancedHalaman(
                idPengajuan: provider.pengajuanAktif!.idPengajuan);
          }

          if (provider.isLoading && provider.daftarPengajuan.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(UkuranAplikasi.paddingSedang),
              child: ShimmerListPengajuan(),
            );
          }

          // Filter: Approved or Finished
          final daftar = provider.daftarPengajuan
              .where((p) => p.isDisetujui || p.isSelesai)
              .toList();

          if (daftar.isEmpty) {
            return const EmptyState(
              icon: Icons.school_outlined,
              judul: 'Belum Ada Bimbingan',
              deskripsi: 'Belum ada mahasiswa/siswa bimbingan.',
            );
          }

          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                final pengajuan = daftar[index];
                final nama = pengajuan.namaMahasiswa ??
                    pengajuan.namaSiswa ??
                    'Tanpa Nama';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Navigate to Enhanced Bimbingan page (UML Compliant)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BimbinganEnhancedHalaman(
                            idPengajuan: pengajuan.idPengajuan,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                WarnaAplikasi.success.withAlpha(26),
                            child: Text(
                              nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: WarnaAplikasi.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.work_outline,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        pengajuan.posisi ?? '-',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.business,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        pengajuan.namaInstansi ?? '-',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
