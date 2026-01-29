import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../komponen/shimmer_loading.dart';
import '../../komponen/empty_state.dart';
import 'nilai_input_halaman.dart';

class PenilaianListHalaman extends StatefulWidget {
  const PenilaianListHalaman({super.key});

  @override
  State<PenilaianListHalaman> createState() => _PenilaianListHalamanState();
}

class _PenilaianListHalamanState extends State<PenilaianListHalaman> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Penilaian')),
      body: Consumer<PengajuanProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.daftarPengajuan.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(UkuranAplikasi.paddingSedang),
              child: ShimmerListPengajuan(),
            );
          }

          // Filter: Approved or Finished (Only they can be graded)
          final daftar = provider.daftarPengajuan
              .where((p) => p.isDisetujui || p.isSelesai)
              .toList();

          if (daftar.isEmpty) {
            return const EmptyState(
              icon: Icons.grade_outlined,
              judul: 'Belum Ada Mahasiswa',
              deskripsi: 'Belum ada mahasiswa/siswa yang siap dinilai.',
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NilaiInputHalaman(
                            idPengajuan: pengajuan.idPengajuan,
                            namaMahasiswa: nama,
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
                                WarnaAplikasi.warning.withAlpha(26),
                            child: Text(
                              nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: WarnaAplikasi.warning,
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
                                    const Icon(Icons.business,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        pengajuan.namaInstansi ?? '-',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_note,
                              color: WarnaAplikasi.warning),
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
