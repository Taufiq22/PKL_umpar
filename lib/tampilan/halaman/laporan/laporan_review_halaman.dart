import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/laporan.dart';
import '../../../provider/laporan_provider.dart';

/// Halaman Review Laporan
/// Digunakan oleh Dosen Pembimbing dan Guru Pembimbing
class LaporanReviewHalaman extends StatefulWidget {
  final int? idPengajuan;

  const LaporanReviewHalaman({super.key, this.idPengajuan});

  @override
  State<LaporanReviewHalaman> createState() => _LaporanReviewHalamanState();
}

class _LaporanReviewHalamanState extends State<LaporanReviewHalaman>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context
        .read<LaporanProvider>()
        .ambilLaporan(idPengajuan: widget.idPengajuan);
  }

  List<Laporan> _getFilteredList(List<Laporan> list, JenisLaporan jenis) {
    var filtered = list.where((l) => l.jenisLaporan == jenis).toList();

    if (_filterStatus != 'Semua') {
      filtered =
          filtered.where((l) => l.status.label == _filterStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Laporan'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Harian'),
            Tab(text: 'Monitoring'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Semua', child: Text('Semua')),
              const PopupMenuItem(value: 'Pending', child: Text('Pending')),
              const PopupMenuItem(value: 'Disetujui', child: Text('Disetujui')),
              const PopupMenuItem(value: 'Ditolak', child: Text('Ditolak')),
              const PopupMenuItem(
                  value: 'Perlu Perbaikan', child: Text('Perlu Perbaikan')),
            ],
          ),
        ],
      ),
      body: Consumer<LaporanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildLaporanList(_getFilteredList(
                  provider.daftarLaporan, JenisLaporan.harian)),
              _buildLaporanList(_getFilteredList(
                  provider.daftarLaporan, JenisLaporan.monitoring)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLaporanList(List<Laporan> laporanList) {
    if (laporanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined,
                size: 64, color: WarnaAplikasi.textLight),
            const SizedBox(height: 16),
            Text(
              'Tidak ada laporan',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: WarnaAplikasi.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
        itemCount: laporanList.length,
        itemBuilder: (context, index) {
          return _buildLaporanCard(laporanList[index]);
        },
      ),
    );
  }

  Widget _buildLaporanCard(Laporan laporan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
      ),
      child: InkWell(
        onTap: () => _showReviewDialog(laporan),
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildStatusChip(laporan.status),
                  const Spacer(),
                  Text(
                    _formatDate(laporan.tanggal),
                    style: TextStyle(
                      color: WarnaAplikasi.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Kegiatan
              Text(
                laporan.kegiatan,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // File attachment indicator
              if (laporan.fileLaporan != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_file,
                        size: 16, color: WarnaAplikasi.primary),
                    const SizedBox(width: 4),
                    Text(
                      'File terlampir',
                      style: TextStyle(
                        color: WarnaAplikasi.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],

              // Komentar pembimbing
              if (laporan.komentarPembimbing?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.comment,
                          size: 16, color: WarnaAplikasi.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          laporan.komentarPembimbing!,
                          style: TextStyle(
                            fontSize: 12,
                            color: WarnaAplikasi.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons for pending
              if (laporan.isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(laporan),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Revisi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: WarnaAplikasi.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _review(laporan, 'Disetujui'),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Setujui'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(StatusLaporan status) {
    Color color;
    switch (status) {
      case StatusLaporan.disetujui:
      case StatusLaporan.sesuai:
      case StatusLaporan.selesai:
        color = WarnaAplikasi.success;
        break;
      case StatusLaporan.ditolak:
        color = WarnaAplikasi.error;
        break;
      case StatusLaporan.perluPerbaikan:
      case StatusLaporan.revisi:
        color = WarnaAplikasi.warning;
        break;
      default:
        color = WarnaAplikasi.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReviewDialog(Laporan laporan) {
    final komentarController =
        TextEditingController(text: laporan.komentarPembimbing);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: UkuranAplikasi.paddingBesar,
          right: UkuranAplikasi.paddingBesar,
          top: UkuranAplikasi.paddingBesar,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              UkuranAplikasi.paddingBesar,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: WarnaAplikasi.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Review Laporan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(laporan.tanggal),
              style: TextStyle(color: WarnaAplikasi.textSecondary),
            ),
            const SizedBox(height: 16),

            // Kegiatan
            Text(
              'Kegiatan:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WarnaAplikasi.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(laporan.kegiatan),
            ),
            const SizedBox(height: 16),

            // Komentar
            Text(
              'Komentar/Feedback:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: komentarController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Berikan feedback untuk mahasiswa/siswa...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _review(laporan, 'Perlu Perbaikan',
                          komentar: komentarController.text);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WarnaAplikasi.warning,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Perlu Revisi'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _review(laporan, 'Disetujui',
                          komentar: komentarController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Setujui'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(Laporan laporan) {
    final komentarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minta Revisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berikan catatan untuk perbaikan:'),
            const SizedBox(height: 12),
            TextField(
              controller: komentarController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Catatan perbaikan...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _review(laporan, 'Perlu Perbaikan',
                  komentar: komentarController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.warning,
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  Future<void> _review(Laporan laporan, String status,
      {String? komentar}) async {
    final provider = context.read<LaporanProvider>();
    final success = await provider.reviewLaporan(
      laporan.idLaporan,
      status: status,
      komentar: komentar,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Laporan berhasil di-review' : 'Gagal review laporan'),
          backgroundColor:
              success ? WarnaAplikasi.success : WarnaAplikasi.error,
        ),
      );
    }
  }
}
