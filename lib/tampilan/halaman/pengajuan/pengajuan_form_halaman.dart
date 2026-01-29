import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../../provider/instansi_provider.dart';

/// Halaman form pengajuan magang/PKL
class PengajuanFormHalaman extends StatefulWidget {
  final bool isMagang;

  const PengajuanFormHalaman({super.key, this.isMagang = true});

  @override
  State<PengajuanFormHalaman> createState() => _PengajuanFormHalamanState();
}

class _PengajuanFormHalamanState extends State<PengajuanFormHalaman> {
  final _formKey = GlobalKey<FormState>();
  final _posisiController = TextEditingController();
  final _keteranganController = TextEditingController();

  // For instansi selection
  int? _selectedInstansiId;
  bool _useManualInput = false;
  final _manualInstansiController = TextEditingController();
  final _manualAlamatController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int _durasiBulan = 3;

  @override
  void initState() {
    super.initState();
    // Load instansi list on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstansiProvider>().ambilDaftarInstansi();
    });
  }

  @override
  void dispose() {
    _posisiController.dispose();
    _keteranganController.dispose();
    _manualInstansiController.dispose();
    _manualAlamatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_tanggalMulai ?? DateTime.now())
          : (_tanggalSelesai ?? DateTime.now().add(const Duration(days: 90))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = picked;
          // Auto-set tanggal selesai
          _tanggalSelesai = picked.add(Duration(days: _durasiBulan * 30));
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalMulai == null || _tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan pilih tanggal mulai dan selesai')),
      );
      return;
    }

    // Validate instansi selection
    if (!_useManualInput && _selectedInstansiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih instansi')),
      );
      return;
    }

    final provider = context.read<PengajuanProvider>();
    final instansiProvider = context.read<InstansiProvider>();

    // Get instansi data
    String namaInstansi;
    String alamatInstansi;

    if (_useManualInput) {
      namaInstansi = _manualInstansiController.text.trim();
      alamatInstansi = _manualAlamatController.text.trim();
    } else {
      final selectedInstansi = instansiProvider.getById(_selectedInstansiId!);
      namaInstansi = selectedInstansi?.namaInstansi ?? '';
      alamatInstansi = selectedInstansi?.alamat ?? '';
    }

    final data = {
      'jenis_pengajuan': widget.isMagang ? 'Magang' : 'PKL',
      'id_instansi': _useManualInput ? null : _selectedInstansiId,
      'nama_instansi': namaInstansi,
      'alamat_instansi': alamatInstansi,
      'posisi': _posisiController.text.trim(),
      'tanggal_mulai': _tanggalMulai!.toIso8601String().split('T').first,
      'tanggal_selesai': _tanggalSelesai!.toIso8601String().split('T').first,
      'durasi_bulan': _durasiBulan,
      'keterangan': _keteranganController.text.trim(),
    };

    final success = await provider.buatPengajuan(data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan berhasil dikirim!'),
          backgroundColor: WarnaAplikasi.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal mengirim pengajuan'),
          backgroundColor: WarnaAplikasi.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pengajuan ${widget.isMagang ? "Magang" : "PKL"}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.info.withAlpha(26),
                  borderRadius:
                      BorderRadius.circular(UkuranAplikasi.radiusSedang),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: WarnaAplikasi.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lengkapi form berikut untuk mengajukan ${widget.isMagang ? "magang" : "PKL"}.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WarnaAplikasi.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Toggle for manual input
              Row(
                children: [
                  Expanded(child: _buildLabel('Pilih Instansi')),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _useManualInput = !_useManualInput;
                        if (_useManualInput) {
                          _selectedInstansiId = null;
                        } else {
                          _manualInstansiController.clear();
                          _manualAlamatController.clear();
                        }
                      });
                    },
                    icon: Icon(
                      _useManualInput ? Icons.list_alt : Icons.edit_outlined,
                      size: 18,
                    ),
                    label: Text(
                      _useManualInput ? 'Pilih dari daftar' : 'Input manual',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),

              // Instansi Selection
              if (_useManualInput) ...[
                // Manual Input Fields
                TextFormField(
                  controller: _manualInstansiController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama instansi',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (value) {
                    if (_useManualInput && (value == null || value.isEmpty)) {
                      return 'Nama instansi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Alamat Instansi'),
                TextFormField(
                  controller: _manualAlamatController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alamat lengkap',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (_useManualInput && (value == null || value.isEmpty)) {
                      return 'Alamat wajib diisi';
                    }
                    return null;
                  },
                ),
              ] else ...[
                // Dropdown Selection
                Consumer<InstansiProvider>(
                  builder: (context, instansiProv, _) {
                    if (instansiProv.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (instansiProv.daftarInstansi.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: WarnaAplikasi.warning.withAlpha(26),
                          borderRadius: BorderRadius.circular(
                              UkuranAplikasi.radiusSedang),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.warning_amber,
                                color: WarnaAplikasi.warning),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada instansi terdaftar',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Silakan gunakan input manual',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      initialValue: _selectedInstansiId,
                      decoration: const InputDecoration(
                        hintText: 'Pilih instansi',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items: instansiProv.daftarInstansi.map((instansi) {
                        return DropdownMenuItem(
                          value: instansi.idInstansi,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                instansi.namaInstansi,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (instansi.bidang != null)
                                Text(
                                  instansi.bidang!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: WarnaAplikasi.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedInstansiId = value;
                        });
                      },
                      validator: (value) {
                        if (!_useManualInput && value == null) {
                          return 'Pilih instansi atau gunakan input manual';
                        }
                        return null;
                      },
                    );
                  },
                ),

                // Show selected instansi details
                if (_selectedInstansiId != null)
                  Consumer<InstansiProvider>(
                    builder: (context, instansiProv, _) {
                      final selected =
                          instansiProv.getById(_selectedInstansiId!);
                      if (selected == null) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WarnaAplikasi.primary.withAlpha(13),
                          borderRadius: BorderRadius.circular(
                              UkuranAplikasi.radiusSedang),
                          border: Border.all(
                            color: WarnaAplikasi.primary.withAlpha(51),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: WarnaAplikasi.success, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Instansi Terpilih',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                          color: WarnaAplikasi.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selected.namaInstansi,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              selected.alamat,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (selected.kontak != null)
                              Text(
                                'Kontak: ${selected.kontak}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],

              const SizedBox(height: 16),

              // Posisi
              _buildLabel('Posisi yang Dilamar'),
              TextFormField(
                controller: _posisiController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Frontend Developer',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Posisi wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Durasi
              _buildLabel('Durasi (Bulan)'),
              DropdownButtonFormField<int>(
                initialValue: _durasiBulan,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                items: [1, 2, 3, 4, 5, 6].map((bulan) {
                  return DropdownMenuItem(
                    value: bulan,
                    child: Text('$bulan Bulan'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _durasiBulan = value ?? 3;
                    if (_tanggalMulai != null) {
                      _tanggalSelesai =
                          _tanggalMulai!.add(Duration(days: _durasiBulan * 30));
                    }
                  });
                },
              ),

              const SizedBox(height: 16),

              // Tanggal
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal Mulai'),
                        InkWell(
                          onTap: () => _selectDate(true),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(
                                  UkuranAplikasi.radiusSedang),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 20, color: WarnaAplikasi.textLight),
                                const SizedBox(width: 8),
                                Text(
                                  _tanggalMulai != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(_tanggalMulai!)
                                      : 'Pilih tanggal',
                                  style: TextStyle(
                                    color: _tanggalMulai != null
                                        ? WarnaAplikasi.textPrimary
                                        : WarnaAplikasi.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal Selesai'),
                        InkWell(
                          onTap: () => _selectDate(false),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(
                                  UkuranAplikasi.radiusSedang),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 20, color: WarnaAplikasi.textLight),
                                const SizedBox(width: 8),
                                Text(
                                  _tanggalSelesai != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(_tanggalSelesai!)
                                      : 'Pilih tanggal',
                                  style: TextStyle(
                                    color: _tanggalSelesai != null
                                        ? WarnaAplikasi.textPrimary
                                        : WarnaAplikasi.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Keterangan
              _buildLabel('Keterangan (Opsional)'),
              TextFormField(
                controller: _keteranganController,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan keterangan jika perlu',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Submit Button
              Consumer<PengajuanProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Kirim Pengajuan'),
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
}
