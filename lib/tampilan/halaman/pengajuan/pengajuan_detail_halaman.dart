import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/pengajuan.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/pengajuan_provider.dart';

import '../../../konfigurasi/rute.dart';

/// Halaman detail pengajuan
class PengajuanDetailHalaman extends StatelessWidget {
  final Pengajuan pengajuan;

  const PengajuanDetailHalaman({super.key, required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isVerifikator = auth.role == RolePengguna.admin ||
        auth.role == RolePengguna.dosen ||
        auth.role == RolePengguna.guru;
    final canVerify =
        isVerifikator && pengajuan.statusPengajuan == StatusPengajuan.diajukan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
        actions: [
          // Tombol cetak surat (untuk verifikator)
          if (isVerifikator)
            PopupMenuButton<String>(
              icon: const Icon(Icons.print),
              tooltip: 'Cetak Surat',
              onSelected: (value) {
                if (value == 'permohonan') {
                  Navigator.pushNamed(
                    context,
                    RuteAplikasi.suratPermohonan,
                    arguments: pengajuan.idPengajuan,
                  );
                } else if (value == 'balasan') {
                  if (pengajuan.isDisetujui) {
                    Navigator.pushNamed(
                      context,
                      RuteAplikasi.suratBalasan,
                      arguments: pengajuan.idPengajuan,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Surat balasan hanya tersedia untuk pengajuan yang disetujui'),
                        backgroundColor: WarnaAplikasi.warning,
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'permohonan',
                  child: Row(
                    children: [
                      Icon(Icons.description_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Surat Permohonan'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'balasan',
                  enabled: pengajuan.isDisetujui,
                  child: const Row(
                    children: [
                      Icon(Icons.reply_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Surat Balasan'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: canVerify ? _buildActionButtons(context) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(UkuranAplikasi.paddingBesar),
              decoration: const BoxDecoration(
                gradient: WarnaAplikasi.primaryGradient,
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pengajuan.statusPengajuan.label.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    _getStatusIcon(),
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusMessage(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Instansi
                  _buildSection(
                    context,
                    icon: Icons.business_outlined,
                    title: 'Informasi Instansi',
                    children: [
                      _buildInfoRow(context, 'Nama Instansi',
                          pengajuan.namaInstansi ?? '-'),
                      _buildInfoRow(context, 'Posisi', pengajuan.posisi ?? '-'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info Waktu
                  _buildSection(
                    context,
                    icon: Icons.schedule_outlined,
                    title: 'Waktu Pelaksanaan',
                    children: [
                      _buildInfoRow(
                          context, 'Jenis', pengajuan.jenisPengajuan.label),
                      _buildInfoRow(
                          context, 'Durasi', '${pengajuan.durasiBulan} Bulan'),
                      _buildInfoRow(context, 'Tanggal Mulai',
                          _formatDate(pengajuan.tanggalMulai)),
                      _buildInfoRow(context, 'Tanggal Selesai',
                          _formatDate(pengajuan.tanggalSelesai)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pembimbing
                  if (pengajuan.isDisetujui) ...[
                    _buildSection(
                      context,
                      icon: Icons.person_outline,
                      title: 'Pembimbing',
                      children: [
                        _buildInfoRow(
                          context,
                          pengajuan.isMagang
                              ? 'Dosen Pembimbing'
                              : 'Guru Pembimbing',
                          pengajuan.namaDosenPembimbing ??
                              pengajuan.namaGuruPembimbing ??
                              'Belum ditentukan',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Keterangan
                  if (pengajuan.keterangan != null &&
                      pengajuan.keterangan!.isNotEmpty) ...[
                    _buildSection(
                      context,
                      icon: Icons.notes_outlined,
                      title: 'Keterangan',
                      children: [
                        Text(
                          pengajuan.keterangan!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Surat Balasan
                  if (pengajuan.suratBalasan != null) ...[
                    _buildSection(
                      context,
                      icon: Icons.description_outlined,
                      title: 'Surat Balasan',
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _downloadSuratBalasan(context),
                          icon: const Icon(Icons.download),
                          label: const Text('Download Surat Balasan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tanggal Pengajuan
                  Text(
                    'Diajukan pada ${_formatDate(pengajuan.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: WarnaAplikasi.textLight,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: WarnaAplikasi.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WarnaAplikasi.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (pengajuan.statusPengajuan) {
      case StatusPengajuan.diajukan:
        return Icons.hourglass_empty;
      case StatusPengajuan.disetujui:
        return Icons.check_circle;
      case StatusPengajuan.ditolak:
        return Icons.cancel;
      case StatusPengajuan.selesai:
        return Icons.verified;
    }
  }

  String _getStatusMessage() {
    switch (pengajuan.statusPengajuan) {
      case StatusPengajuan.diajukan:
        return 'Pengajuan Anda sedang diproses.\nMohon tunggu konfirmasi dari pembimbing.';
      case StatusPengajuan.disetujui:
        return 'Selamat! Pengajuan Anda telah disetujui.\nAnda bisa mulai mengikuti kegiatan.';
      case StatusPengajuan.ditolak:
        return 'Maaf, pengajuan Anda ditolak.\nSilakan ajukan ulang dengan memperbaiki data.';
      case StatusPengajuan.selesai:
        return 'Kegiatan telah selesai.\nTerima kasih atas partisipasi Anda.';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  void _downloadSuratBalasan(BuildContext context) {
    final fileUrl = '${ApiKonstanta.baseUrl}/uploads/${pengajuan.suratBalasan}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description, color: WarnaAplikasi.primary),
            SizedBox(width: 8),
            Text('Surat Balasan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File surat balasan tersedia:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WarnaAplikasi.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.file_present, color: WarnaAplikasi.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pengajuan.suratBalasan!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'URL: $fileUrl',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WarnaAplikasi.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buka link di browser untuk mengunduh file.',
              style: TextStyle(fontSize: 12, color: WarnaAplikasi.textLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Copy URL to clipboard
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Silakan buka link di browser untuk download'),
                  backgroundColor: WarnaAplikasi.info,
                ),
              );
            },
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('Buka'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showVerifikasiDialog(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: WarnaAplikasi.error,
                side: const BorderSide(color: WarnaAplikasi.error),
              ),
              child: const Text('Tolak'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showVerifikasiDialog(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: WarnaAplikasi.success,
              ),
              child: const Text('Setujui'),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerifikasiDialog(BuildContext context, bool setujui) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(setujui ? 'Setujui Pengajuan?' : 'Tolak Pengajuan?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(setujui
                    ? 'Anda yakin ingin menyetujui pengajuan ini?'
                    : 'Anda yakin ingin menolak pengajuan ini?'),
                const SizedBox(height: 16),
                TextField(
                  controller: catatanController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog

                final provider = context.read<PengajuanProvider>();
                bool success;

                if (pengajuan.isMagang) {
                  // Magang -> Approve by Fakultas
                  success = await provider.approveByFakultas(
                    pengajuan.idPengajuan,
                    approved: setujui,
                    catatan: catatanController.text.trim(),
                  );
                } else {
                  // PKL -> Approve by Sekolah
                  success = await provider.approveBySekolah(
                    pengajuan.idPengajuan,
                    approved: setujui,
                    catatan: catatanController.text.trim(),
                  );
                }

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(setujui
                          ? 'Pengajuan disetujui (Admin Verified)'
                          : 'Pengajuan ditolak'),
                      backgroundColor:
                          setujui ? WarnaAplikasi.success : WarnaAplikasi.error,
                    ),
                  );
                  Navigator.pop(context); // Kembali ke list
                } else if (context.mounted && provider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error!),
                      backgroundColor: WarnaAplikasi.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    setujui ? WarnaAplikasi.success : WarnaAplikasi.error,
              ),
              child: Text(setujui ? 'Setujui' : 'Tolak'),
            ),
          ],
        ),
      ),
    );
  }
}
