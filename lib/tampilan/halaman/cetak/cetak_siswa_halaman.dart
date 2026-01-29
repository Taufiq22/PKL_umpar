import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../provider/cetak_provider.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/laporan_provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../komponen/loading_overlay.dart';

/// Halaman Cetak khusus untuk Siswa
class CetakSiswaHalaman extends StatefulWidget {
  const CetakSiswaHalaman({super.key});

  @override
  State<CetakSiswaHalaman> createState() => _CetakSiswaHalamanState();
}

class _CetakSiswaHalamanState extends State<CetakSiswaHalaman> {
  Future<void> _cetakSuratPengantar() async {
    final auth = context.read<AuthProvider>();
    final pengajuan = context.read<PengajuanProvider>().pengajuanAktif;

    if (pengajuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada pengajuan PKL aktif')),
      );
      return;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(children: [
                  pw.Text('SURAT PENGANTAR PKL',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('PRAKTEK KERJA LAPANGAN',
                      style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 30),
                ]),
              ),
              pw.Text('Nama: ${auth.pengguna?.namaLengkap ?? "-"}'),
              pw.SizedBox(height: 8),
              pw.Text('Jenis: ${pengajuan.jenisPengajuan.label}'),
              pw.SizedBox(height: 8),
              pw.Text('Instansi: ${pengajuan.namaInstansi ?? "-"}'),
              pw.SizedBox(height: 8),
              pw.Text('Posisi: ${pengajuan.posisi ?? "-"}'),
              pw.SizedBox(height: 8),
              pw.Text(
                  'Periode: ${pengajuan.tanggalMulai?.toString().split(" ").first ?? "-"} s/d ${pengajuan.tanggalSelesai?.toString().split(" ").first ?? "-"}'),
              pw.SizedBox(height: 30),
              pw.Text('Status: ${pengajuan.statusPengajuan.label}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<void> _cetakNilai() async {
    final pengajuan = context.read<PengajuanProvider>().pengajuanAktif;
    final cetakProvider = context.read<CetakProvider>();

    if (pengajuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada pengajuan PKL aktif')),
      );
      return;
    }

    // Fetch nilai for this pengajuan
    final nilaiData =
        await cetakProvider.getNilaiPengajuan(pengajuan.idPengajuan);

    if (nilaiData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum ada nilai untuk dicetak')),
        );
      }
      return;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(children: [
                  pw.Text('LAPORAN NILAI PKL',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.SizedBox(height: 20),
                ]),
              ),
              pw.Text(
                  'Nilai Kedisiplinan: ${nilaiData['kedisiplinan'] ?? "-"}'),
              pw.SizedBox(height: 8),
              pw.Text('Nilai Kinerja: ${nilaiData['kinerja'] ?? "-"}'),
              pw.SizedBox(height: 8),
              pw.Text('Nilai Laporan: ${nilaiData['laporan'] ?? "-"}'),
              pw.SizedBox(height: 8),
              pw.Text('Nilai Sikap: ${nilaiData['sikap'] ?? "-"}'),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.Text('Rata-rata: ${nilaiData['rata_rata'] ?? "-"}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<void> _cetakLaporanHarian() async {
    final pengajuan = context.read<PengajuanProvider>().pengajuanAktif;
    final laporanProv = context.read<LaporanProvider>();
    final auth = context.read<AuthProvider>();

    if (pengajuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada pengajuan PKL aktif')),
      );
      return;
    }

    if (laporanProv.daftarLaporan.isEmpty) {
      await laporanProv.ambilLaporan(idPengajuan: pengajuan.idPengajuan);
    }

    final daftarLaporan = laporanProv.laporanHarian;

    if (daftarLaporan.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Belum ada laporan harian untuk dicetak')),
        );
      }
      return;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) {
            return pw.Column(children: [
              pw.Center(
                child: pw.Column(children: [
                  pw.Text('LAPORAN KEGIATAN SISWA',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text('PRAKTIK KERJA LAPANGAN (PKL)',
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 10),
                ]),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Nama: ${auth.pengguna?.namaLengkap ?? "-"}',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Instansi: ${pengajuan.namaInstansi ?? "-"}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Periode: ${pengajuan.durasiBulan} Bulan',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Posisi: ${pengajuan.posisi ?? "-"}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ])
                  ]),
              pw.SizedBox(height: 20),
            ]);
          },
          build: (pw.Context context) {
            return [
              pw.TableHelper.fromTextArray(
                headers: ['No', 'Hari/Tanggal', 'Kegiatan', 'Status'],
                data: List<List<String>>.generate(
                  daftarLaporan.length,
                  (index) {
                    final laporan = daftarLaporan[index];
                    return [
                      (index + 1).toString(),
                      laporan.tanggal.toString().split(' ').first,
                      laporan.kegiatan,
                      laporan.status.label,
                    ];
                  },
                ),
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.orange800), // Orange for Siswa
                rowDecoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                            color: PdfColors.grey300, width: 0.5))),
                cellStyle: const pw.TextStyle(fontSize: 10),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FixedColumnWidth(80),
                  2: const pw.FlexColumnWidth(),
                  3: const pw.FixedColumnWidth(60),
                },
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.center,
                },
              ),
            ];
          },
          footer: (context) {
            return pw.Column(children: [
              pw.SizedBox(height: 20),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(children: [
                      pw.Text('Mengetahui,',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Pembimbing Lapangan',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 40),
                      pw.Text('( ................................. )',
                          style: const pw.TextStyle(fontSize: 10)),
                    ]),
                    pw.Column(children: [
                      pw.Text('Parepare, .........................',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Siswa', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 40),
                      pw.Text(
                          '${auth.pengguna?.namaLengkap ?? "................................."}',
                          style: const pw.TextStyle(
                              fontSize: 10,
                              decoration: pw.TextDecoration.underline)),
                    ]),
                  ])
            ]);
          }),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CetakProvider>();

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
              title: 'Cetak Surat Pengantar',
              description: 'Unduh surat pengantar PKL Anda.',
              icon: Icons.description,
              color: Colors.blue,
              onTap: _cetakSuratPengantar,
            ),
            const SizedBox(height: 16),
            _buildCetakCard(
              title: 'Laporan Harian',
              description: 'Rekap kegiatan harian PKL Anda.',
              icon: Icons.calendar_today,
              color: Colors.teal,
              onTap: _cetakLaporanHarian,
            ),
            const SizedBox(height: 16),
            _buildCetakCard(
              title: 'Cetak Nilai',
              description: 'Unduh laporan nilai PKL Anda.',
              icon: Icons.grade,
              color: Colors.orange,
              onTap: _cetakNilai,
            ),
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
                  color: color.withAlpha(26),
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
