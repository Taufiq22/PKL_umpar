/// Layanan Ekspor
/// UMPAR Magang & PKL System
///
/// Service untuk ekspor data ke PDF dan Excel

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Abstract class untuk format ekspor
abstract class FormatEkspor {
  Future<File> generateFile(String namaFile, Map<String, dynamic> data);
}

/// Service untuk ekspor data
class LayananEkspor {
  /// Ekspor data ke format CSV (alternatif Excel yang sederhana)
  static Future<File?> eksporKeCSV({
    required String namaFile,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    try {
      // Build CSV content
      final StringBuffer buffer = StringBuffer();

      // Add headers
      buffer.writeln(headers.join(','));

      // Add rows
      for (final row in rows) {
        final sanitizedRow = row.map((cell) {
          final str = cell?.toString() ?? '';
          // Escape commas and quotes
          if (str.contains(',') || str.contains('"')) {
            return '"${str.replaceAll('"', '""')}"';
          }
          return str;
        });
        buffer.writeln(sanitizedRow.join(','));
      }

      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$namaFile.csv';
      final file = File(path);

      // Write file
      await file.writeAsString(buffer.toString());

      return file;
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
      return null;
    }
  }

  /// Ekspor kehadiran ke CSV
  static Future<File?> eksporKehadiran({
    required List<Map<String, dynamic>> dataKehadiran,
    required String namaFile,
  }) async {
    final headers = [
      'Tanggal',
      'Status',
      'Jam Masuk',
      'Jam Keluar',
      'Durasi',
      'Keterangan',
    ];

    final rows = dataKehadiran.map((k) {
      return [
        k['tanggal'] ?? '-',
        k['status_kehadiran'] ?? '-',
        k['jam_masuk'] ?? '-',
        k['jam_keluar'] ?? '-',
        k['durasi'] ?? '-',
        k['keterangan'] ?? '-',
      ];
    }).toList();

    return await eksporKeCSV(
      namaFile: namaFile,
      headers: headers,
      rows: rows,
    );
  }

  /// Ekspor pengajuan ke CSV
  static Future<File?> eksporPengajuan({
    required List<Map<String, dynamic>> dataPengajuan,
    required String namaFile,
  }) async {
    final headers = [
      'ID',
      'Nama',
      'NIM/NISN',
      'Instansi',
      'Posisi',
      'Tanggal Mulai',
      'Tanggal Selesai',
      'Status',
    ];

    final rows = dataPengajuan.map((p) {
      return [
        p['id_pengajuan']?.toString() ?? '-',
        p['nama_mahasiswa'] ?? p['nama_siswa'] ?? '-',
        p['nim'] ?? p['nisn'] ?? '-',
        p['nama_instansi'] ?? '-',
        p['posisi'] ?? '-',
        p['tanggal_mulai'] ?? '-',
        p['tanggal_selesai'] ?? '-',
        p['status_pengajuan'] ?? '-',
      ];
    }).toList();

    return await eksporKeCSV(
      namaFile: namaFile,
      headers: headers,
      rows: rows,
    );
  }

  /// Ekspor laporan ke CSV
  static Future<File?> eksporLaporan({
    required List<Map<String, dynamic>> dataLaporan,
    required String namaFile,
  }) async {
    final headers = [
      'Judul',
      'Jenis',
      'Tanggal',
      'Status',
      'Catatan Pembimbing',
    ];

    final rows = dataLaporan.map((l) {
      return [
        l['judul_laporan'] ?? '-',
        l['jenis_laporan'] ?? '-',
        l['tanggal_pengumpulan'] ?? '-',
        l['status_laporan'] ?? '-',
        l['catatan_pembimbing'] ?? '-',
      ];
    }).toList();

    return await eksporKeCSV(
      namaFile: namaFile,
      headers: headers,
      rows: rows,
    );
  }

  /// Share exported file
  static Future<void> bagikanFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Data Export',
    );
  }

  /// Show export dialog
  static void tampilkanDialogEkspor(
    BuildContext context, {
    required String judul,
    required VoidCallback onEksporCSV,
    VoidCallback? onEksporPDF,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.table_chart, color: Colors.green),
                ),
                title: const Text('Ekspor ke CSV'),
                subtitle: const Text('Format spreadsheet sederhana'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  onEksporCSV();
                },
              ),
              if (onEksporPDF != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  title: const Text('Ekspor ke PDF'),
                  subtitle: const Text('Format dokumen portabel'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    onEksporPDF();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// Widget tombol ekspor
class TombolEkspor extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData ikon;

  const TombolEkspor({
    super.key,
    this.label = 'Ekspor',
    required this.onPressed,
    this.ikon = Icons.file_download,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(ikon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
