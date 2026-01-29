import 'package:flutter/material.dart';
import '../../konfigurasi/konstanta.dart';
import '../../data/model/laporan.dart';

/// Kartu laporan untuk ditampilkan di list
class KartuLaporan extends StatelessWidget {
  final Laporan laporan;
  final VoidCallback? onTap;

  const KartuLaporan({
    super.key,
    required this.laporan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor().withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      laporan.tanggal.day.toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                    ),
                    Text(
                      _getShortMonth(laporan.tanggal.month),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getJenisColor().withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            laporan.jenisLaporan.label,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _getJenisColor(),
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            laporan.status.label,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _getStatusColor(),
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      laporan.kegiatan,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (laporan.komentarPembimbing != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.comment_outlined,
                            size: 14,
                            color: WarnaAplikasi.textLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              laporan.komentarPembimbing!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: WarnaAplikasi.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (laporan.status) {
      case StatusLaporan.disetujui:
      case StatusLaporan.sesuai:
      case StatusLaporan.selesai:
        return WarnaAplikasi.success;
      case StatusLaporan.ditolak:
      case StatusLaporan.perluPerbaikan:
      case StatusLaporan.revisi:
        return WarnaAplikasi.error;
      case StatusLaporan.pending:
        return WarnaAplikasi.warning;
    }
  }

  Color _getJenisColor() {
    switch (laporan.jenisLaporan) {
      case JenisLaporan.harian:
        return WarnaAplikasi.primary;
      case JenisLaporan.monitoring:
        return WarnaAplikasi.info;
      case JenisLaporan.bimbingan:
        return WarnaAplikasi.success;
    }
  }

  String _getShortMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }
}
