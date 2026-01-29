import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/notifikasi.dart';
import '../../../provider/notifikasi_provider.dart';
import '../../komponen/empty_state.dart';

/// Halaman notifikasi - UI/UX Upgraded
class NotifikasiListHalaman extends StatefulWidget {
  const NotifikasiListHalaman({super.key});

  @override
  State<NotifikasiListHalaman> createState() => _NotifikasiListHalamanState();
}

class _NotifikasiListHalamanState extends State<NotifikasiListHalaman> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotifikasiProvider>().ambilNotifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: WarnaAplikasi.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Notifikasi',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Consumer<NotifikasiProvider>(
                            builder: (context, provider, _) {
                              if (provider.jumlahBelumDibaca > 0) {
                                return TextButton.icon(
                                  onPressed: () => provider.tandaiSemuaDibaca(),
                                  icon: const Icon(Icons.done_all,
                                      color: Colors.white, size: 18),
                                  label: const Text(
                                    'Baca Semua',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white.withAlpha(30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stats
                      Consumer<NotifikasiProvider>(
                        builder: (context, provider, _) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildHeaderStat(
                                    Icons.notifications,
                                    '${provider.daftarNotifikasi.length}',
                                    'Total',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withAlpha(40),
                                ),
                                Expanded(
                                  child: _buildHeaderStat(
                                    Icons.mark_email_unread,
                                    '${provider.jumlahBelumDibaca}',
                                    'Belum Dibaca',
                                  ),
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
            ),
          ),

          // Content
          Consumer<NotifikasiProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.daftarNotifikasi.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.daftarNotifikasi.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState.notifikasi(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notif = provider.daftarNotifikasi[index];
                      return _buildModernNotifikasiCard(notif);
                    },
                    childCount: provider.daftarNotifikasi.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
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

  Widget _buildModernNotifikasiCard(Notifikasi notif) {
    final tipeColor = _getTipeColor(notif.tipe);

    return Dismissible(
      key: Key('notif-${notif.idNotifikasi}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: WarnaAplikasi.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      onDismissed: (_) {
        context.read<NotifikasiProvider>().hapusNotifikasi(notif.idNotifikasi);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:
              notif.dibaca ? Colors.white : WarnaAplikasi.primary.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.dibaca
                ? Colors.grey.withAlpha(30)
                : WarnaAplikasi.primary.withAlpha(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!notif.dibaca) {
                context
                    .read<NotifikasiProvider>()
                    .tandaiDibaca(notif.idNotifikasi);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tipeColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTipeIcon(notif.tipe),
                      color: tipeColor,
                      size: 22,
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
                            Expanded(
                              child: Text(
                                notif.judul,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: notif.dibaca
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (!notif.dibaca)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: WarnaAplikasi.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notif.pesan,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: WarnaAplikasi.textSecondary,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              notif.createdAt != null
                                  ? _formatWaktu(notif.createdAt!)
                                  : '-',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTipeIcon(TipeNotifikasi tipe) {
    switch (tipe) {
      case TipeNotifikasi.info:
        return Icons.info_outline;
      case TipeNotifikasi.sukses:
        return Icons.check_circle_outline;
      case TipeNotifikasi.peringatan:
        return Icons.warning_amber_outlined;
      case TipeNotifikasi.error:
        return Icons.error_outline;
    }
  }

  Color _getTipeColor(TipeNotifikasi tipe) {
    switch (tipe) {
      case TipeNotifikasi.info:
        return WarnaAplikasi.info;
      case TipeNotifikasi.sukses:
        return WarnaAplikasi.success;
      case TipeNotifikasi.peringatan:
        return WarnaAplikasi.warning;
      case TipeNotifikasi.error:
        return WarnaAplikasi.error;
    }
  }

  String _formatWaktu(DateTime waktu) {
    final now = DateTime.now();
    final diff = now.difference(waktu);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${waktu.day}/${waktu.month}/${waktu.year}';
    }
  }
}
