/// Enhanced Bimbingan List Page
/// UMPAR Magang & PKL System
///
/// Displays guidance session list with scheduling and feedback

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/bimbingan.dart';
import '../../../provider/bimbingan_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../konfigurasi/konstanta.dart';

class BimbinganEnhancedHalaman extends StatefulWidget {
  final int? idPengajuan;

  const BimbinganEnhancedHalaman({super.key, this.idPengajuan});

  @override
  State<BimbinganEnhancedHalaman> createState() =>
      _BimbinganEnhancedHalamanState();
}

class _BimbinganEnhancedHalamanState extends State<BimbinganEnhancedHalaman>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<BimbinganProvider>();
    if (widget.idPengajuan != null) {
      await provider.fetchByPengajuan(widget.idPengajuan!);
    } else {
      await provider.fetchBimbingan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final isStudent = authProvider.role?.isPeserta ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bimbingan'),
        backgroundColor: WarnaAplikasi.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Terjadwal'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: Consumer<BimbinganProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(provider.error!,
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBimbinganList(
                  provider.bimbinganDiajukan,
                  isStudent
                      ? 'Belum ada pengajuan bimbingan'
                      : 'Belum ada permintaan bimbingan'),
              _buildBimbinganList(
                  provider.bimbinganDijadwalkan,
                  isStudent
                      ? 'Belum ada jadwal bimbingan'
                      : 'Belum ada jadwal bimbingan'),
              _buildBimbinganList(
                  provider.bimbinganSelesai,
                  isStudent
                      ? 'Belum ada riwayat selesai'
                      : 'Belum ada bimbingan selesai'),
            ],
          );
        },
      ),
      floatingActionButton: isStudent
          ? FloatingActionButton.extended(
              onPressed: () => _showRequestDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Ajukan Bimbingan'),
              backgroundColor: WarnaAplikasi.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildBimbinganList(List<Bimbingan> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildBimbinganCard(list[index]);
        },
      ),
    );
  }

  Widget _buildBimbinganCard(Bimbingan bimbingan) {
    final authProvider = context.read<AuthProvider>();
    final isStudent = authProvider.role?.isPeserta ?? false;
    final isPembimbing = authProvider.role?.isPembimbing ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailSheet(bimbingan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bimbingan.statusBimbingan.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      bimbingan.statusBimbingan.icon,
                      color: bimbingan.statusBimbingan.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bimbingan.topikBimbingan,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isStudent
                              ? (bimbingan.namaPembimbing ?? 'Pembimbing')
                              : (bimbingan.namaPeserta ?? 'Peserta'),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bimbingan.statusBimbingan.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bimbingan.statusBimbingan.label,
                      style: TextStyle(
                        color: bimbingan.statusBimbingan.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                bimbingan.deskripsiMasalah,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Diajukan: ${bimbingan.tanggalPengajuanFormatted}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  if (bimbingan.tanggalBimbingan != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.event, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Jadwal: ${bimbingan.tanggalBimbinganFormatted}',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ],
              ),

              // Rating stars if completed
              if (bimbingan.rating != null) ...[
                const SizedBox(height: 8),
                Row(children: bimbingan.getRatingStars()),
              ],

              // Action buttons
              if (isPembimbing &&
                  bimbingan.statusBimbingan == StatusBimbingan.diajukan) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showScheduleDialog(bimbingan),
                      icon: const Icon(Icons.event, size: 18),
                      label: const Text('Jadwalkan'),
                    ),
                  ],
                ),
              ],

              if (isPembimbing &&
                  bimbingan.statusBimbingan == StatusBimbingan.dijadwalkan) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showCompleteDialog(bimbingan),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Selesaikan'),
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.green),
                    ),
                  ],
                ),
              ],

              if (!isPembimbing && bimbingan.canGiveRating) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showRatingDialog(bimbingan),
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('Beri Rating'),
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.amber),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(Bimbingan bimbingan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: bimbingan.statusBimbingan.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(bimbingan.statusBimbingan.icon,
                            size: 16, color: bimbingan.statusBimbingan.color),
                        const SizedBox(width: 6),
                        Text(
                          bimbingan.statusBimbingan.label,
                          style: TextStyle(
                            color: bimbingan.statusBimbingan.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Topic
                  Text(
                    bimbingan.topikBimbingan,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Deskripsi Masalah',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(bimbingan.deskripsiMasalah),

                  if (bimbingan.catatanMahasiswa != null) ...[
                    const SizedBox(height: 16),
                    const Text('Catatan Mahasiswa',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(bimbingan.catatanMahasiswa!),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Schedule info
                  _buildDetailRow(Icons.calendar_today, 'Tanggal Pengajuan',
                      bimbingan.tanggalPengajuanFormatted),
                  if (bimbingan.tanggalBimbingan != null)
                    _buildDetailRow(Icons.event, 'Jadwal Bimbingan',
                        '${bimbingan.tanggalBimbinganFormatted} ${bimbingan.jamBimbinganFormatted}'),
                  if (bimbingan.lokasiBimbingan != null)
                    _buildDetailRow(Icons.location_on, 'Lokasi',
                        bimbingan.lokasiBimbingan!),

                  // Feedback
                  if (bimbingan.feedbackPembimbing != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('Feedback Pembimbing',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(bimbingan.feedbackPembimbing!),
                    ),
                  ],

                  // Rating
                  if (bimbingan.rating != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Rating: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...bimbingan.getRatingStars(),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showRequestDialog() {
    final topikController = TextEditingController();
    final masalahController = TextEditingController();
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajukan Bimbingan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: topikController,
                  decoration: const InputDecoration(
                    labelText: 'Topik Bimbingan',
                    hintText: 'Contoh: Kesulitan Integrasi API',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: masalahController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Masalah',
                    hintText: 'Jelaskan masalah yang ingin dibahas...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: catatanController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Tambahan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (topikController.text.isEmpty ||
                    masalahController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Topik dan deskripsi wajib diisi')),
                  );
                  return;
                }

                if (widget.idPengajuan == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ID Pengajuan tidak ditemukan')),
                  );
                  return;
                }

                final bimbingan = Bimbingan(
                  idPengajuan: widget.idPengajuan!,
                  topikBimbingan: topikController.text,
                  deskripsiMasalah: masalahController.text,
                  tanggalPengajuan: DateTime.now(),
                  statusBimbingan: StatusBimbingan.diajukan,
                  catatanMahasiswa: catatanController.text.isNotEmpty
                      ? catatanController.text
                      : null,
                );

                Navigator.pop(context);

                final success = await context
                    .read<BimbinganProvider>()
                    .createBimbingan(bimbingan);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Permintaan bimbingan berhasil diajukan'
                          : 'Gagal mengajukan bimbingan'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Ajukan'),
            ),
          ],
        );
      },
    );
  }

  void _showScheduleDialog(Bimbingan bimbingan) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final lokasiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Jadwalkan Bimbingan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lokasiController,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi (Opsional)',
                      hintText: 'Contoh: Ruang Dosen Lt. 2',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final scheduledDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    Navigator.pop(context);

                    final success =
                        await context.read<BimbinganProvider>().setJadwal(
                              bimbingan.idBimbingan!,
                              scheduledDateTime,
                              lokasi: lokasiController.text.isNotEmpty
                                  ? lokasiController.text
                                  : null,
                            );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Jadwal berhasil diatur'
                              : 'Gagal mengatur jadwal'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCompleteDialog(Bimbingan bimbingan) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selesaikan Bimbingan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Berikan feedback untuk mahasiswa/siswa:'),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  hintText: 'Masukkan feedback...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final success =
                    await context.read<BimbinganProvider>().selesaikanBimbingan(
                          bimbingan.idBimbingan!,
                          feedback: feedbackController.text.isNotEmpty
                              ? feedbackController.text
                              : null,
                        );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Bimbingan berhasil diselesaikan'
                          : 'Gagal menyelesaikan bimbingan'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Selesaikan'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(Bimbingan bimbingan) {
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Beri Rating'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bagaimana pengalaman bimbingan Anda?'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () =>
                            setState(() => selectedRating = index + 1),
                      );
                    }),
                  ),
                  Text(
                    '$selectedRating / 5',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    final success =
                        await context.read<BimbinganProvider>().giveRating(
                              bimbingan.idBimbingan!,
                              selectedRating,
                            );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Rating berhasil diberikan'
                              : 'Gagal memberikan rating'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text('Kirim Rating'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
