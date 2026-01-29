import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../provider/cetak_provider.dart';
import '../../../../konfigurasi/konstanta.dart';
import '../../../komponen/loading_overlay.dart';

class CetakHalaman extends StatefulWidget {
  const CetakHalaman({super.key});

  @override
  State<CetakHalaman> createState() => _CetakHalamanState();
}

class _CetakHalamanState extends State<CetakHalaman> {
  Future<void> _cetakRekapMahasiswa() async {
    final provider = context.read<CetakProvider>();
    final data = await provider.getRekapMahasiswa();

    if (data.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak ada data mahasiswa untuk dicetak')),
        );
      }
      return;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
                level: 0,
                child: pw.Column(children: [
                  pw.Text('REKAPITULASI DATA MAHASISWA MAGANG',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('UNIVERSITAS MUHAMMADIYAH PAREPARE',
                      style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 20),
                ])),
            pw.TableHelper.fromTextArray(
              headers: ['No', 'NIM', 'Nama Lengkap', 'Prodi', 'Status'],
              data: List<List<dynamic>>.generate(
                data.length,
                (index) {
                  final item = data[index];
                  return [
                    (index + 1).toString(),
                    item['nim'] ?? '-',
                    item['nama_lengkap'] ?? '-',
                    item['prodi'] ?? '-',
                    item['status_magang'] ?? 'Belum Magang',
                  ];
                },
              ),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<void> _cetakRekapNilai() async {
    final provider = context.read<CetakProvider>();
    final data = await provider.getRekapNilai();

    if (data.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data nilai untuk dicetak')),
        );
      }
      return;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape, // Fixed usage
        build: (pw.Context context) {
          return [
            pw.Header(
                level: 0,
                child: pw.Column(children: [
                  pw.Text('REKAPITULASI NILAI AKHIR',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('MAGANG & PKL - UMPAR',
                      style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 20),
                ])),
            pw.TableHelper.fromTextArray(
              // Fixed deprecated usage
              headers: [
                'No',
                'Nama Peserta',
                'Instansi',
                'Jenis',
                'Nilai Akhir'
              ],
              data: List<List<dynamic>>.generate(
                data.length,
                (index) {
                  final item = data[index];
                  return [
                    (index + 1).toString(),
                    item['nama_peserta'] ?? '-',
                    item['nama_instansi'] ?? '-',
                    item['jenis_pengajuan'] ?? '-',
                    item['nilai_akhir']?.toString() ?? '-',
                  ];
                },
              ),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CetakProvider>();
    // final provider = Provider.of<CetakProvider>(context); // Alternative

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cetak Dokumen'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
          children: [
            _buildCetakCard(
              title: 'Rekap Data Mahasiswa',
              description:
                  'Unduh daftar seluruh mahasiswa beserta status magang.',
              icon: Icons.people_alt,
              color: Colors.blue,
              onTap: _cetakRekapMahasiswa,
            ),
            const SizedBox(height: 16),
            _buildCetakCard(
              title: 'Rekap Nilai Akhir',
              description: 'Unduh rekapitulasi nilai akhir peserta magang/PKL.',
              icon: Icons.grade,
              color: Colors.orange,
              onTap: _cetakRekapNilai,
            ),
            // Add more options if needed
          ],
        ),
      ),
    );
  }

  Widget _buildCetakCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.print, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
