import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/pengajuan.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../komponen/shimmer_loading.dart';
import '../../komponen/empty_state.dart';
import 'pengajuan_form_halaman.dart';
import 'pengajuan_detail_halaman.dart';

/// Halaman daftar pengajuan - UI/UX Upgraded
class PengajuanListHalaman extends StatefulWidget {
  final bool isMagang;
  final bool isAdmin;

  const PengajuanListHalaman({
    super.key,
    this.isMagang = true,
    this.isAdmin = false,
  });

  @override
  State<PengajuanListHalaman> createState() => _PengajuanListHalamanState();
}

class _PengajuanListHalamanState extends State<PengajuanListHalaman> {
  final RefreshController _refreshController = RefreshController();
  StatusPengajuan? _filterStatus;

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WarnaAplikasi.primary,
        title: Text(widget.isAdmin
            ? 'Verifikasi Pengajuan'
            : 'Pengajuan ${widget.isMagang ? "Magang" : "PKL"}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Consumer<PengajuanProvider>(
                    builder: (context, provider, _) {
                      final total = provider.daftarPengajuan.length;
                      final pending = provider.daftarPengajuan
                          .where((p) =>
                              p.statusPengajuan == StatusPengajuan.diajukan)
                          .length;
                      return Row(
                        children: [
                          _buildStatBadge('$total', 'Total'),
                          const SizedBox(width: 12),
                          _buildStatBadge('$pending', 'Pending',
                              isWarning: true),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PopupMenuButton<StatusPengajuan?>(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onSelected: (status) {
                      setState(() => _filterStatus = status);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: null,
                        child: Text('Semua Status'),
                      ),
                      ...StatusPengajuan.values.map((status) => PopupMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(status.label),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<PengajuanProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.daftarPengajuan.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(UkuranAplikasi.paddingSedang),
              child: ShimmerListPengajuan(),
            );
          }

          List<Pengajuan> daftar = provider.daftarPengajuan;

          if (!widget.isAdmin) {
            daftar = daftar
                .where((p) => widget.isMagang ? p.isMagang : p.isPKL)
                .toList();
          }

          if (_filterStatus != null) {
            daftar = daftar
                .where((p) => p.statusPengajuan == _filterStatus)
                .toList();
          }

          if (daftar.isEmpty) {
            if (widget.isAdmin) {
              return const EmptyState(
                icon: Icons.check_circle_outline,
                judul: 'Tidak Ada Pengajuan',
                deskripsi: 'Belum ada pengajuan yang perlu diverifikasi.',
              );
            }
            return EmptyState.pengajuan(
              tombolTeks: 'Buat Pengajuan',
              onTombolPressed: () => _navigateToForm(),
            );
          }

          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                return _buildModernPengajuanCard(daftar[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: widget.isAdmin
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _navigateToForm(),
              backgroundColor: WarnaAplikasi.primary,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text('Buat Pengajuan'),
            ),
    );
  }

  Widget _buildStatBadge(String value, String label, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isWarning ? Colors.amber.withAlpha(40) : Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: isWarning ? Colors.amber[100] : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isWarning ? Colors.amber[100] : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPengajuanCard(Pengajuan pengajuan) {
    final statusColor = _getStatusColor(pengajuan.statusPengajuan);

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
          onTap: () => _navigateToDetail(pengajuan),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: WarnaAplikasi.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        pengajuan.isMagang ? Icons.work : Icons.business_center,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pengajuan.namaInstansi ?? 'Instansi',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            pengajuan.posisi ?? '-',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: WarnaAplikasi.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pengajuan.statusPengajuan.label,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Details
                Row(
                  children: [
                    _buildDetailItem(Icons.calendar_today_outlined,
                        _formatDate(pengajuan.tanggalMulai)),
                    const SizedBox(width: 20),
                    _buildDetailItem(
                        Icons.badge_outlined, pengajuan.jenisPengajuan.label),
                  ],
                ),
                if (widget.isAdmin && pengajuan.namaMahasiswa != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailItem(Icons.person_outline,
                      pengajuan.namaMahasiswa ?? pengajuan.namaSiswa ?? '-'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: WarnaAplikasi.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WarnaAplikasi.textSecondary,
              ),
        ),
      ],
    );
  }

  Color _getStatusColor(StatusPengajuan status) {
    switch (status) {
      case StatusPengajuan.disetujui:
        return WarnaAplikasi.success;
      case StatusPengajuan.ditolak:
        return WarnaAplikasi.error;
      case StatusPengajuan.selesai:
        return WarnaAplikasi.info;
      default:
        return WarnaAplikasi.warning;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PengajuanFormHalaman(isMagang: widget.isMagang),
      ),
    ).then((_) {
      if (mounted) {
        context.read<PengajuanProvider>().ambilPengajuan();
      }
    });
  }

  void _navigateToDetail(Pengajuan pengajuan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PengajuanDetailHalaman(
          pengajuan: pengajuan,
        ),
      ),
    ).then((_) {
      if (mounted) {
        context.read<PengajuanProvider>().ambilPengajuan();
      }
    });
  }
}
