import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/cetak_provider.dart';

/// Halaman preview dan cetak surat permohonan
class SuratPermohonanHalaman extends StatefulWidget {
  final int idPengajuan;

  const SuratPermohonanHalaman({super.key, required this.idPengajuan});

  @override
  State<SuratPermohonanHalaman> createState() => _SuratPermohonanHalamanState();
}

class _SuratPermohonanHalamanState extends State<SuratPermohonanHalaman> {
  Map<String, dynamic>? _dataSurat;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final cetakProvider = context.read<CetakProvider>();
    final data = await cetakProvider.getSuratPermohonan(widget.idPengajuan);

    setState(() {
      _dataSurat = data;
      _isLoading = false;
      if (data == null) {
        _error = cetakProvider.error ?? 'Gagal memuat data surat';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surat Permohonan'),
        actions: [
          if (_dataSurat != null)
            IconButton(
              onPressed: _printSurat,
              icon: const Icon(Icons.print),
              tooltip: 'Cetak',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _dataSurat == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: WarnaAplikasi.error),
            const SizedBox(height: 16),
            Text(_error ?? 'Data tidak ditemukan'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Preview Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'UNIVERSITAS MUHAMMADIYAH PAREPARE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'FAKULTAS TEKNIK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jl. Jenderal Ahmad Yani Km. 6 Parepare',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: 24, thickness: 2),
                    ],
                  ),
                ),

                // Nomor Surat
                Text(
                  'Nomor: ${_dataSurat!['nomor_surat'] ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Text('Hal: Permohonan Magang/PKL'),
                const SizedBox(height: 16),

                // Tanggal
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Parepare, ${_formatDate(_dataSurat!['tanggal_pengajuan'])}',
                  ),
                ),
                const SizedBox(height: 16),

                // Kepada
                const Text('Kepada Yth.'),
                Text(
                  'Pimpinan ${_dataSurat!['nama_instansi'] ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('di ${_dataSurat!['alamat_instansi'] ?? '-'}'),
                const SizedBox(height: 16),

                // Isi Surat
                const Text('Dengan hormat,'),
                const SizedBox(height: 8),
                _buildParagraph(
                  'Sehubungan dengan program ${_dataSurat!['jenis_pengajuan']} yang merupakan '
                  'bagian dari kurikulum pendidikan di Universitas Muhammadiyah Parepare, '
                  'dengan ini kami mengajukan permohonan untuk dapat menerima mahasiswa/siswa kami:',
                ),
                const SizedBox(height: 16),

                // Data Peserta
                _buildDataPeserta(),
                const SizedBox(height: 16),

                // Waktu Pelaksanaan
                _buildParagraph(
                  'untuk melaksanakan ${_dataSurat!['jenis_pengajuan']} di instansi/perusahaan '
                  'yang Bapak/Ibu pimpin pada posisi ${_dataSurat!['posisi'] ?? '-'}, '
                  'dengan waktu pelaksanaan sebagai berikut:',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                    'Tanggal Mulai', _formatDate(_dataSurat!['tanggal_mulai'])),
                _buildInfoRow('Tanggal Selesai',
                    _formatDate(_dataSurat!['tanggal_selesai'])),
                _buildInfoRow('Durasi', '${_dataSurat!['durasi_bulan']} bulan'),
                const SizedBox(height: 16),

                // Penutup
                _buildParagraph(
                  'Demikian surat permohonan ini kami sampaikan. Atas perhatian dan '
                  'kerjasamanya, kami ucapkan terima kasih.',
                ),
                const SizedBox(height: 32),

                // TTD
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Hormat kami,'),
                        const SizedBox(height: 60),
                        const Text(
                          '(............................)',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Ketua ${_dataSurat!['jenis_pengajuan'] == 'Magang' ? 'Prodi' : 'Jurusan'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Print Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _printSurat,
              icon: const Icon(Icons.print),
              label: const Text('Cetak Surat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPeserta() {
    final peserta = _dataSurat!['peserta'] as Map<String, dynamic>?;
    if (peserta == null) {
      return const Text('Data peserta tidak tersedia');
    }

    final isMahasiswa = peserta.containsKey('nim');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WarnaAplikasi.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WarnaAplikasi.primary.withAlpha(51)),
      ),
      child: Column(
        children: [
          _buildInfoRow('Nama', peserta['nama'] ?? '-'),
          _buildInfoRow(
            isMahasiswa ? 'NIM' : 'NISN',
            peserta['nim'] ?? peserta['nisn'] ?? '-',
          ),
          _buildInfoRow(
            isMahasiswa ? 'Program Studi' : 'Jurusan',
            peserta['prodi'] ?? peserta['jurusan'] ?? '-',
          ),
          _buildInfoRow(
            isMahasiswa ? 'Fakultas' : 'Sekolah',
            peserta['fakultas'] ?? peserta['sekolah'] ?? '-',
          ),
          _buildInfoRow(
            isMahasiswa ? 'Semester' : 'Kelas',
            '${peserta['semester'] ?? peserta['kelas'] ?? '-'}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: WarnaAplikasi.textSecondary),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(height: 1.5),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return '-';
      }
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return date.toString();
    }
  }

  void _printSurat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur cetak akan membuka dialog print browser'),
        backgroundColor: WarnaAplikasi.info,
      ),
    );
    // TODO: Implement actual printing using printing package
  }
}
