import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/pengajuan.dart';
import '../../../provider/pengajuan_provider.dart';
import '../nilai/nilai_input_halaman.dart';
import '../../komponen/empty_state.dart';

/// Halaman penilaian untuk dosen/guru/instansi
/// Ini menampilkan daftar peserta yang bisa dinilai
class PenilaianListHalaman extends StatefulWidget {
  final String jenisPenilai; // 'Dosen', 'Guru', 'Instansi'

  const PenilaianListHalaman({super.key, required this.jenisPenilai});

  @override
  State<PenilaianListHalaman> createState() => _PenilaianListHalamanState();
}

class _PenilaianListHalamanState extends State<PenilaianListHalaman> {
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
        title: const Text('Penilaian'),
      ),
      body: Consumer<PengajuanProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter pengajuan yang disetujui
          final daftarDisetujui = provider.daftarPengajuan
              .where((p) =>
                  p.statusPengajuan == StatusPengajuan.disetujui ||
                  p.statusPengajuan == StatusPengajuan.selesai)
              .toList();

          if (daftarDisetujui.isEmpty) {
            return const EmptyState(
              icon: Icons.grade_outlined,
              judul: 'Tidak Ada Peserta',
              deskripsi: 'Tidak ada peserta yang perlu dinilai saat ini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
            itemCount: daftarDisetujui.length,
            itemBuilder: (context, index) {
              final pengajuan = daftarDisetujui[index];
              return _buildPenilaianCard(pengajuan);
            },
          );
        },
      ),
    );
  }

  Widget _buildPenilaianCard(Pengajuan pengajuan) {
    final nama = pengajuan.namaMahasiswa ?? pengajuan.namaSiswa ?? 'Peserta';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to NilaiInputHalaman
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
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: WarnaAplikasi.primary.withAlpha(26),
                child: Text(
                  nama[0].toUpperCase(),
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
                      nama,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${pengajuan.posisi ?? pengajuan.jenisPengajuan.label} • ${pengajuan.namaInstansi ?? "-"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: WarnaAplikasi.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.warning.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 14, color: WarnaAplikasi.warning),
                    SizedBox(width: 4),
                    Text(
                      'Nilai',
                      style: TextStyle(
                        color: WarnaAplikasi.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
