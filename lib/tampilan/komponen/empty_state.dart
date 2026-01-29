import 'package:flutter/material.dart';
import '../../konfigurasi/konstanta.dart';

/// Komponen Empty State untuk tampilan kosong
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String judul;
  final String deskripsi;
  final String? tombolTeks;
  final VoidCallback? onTombolPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.judul,
    required this.deskripsi,
    this.tombolTeks,
    this.onTombolPressed,
  });

  /// Empty state untuk pengajuan kosong
  const EmptyState.pengajuan({super.key, this.tombolTeks, this.onTombolPressed})
      : icon = Icons.description_outlined,
        judul = 'Belum Ada Pengajuan',
        deskripsi =
            'Anda belum memiliki pengajuan magang/PKL. Buat pengajuan baru untuk memulai.';

  /// Empty state untuk laporan kosong
  const EmptyState.laporan({super.key, this.tombolTeks, this.onTombolPressed})
      : icon = Icons.article_outlined,
        judul = 'Belum Ada Laporan',
        deskripsi =
            'Belum ada laporan yang dikirim. Mulai buat laporan harian Anda.';

  /// Empty state untuk nilai kosong
  const EmptyState.nilai({super.key})
      : icon = Icons.grade_outlined,
        judul = 'Belum Ada Nilai',
        deskripsi =
            'Nilai Anda akan muncul setelah pembimbing memberikan penilaian.',
        tombolTeks = null,
        onTombolPressed = null;

  /// Empty state untuk notifikasi kosong
  const EmptyState.notifikasi({super.key})
      : icon = Icons.notifications_none,
        judul = 'Tidak Ada Notifikasi',
        deskripsi = 'Anda tidak memiliki notifikasi baru saat ini.',
        tombolTeks = null,
        onTombolPressed = null;

  /// Empty state untuk data tidak ditemukan
  const EmptyState.tidakDitemukan(
      {super.key, this.tombolTeks, this.onTombolPressed})
      : icon = Icons.search_off,
        judul = 'Data Tidak Ditemukan',
        deskripsi = 'Tidak ada data yang sesuai dengan pencarian Anda.';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UkuranAplikasi.paddingBesar),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: WarnaAplikasi.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: WarnaAplikasi.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              judul,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              deskripsi,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WarnaAplikasi.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (tombolTeks != null && onTombolPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onTombolPressed,
                icon: const Icon(Icons.add),
                label: Text(tombolTeks!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
