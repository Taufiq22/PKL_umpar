import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/cetak_provider.dart';

/// Halaman preview dan cetak surat balasan
class SuratBalasanHalaman extends StatefulWidget {
  final int idPengajuan;

  const SuratBalasanHalaman({super.key, required this.idPengajuan});

  @override
  State<SuratBalasanHalaman> createState() => _SuratBalasanHalamanState();
}

class _SuratBalasanHalamanState extends State<SuratBalasanHalaman> {
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
    final data = await cetakProvider.getSuratBalasan(widget.idPengajuan);

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
        title: const Text('Surat Balasan'),
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
          // Status Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: WarnaAplikasi.success.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: WarnaAplikasi.success),
                const SizedBox(width: 8),
                Text(
                  'Status: ${_dataSurat!['status_pengajuan']}',
                  style: const TextStyle(
                    color: WarnaAplikasi.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                        'SURAT BALASAN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nomor: ${_dataSurat!['nomor_surat'] ?? '-'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Divider(height: 24, thickness: 2),
                    ],
                  ),
                ),

                // Isi Surat
                const Text('Yang bertanda tangan di bawah ini:'),
                const SizedBox(height: 8),
                _buildInfoRow('Nama', 'Kepala Bagian Akademik'),
                _buildInfoRow('Jabatan', 'Wakil Rektor I UMPAR'),
                const SizedBox(height: 16),

                const Text('Dengan ini menerangkan bahwa mahasiswa/siswa:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.primary.withAlpha(13),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: WarnaAplikasi.primary.withAlpha(51)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Nama', _dataSurat!['nama_peserta'] ?? '-'),
                      _buildInfoRow(
                          'Jenis', _dataSurat!['jenis_pengajuan'] ?? '-'),
                      _buildInfoRow('Posisi', _dataSurat!['posisi'] ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildParagraph(
                  'Telah diterima untuk melaksanakan ${_dataSurat!['jenis_pengajuan']} '
                  'di ${_dataSurat!['nama_instansi'] ?? '-'} dengan ketentuan sebagai berikut:',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                    'Tanggal Mulai', _formatDate(_dataSurat!['tanggal_mulai'])),
                _buildInfoRow('Tanggal Selesai',
                    _formatDate(_dataSurat!['tanggal_selesai'])),
                _buildInfoRow('Durasi', '${_dataSurat!['durasi_bulan']} bulan'),
                if (_dataSurat!['nama_pembimbing'] != null)
                  _buildInfoRow('Pembimbing', _dataSurat!['nama_pembimbing']),
                const SizedBox(height: 16),

                _buildParagraph(
                  'Demikian surat balasan ini dibuat untuk dapat dipergunakan sebagaimana mestinya.',
                ),
                const SizedBox(height: 32),

                // TTD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TTD Pembimbing
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Pembimbing,'),
                        const SizedBox(height: 60),
                        Text(
                          '(${_dataSurat!['nama_pembimbing'] ?? '............................'})',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'NIP. .............................',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    // TTD Akademik
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Parepare, ${_formatDate(_dataSurat!['tanggal_verifikasi'])}',
                        ),
                        const SizedBox(height: 4),
                        const Text('Wakil Rektor I,'),
                        const SizedBox(height: 50),
                        const Text(
                          '(............................)',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'NIP. .............................',
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

          // Info file surat balasan
          if (_dataSurat!['surat_balasan'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WarnaAplikasi.info.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: WarnaAplikasi.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'File Surat Balasan:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _dataSurat!['surat_balasan'],
                          style: const TextStyle(
                            color: WarnaAplikasi.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

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
  }
}
