import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/pengajuan.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../komponen/shimmer_loading.dart';
import '../../komponen/empty_state.dart';

/// Halaman verifikasi pengajuan untuk dosen/guru
class VerifikasiListHalaman extends StatefulWidget {
  final bool isMagang; // true = dosen (magang), false = guru (PKL)

  const VerifikasiListHalaman({super.key, this.isMagang = true});

  @override
  State<VerifikasiListHalaman> createState() => _VerifikasiListHalamanState();
}

class _VerifikasiListHalamanState extends State<VerifikasiListHalaman> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanProvider>().ambilPengajuan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Pengajuan'),
      ),
      body: Consumer<PengajuanProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.daftarPengajuan.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(UkuranAplikasi.paddingSedang),
              child: ShimmerListPengajuan(),
            );
          }

          // Filter pengajuan yang perlu diverifikasi
          final daftarPending = provider.daftarPengajuan
              .where((p) => p.statusPengajuan == StatusPengajuan.diajukan)
              .toList();

          if (daftarPending.isEmpty) {
            return const EmptyState(
              icon: Icons.verified,
              judul: 'Tidak Ada Pengajuan',
              deskripsi:
                  'Tidak ada pengajuan yang perlu diverifikasi saat ini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
            itemCount: daftarPending.length,
            itemBuilder: (context, index) {
              final pengajuan = daftarPending[index];
              return _buildVerifikasiCard(pengajuan);
            },
          );
        },
      ),
    );
  }

  Widget _buildVerifikasiCard(Pengajuan pengajuan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: WarnaAplikasi.primary.withAlpha(26),
                  child: Text(
                    (pengajuan.namaMahasiswa ?? pengajuan.namaSiswa ?? 'P')[0]
                        .toUpperCase(),
                    style: const TextStyle(
                      color: WarnaAplikasi.primary,
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
                        pengajuan.namaMahasiswa ??
                            pengajuan.namaSiswa ??
                            'Nama Peserta',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        pengajuan.jenisPengajuan.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WarnaAplikasi.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.warning.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Pending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: WarnaAplikasi.warning,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Info
            _buildInfoRow(
                Icons.business_outlined, pengajuan.namaInstansi ?? '-'),
            _buildInfoRow(Icons.work_outline, pengajuan.posisi ?? '-'),
            _buildInfoRow(
                Icons.schedule_outlined, '${pengajuan.durasiBulan} Bulan'),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(pengajuan),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WarnaAplikasi.error,
                      side: const BorderSide(color: WarnaAplikasi.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(pengajuan),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: WarnaAplikasi.textLight),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(Pengajuan pengajuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Pengajuan'),
        content: Text(
            'Apakah Anda yakin ingin menyetujui pengajuan dari ${pengajuan.namaMahasiswa ?? pengajuan.namaSiswa}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<PengajuanProvider>();
              Navigator.pop(context);
              await provider.verifikasiPengajuan(
                pengajuan.idPengajuan,
                disetujui: true,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengajuan berhasil disetujui'),
                    backgroundColor: WarnaAplikasi.success,
                  ),
                );
              }
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Pengajuan pengajuan) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pengajuan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Berikan alasan penolakan untuk ${pengajuan.namaMahasiswa ?? pengajuan.namaSiswa}:'),
            const SizedBox(height: 16),
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<PengajuanProvider>();
              Navigator.pop(context);
              await provider.verifikasiPengajuan(
                pengajuan.idPengajuan,
                disetujui: false,
                catatan: catatanController.text,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengajuan telah ditolak'),
                    backgroundColor: WarnaAplikasi.error,
                  ),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: WarnaAplikasi.error),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}
