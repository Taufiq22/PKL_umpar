import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/laporan.dart';
import '../../../provider/laporan_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../komponen/shimmer_loading.dart';
import '../../komponen/empty_state.dart';
import 'laporan_form_halaman.dart';

/// Halaman daftar laporan - Simplified Layout
class LaporanListHalaman extends StatefulWidget {
  final int? idPengajuan;
  final int initialIndex;

  const LaporanListHalaman({
    super.key,
    this.idPengajuan,
    this.initialIndex = 0,
  });

  @override
  State<LaporanListHalaman> createState() => _LaporanListHalamanState();
}

class _LaporanListHalamanState extends State<LaporanListHalaman>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final RefreshController _harianRefreshController = RefreshController();
  final RefreshController _monitoringRefreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    // Limit initialIndex to valid range (0 or 1 for 2 tabs)
    final safeInitialIndex = widget.initialIndex.clamp(0, 1);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: safeInitialIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<LaporanProvider>()
          .ambilLaporan(idPengajuan: widget.idPengajuan);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _harianRefreshController.dispose();
    _monitoringRefreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(RefreshController controller) async {
    await context
        .read<LaporanProvider>()
        .ambilLaporan(idPengajuan: widget.idPengajuan);
    controller.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Gradient Header
          Container(
            decoration: const BoxDecoration(
              gradient: WarnaAplikasi.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (Navigator.canPop(context))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Kembali',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Consumer<LaporanProvider>(
                    builder: (context, provider, _) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeaderStat(
                              '${provider.laporanHarian.length}',
                              'Harian',
                              Icons.today,
                            ),
                            _buildHeaderStat(
                              '${provider.laporanMonitoring.length}',
                              'Monitoring',
                              Icons.visibility,
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
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: WarnaAplikasi.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: WarnaAplikasi.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Harian'),
                Tab(text: 'Monitoring'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLaporanList(
                    JenisLaporan.harian, _harianRefreshController),
                _buildLaporanList(
                    JenisLaporan.monitoring, _monitoringRefreshController),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget? _buildFloatingButton() {
    final auth = context.watch<AuthProvider>();

    // Only mahasiswa/siswa can create reports
    final userRole = auth.pengguna?.role;
    if (userRole != RolePengguna.mahasiswa && userRole != RolePengguna.siswa) {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: () => _navigateToForm(),
      backgroundColor: WarnaAplikasi.primary,
      elevation: 4,
      icon: const Icon(Icons.add),
      label: const Text('Buat Laporan'),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
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

  Widget _buildLaporanList(JenisLaporan jenis, RefreshController controller) {
    return Consumer<LaporanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.daftarLaporan.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(UkuranAplikasi.paddingSedang),
            child: ShimmerListPengajuan(itemCount: 5),
          );
        }

        final daftar = provider.daftarLaporan
            .where((l) => l.jenisLaporan == jenis)
            .toList();

        if (daftar.isEmpty) {
          final auth = context.read<AuthProvider>();
          final role = auth.pengguna?.role;
          final isStudent =
              role == RolePengguna.mahasiswa || role == RolePengguna.siswa;

          return EmptyState.laporan(
            tombolTeks: isStudent ? 'Buat Laporan ${jenis.label}' : null,
            onTombolPressed:
                isStudent ? () => _navigateToForm(jenis: jenis) : null,
          );
        }

        return SmartRefresher(
          controller: controller,
          onRefresh: () => _onRefresh(controller),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              return _buildModernLaporanCard(daftar[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildModernLaporanCard(Laporan laporan) {
    Color statusColor;
    IconData statusIcon;

    switch (laporan.status) {
      case StatusLaporan.disetujui:
        statusColor = WarnaAplikasi.success;
        statusIcon = Icons.check_circle;
        break;
      case StatusLaporan.ditolak:
        statusColor = WarnaAplikasi.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = WarnaAplikasi.warning;
        statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLaporanDetail(laporan),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: WarnaAplikasi.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${laporan.tanggal.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getMonthShort(laporan.tanggal.month),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            laporan.status.label,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        laporan.kegiatan,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }

  void _navigateToForm({JenisLaporan? jenis}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaporanFormHalaman(
          idPengajuan: widget.idPengajuan,
          jenisLaporan: jenis,
        ),
      ),
    ).then((_) {
      if (mounted) {
        context
            .read<LaporanProvider>()
            .ambilLaporan(idPengajuan: widget.idPengajuan);
      }
    });
  }

  void _showLaporanDetail(Laporan laporan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: WarnaAplikasi.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.description,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(laporan.tanggal),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildChip(laporan.jenisLaporan.label,
                                    WarnaAplikasi.primary),
                                const SizedBox(width: 8),
                                _buildChip(
                                  laporan.status.label,
                                  laporan.isApproved
                                      ? WarnaAplikasi.success
                                      : WarnaAplikasi.warning,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Kegiatan
                  Text(
                    'Kegiatan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(laporan.kegiatan),
                  ),

                  // Komentar
                  if (laporan.komentarPembimbing != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Komentar Pembimbing',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.info.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.chat_bubble_outline,
                              color: WarnaAplikasi.info, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              laporan.komentarPembimbing!,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
