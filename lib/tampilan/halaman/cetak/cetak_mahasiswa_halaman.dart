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

/// Halaman Cetak khusus untuk Mahasiswa - UI/UX Upgraded
class CetakMahasiswaHalaman extends StatefulWidget {
  const CetakMahasiswaHalaman({super.key});

  @override
  State<CetakMahasiswaHalaman> createState() => _CetakMahasiswaHalamanState();
}

class _CetakMahasiswaHalamanState extends State<CetakMahasiswaHalaman> {
  Future<void> _cetakSuratPengantar() async {
    final auth = context.read<AuthProvider>();
    final pengajuan = context.read<PengajuanProvider>().pengajuanAktif;

    if (pengajuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Belum ada pengajuan magang aktif'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
                  pw.Text('SURAT PENGANTAR MAGANG',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('UNIVERSITAS MUHAMMADIYAH PAREPARE',
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
        SnackBar(
          content: const Text('Belum ada pengajuan magang aktif'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final nilaiData =
        await cetakProvider.getNilaiPengajuan(pengajuan.idPengajuan);

    if (nilaiData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Belum ada nilai untuk dicetak'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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
                  pw.Text('LAPORAN NILAI MAGANG',
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
        SnackBar(
          content: const Text('Belum ada pengajuan magang aktif'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Ensure logic to fetch latest data if empty
    if (laporanProv.daftarLaporan.isEmpty) {
      await laporanProv.ambilLaporan(idPengajuan: pengajuan.idPengajuan);
    }

    final daftarLaporan =
        laporanProv.laporanHarian; // Get filtered daily reports

    if (daftarLaporan.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Belum ada laporan harian untuk dicetak'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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
                  pw.Text('LAPORAN KEGIATAN HARIAN',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text('MAHASISWA MAGANG UMPAR',
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
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.blue800),
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
                      pw.Text('Mahasiswa',
                          style: const pw.TextStyle(fontSize: 10)),
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
        backgroundColor: Colors.grey[100],
        body: CustomScrollView(
          slivers: [
            // Modern Header
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: WarnaAplikasi.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cetak Dokumen',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Unduh surat & laporan Anda',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(40),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.info_outline,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Dokumen akan diunduh dalam format PDF',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.white),
                                ),
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

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildDocumentCard(
                    icon: Icons.description_outlined,
                    title: 'Surat Pengantar',
                    description: 'Surat pengantar resmi untuk pengajuan magang',
                    color: WarnaAplikasi.primary,
                    onTap: _cetakSuratPengantar,
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Laporan Harian',
                    description: 'Rekap kegiatan harian selama magang',
                    color: Colors.teal,
                    onTap: _cetakLaporanHarian,
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentCard(
                    icon: Icons.grade_outlined,
                    title: 'Laporan Nilai',
                    description:
                        'Rekap nilai magang dari pembimbing & instansi',
                    color: WarnaAplikasi.warning,
                    onTap: _cetakNilai,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(60),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WarnaAplikasi.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.download, color: color, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
