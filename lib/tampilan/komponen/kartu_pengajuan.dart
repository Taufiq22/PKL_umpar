import 'package:flutter/material.dart';
import '../../konfigurasi/konstanta.dart';
import '../../data/model/pengajuan.dart';

/// Kartu pengajuan untuk ditampilkan di list
class KartuPengajuan extends StatelessWidget {
  final Pengajuan pengajuan;
  final bool showNamaPengaju;
  final VoidCallback? onTap;

  const KartuPengajuan({
    super.key,
    required this.pengajuan,
    this.showNamaPengaju = false,
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
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pengajuan.statusPengajuan.warna.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  pengajuan.isMagang
                      ? Icons.work_outline
                      : Icons.school_outlined,
                  color: pengajuan.statusPengajuan.warna,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showNamaPengaju) ...[
                      Text(
                        pengajuan.namaMahasiswa ??
                            pengajuan.namaSiswa ??
                            'Nama Pengaju Tidak Diketahui',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pengajuan.namaInstansi ?? '-'} • ${pengajuan.posisi ?? pengajuan.jenisPengajuan.label}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WarnaAplikasi.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      Text(
                        pengajuan.namaInstansi ?? 'Instansi',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pengajuan.posisi ?? pengajuan.jenisPengajuan.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WarnaAplikasi.textSecondary,
                            ),
                      ),
                    ],
                    if (pengajuan.tanggalMulai != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: WarnaAplikasi.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTanggal(pengajuan.tanggalMulai!),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: WarnaAplikasi.textLight,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: pengajuan.statusPengajuan.warna.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pengajuan.statusPengajuan.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: pengajuan.statusPengajuan.warna,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTanggal(DateTime tanggal) {
    final months = [
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
    return '${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';
  }
}

/// Kartu status pengajuan untuk dashboard (compact)
class KartuStatusPengajuan extends StatelessWidget {
  final Pengajuan pengajuan;
  final VoidCallback? onTap;

  const KartuStatusPengajuan({
    super.key,
    required this.pengajuan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
        decoration: BoxDecoration(
          gradient: WarnaAplikasi.primaryGradient,
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STATUS ${pengajuan.jenisPengajuan.label.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pengajuan.statusPengajuan.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pengajuan.namaInstansi ?? 'Nama Instansi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              pengajuan.posisi ?? 'Posisi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
