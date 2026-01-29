/// Input Kehadiran Page
/// UMPAR Magang & PKL System
///
/// Form for inputting daily attendance

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/kehadiran.dart';
import '../../../provider/kehadiran_provider.dart';
import '../../../konfigurasi/konstanta.dart';

class InputKehadiranHalaman extends StatefulWidget {
  final int idPengajuan;

  const InputKehadiranHalaman({super.key, required this.idPengajuan});

  @override
  State<InputKehadiranHalaman> createState() => _InputKehadiranHalamanState();
}

class _InputKehadiranHalamanState extends State<InputKehadiranHalaman> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  StatusKehadiran _selectedStatus = StatusKehadiran.hadir;
  TimeOfDay? _jamMasuk;
  TimeOfDay? _jamKeluar;
  final _keteranganController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Kehadiran'),
        backgroundColor: WarnaAplikasi.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker Card
              _buildSectionCard(
                title: 'Tanggal',
                icon: Icons.calendar_today,
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: WarnaAplikasi.primary),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status Selection
              _buildSectionCard(
                title: 'Status Kehadiran',
                icon: Icons.how_to_reg,
                child: Column(
                  children: StatusKehadiran.values.map((status) {
                    final isSelected = _selectedStatus == status;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedStatus = status),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? status.color.withOpacity(0.1)
                                : Colors.grey[50],
                            border: Border.all(
                              color:
                                  isSelected ? status.color : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                status.icon,
                                color: isSelected
                                    ? status.color
                                    : Colors.grey[500],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                status.label,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? status.color
                                      : Colors.grey[700],
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(Icons.check_circle, color: status.color),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Time Pickers (only for Hadir status)
              if (_selectedStatus == StatusKehadiran.hadir)
                _buildSectionCard(
                  title: 'Waktu',
                  icon: Icons.access_time,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Jam Masuk',
                          time: _jamMasuk,
                          onTap: () => _selectTime(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Jam Keluar',
                          time: _jamKeluar,
                          onTap: () => _selectTime(false),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_selectedStatus == StatusKehadiran.hadir)
                const SizedBox(height: 20),

              // Keterangan
              _buildSectionCard(
                title: 'Keterangan',
                icon: Icons.notes,
                subtitle: _selectedStatus != StatusKehadiran.hadir
                    ? '(Wajib untuk ${_selectedStatus.label})'
                    : '(Opsional)',
                child: TextFormField(
                  controller: _keteranganController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _selectedStatus == StatusKehadiran.izin
                        ? 'Contoh: Keperluan keluarga...'
                        : _selectedStatus == StatusKehadiran.sakit
                            ? 'Contoh: Demam, flu...'
                            : 'Tambahkan catatan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (_selectedStatus != StatusKehadiran.hadir &&
                        (value == null || value.isEmpty)) {
                      return 'Keterangan wajib diisi untuk ${_selectedStatus.label}';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaAplikasi.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Kehadiran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: WarnaAplikasi.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  label == 'Jam Masuk' ? Icons.login : Icons.logout,
                  size: 20,
                  color: WarnaAplikasi.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  time != null
                      ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                      : '--:--',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${days[date.weekday]}, ${date.day} ${months[date.month]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: WarnaAplikasi.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(bool isJamMasuk) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isJamMasuk
          ? (_jamMasuk ?? const TimeOfDay(hour: 8, minute: 0))
          : (_jamKeluar ?? const TimeOfDay(hour: 17, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: WarnaAplikasi.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isJamMasuk) {
          _jamMasuk = picked;
        } else {
          _jamKeluar = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate time for Hadir status
    if (_selectedStatus == StatusKehadiran.hadir) {
      if (_jamMasuk == null || _jamKeluar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Jam Masuk dan Jam Keluar wajib diisi untuk status Hadir'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final kehadiran = Kehadiran(
      idPengajuan: widget.idPengajuan,
      tanggal: _selectedDate,
      statusKehadiran: _selectedStatus,
      jamMasuk: _selectedStatus == StatusKehadiran.hadir ? _jamMasuk : null,
      jamKeluar: _selectedStatus == StatusKehadiran.hadir ? _jamKeluar : null,
      keterangan: _keteranganController.text.isNotEmpty
          ? _keteranganController.text
          : null,
    );

    final provider = context.read<KehadiranProvider>();
    final success = await provider.inputKehadiran(kehadiran);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kehadiran berhasil dicatat'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Gagal mencatat kehadiran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
