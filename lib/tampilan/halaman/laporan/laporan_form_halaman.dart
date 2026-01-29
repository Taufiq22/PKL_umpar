import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/laporan_provider.dart';

/// Halaman form laporan
class LaporanFormHalaman extends StatefulWidget {
  final int? idPengajuan;
  final JenisLaporan? jenisLaporan;

  const LaporanFormHalaman({
    super.key,
    this.idPengajuan,
    this.jenisLaporan,
  });

  @override
  State<LaporanFormHalaman> createState() => _LaporanFormHalamanState();
}

class _LaporanFormHalamanState extends State<LaporanFormHalaman> {
  final _formKey = GlobalKey<FormState>();
  final _kegiatanController = TextEditingController();

  JenisLaporan _jenisLaporan = JenisLaporan.harian;
  DateTime _tanggal = DateTime.now();
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    if (widget.jenisLaporan != null) {
      _jenisLaporan = widget.jenisLaporan!;
    }
  }

  @override
  void dispose() {
    _kegiatanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memilih file'),
            backgroundColor: WarnaAplikasi.error,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LaporanProvider>();

    final data = {
      'id_pengajuan': widget.idPengajuan ?? 1, // Default for demo
      'jenis_laporan': _jenisLaporan.name.capitalizeFirst(),
      'tanggal': _tanggal.toIso8601String().split('T').first,
      'kegiatan': _kegiatanController.text.trim(),
      if (_selectedFilePath != null) 'file_laporan': _selectedFilePath,
    };

    final success = await provider.buatLaporan(data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim!'),
          backgroundColor: WarnaAplikasi.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal mengirim laporan'),
          backgroundColor: WarnaAplikasi.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Jenis Laporan (only Harian and Monitoring - Bimbingan is separate)
              _buildLabel('Jenis Laporan'),
              SegmentedButton<JenisLaporan>(
                segments:
                    [JenisLaporan.harian, JenisLaporan.monitoring].map((jenis) {
                  return ButtonSegment(
                    value: jenis,
                    label: Text(jenis.label),
                    icon: Icon(_getJenisIcon(jenis)),
                  );
                }).toList(),
                selected: {_jenisLaporan},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _jenisLaporan = newSelection.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Tanggal
              _buildLabel('Tanggal'),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius:
                        BorderRadius.circular(UkuranAplikasi.radiusSedang),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: WarnaAplikasi.textLight),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                            .format(_tanggal),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down,
                          color: WarnaAplikasi.textLight),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kegiatan
              _buildLabel('Kegiatan'),
              TextFormField(
                controller: _kegiatanController,
                decoration: InputDecoration(
                  hintText: _getKegiatanHint(),
                  prefixIcon: const Icon(Icons.edit_note_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kegiatan wajib diisi';
                  }
                  if (value.length < 20) {
                    return 'Kegiatan minimal 20 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // File Attachment
              _buildLabel('Lampiran (Opsional)'),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedFilePath != null
                          ? WarnaAplikasi.primary
                          : const Color(0xFFE5E7EB),
                    ),
                    borderRadius:
                        BorderRadius.circular(UkuranAplikasi.radiusSedang),
                    color: _selectedFilePath != null
                        ? WarnaAplikasi.primary.withAlpha(26)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedFilePath != null
                            ? Icons.attach_file
                            : Icons.upload_file_outlined,
                        color: _selectedFilePath != null
                            ? WarnaAplikasi.primary
                            : WarnaAplikasi.textLight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFileName ?? 'Pilih file (PDF, DOC, JPG)',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: _selectedFilePath != null
                                        ? WarnaAplikasi.primary
                                        : WarnaAplikasi.textLight,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_selectedFilePath != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedFilePath = null;
                              _selectedFileName = null;
                            });
                          },
                          color: WarnaAplikasi.textLight,
                        )
                      else
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: WarnaAplikasi.textLight),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tips
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.info.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: WarnaAplikasi.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getTips(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WarnaAplikasi.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              Consumer<LaporanProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _submitForm,
                      icon: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Kirim Laporan'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  IconData _getJenisIcon(JenisLaporan jenis) {
    switch (jenis) {
      case JenisLaporan.harian:
        return Icons.today;
      case JenisLaporan.monitoring:
        return Icons.visibility;
      case JenisLaporan.bimbingan:
        return Icons.school;
    }
  }

  String _getKegiatanHint() {
    switch (_jenisLaporan) {
      case JenisLaporan.harian:
        return 'Tuliskan kegiatan yang Anda lakukan hari ini...';
      case JenisLaporan.monitoring:
        return 'Tuliskan hasil monitoring dan evaluasi...';
      case JenisLaporan.bimbingan:
        return 'Tuliskan materi bimbingan dan catatan...';
    }
  }

  String _getTips() {
    switch (_jenisLaporan) {
      case JenisLaporan.harian:
        return 'Tip: Tuliskan kegiatan secara detail, termasuk waktu dan hasil yang dicapai.';
      case JenisLaporan.monitoring:
        return 'Tip: Sertakan evaluasi progress dan kendala yang dihadapi.';
      case JenisLaporan.bimbingan:
        return 'Tip: Catat poin-poin penting dari sesi bimbingan.';
    }
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
