import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/pengajuan.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/admin_roles_provider.dart';

/// Halaman Verifikasi Pengajuan
/// Digunakan oleh Admin Fakultas dan Admin Sekolah
class VerifikasiPengajuanHalaman extends StatefulWidget {
  const VerifikasiPengajuanHalaman({super.key});

  @override
  State<VerifikasiPengajuanHalaman> createState() =>
      _VerifikasiPengajuanHalamanState();
}

class _VerifikasiPengajuanHalamanState
    extends State<VerifikasiPengajuanHalaman> {
  // ... (previous filter state code)
  String _filterStatus = 'Semua';
  String _filterJenis = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<PengajuanProvider>().ambilPengajuan();
  }

  /// Get nama peserta (mahasiswa atau siswa)
  String _getNamaPeserta(Pengajuan p) {
    return p.namaMahasiswa ?? p.namaSiswa ?? 'Nama tidak tersedia';
  }

  List<Pengajuan> _getFilteredList(List<Pengajuan> list) {
    return list.where((p) {
      final statusMatch =
          _filterStatus == 'Semua' || p.statusPengajuan.label == _filterStatus;
      final jenisMatch =
          _filterJenis == 'Semua' || p.jenisPengajuan.label == _filterJenis;
      return statusMatch && jenisMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of build method same as before until _showVerifikasiDialog)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Pengajuan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<PengajuanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final filteredList = _getFilteredList(provider.daftarPengajuan);

          if (filteredList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: WarnaAplikasi.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pengajuan',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: WarnaAplikasi.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildPengajuanCard(filteredList[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPengajuanCard(Pengajuan pengajuan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
      ),
      child: InkWell(
        onTap: () => _showVerifikasiDialog(pengajuan),
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pengajuan.jenisPengajuan == JenisPengajuan.magang
                          ? WarnaAplikasi.primary.withOpacity(0.1)
                          : WarnaAplikasi.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pengajuan.jenisPengajuan.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: pengajuan.jenisPengajuan == JenisPengajuan.magang
                            ? WarnaAplikasi.primary
                            : WarnaAplikasi.success,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(pengajuan.statusPengajuan),
                ],
              ),
              const SizedBox(height: 12),

              // Nama & Posisi
              Text(
                _getNamaPeserta(pengajuan),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Posisi: ${pengajuan.posisi ?? '-'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WarnaAplikasi.textSecondary,
                    ),
              ),

              // Instansi
              Text(
                'Instansi: ${pengajuan.namaInstansi ?? '-'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WarnaAplikasi.textSecondary,
                    ),
              ),

              const SizedBox(height: 12),

              // Tanggal
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: WarnaAplikasi.textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(pengajuan.tanggalMulai)} - ${_formatDate(pengajuan.tanggalSelesai)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              // Action buttons for pending
              if (pengajuan.statusPengajuan == StatusPengajuan.diajukan) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showTolakDialog(pengajuan),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: WarnaAplikasi.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showVerifikasiDialog(pengajuan),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Verifikasi'),
                      ),
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

  Widget _buildStatusChip(StatusPengajuan status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.warna.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.warna,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog() {
    // ... (same as before)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pengajuan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _filterStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Semua', 'Diajukan', 'Disetujui', 'Ditolak', 'Selesai']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _filterStatus = v ?? 'Semua'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _filterJenis,
              decoration: const InputDecoration(labelText: 'Jenis'),
              items: ['Semua', 'Magang', 'PKL']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _filterJenis = v ?? 'Semua'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterStatus = 'Semua';
                _filterJenis = 'Semua';
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  void _showVerifikasiDialog(Pengajuan pengajuan) {
    // Fetch pembimbing data based on user role
    final authProvider = context.read<AuthProvider>();
    final role = authProvider.role;
    final adminRolesProvider = context.read<AdminRolesProvider>();

    // Load data if needed
    if (role == RolePengguna.adminFakultas &&
        adminRolesProvider.dosenList.isEmpty) {
      adminRolesProvider.fetchDosenPembimbing();
    } else if (role == RolePengguna.adminSekolah &&
        adminRolesProvider.guruList.isEmpty) {
      adminRolesProvider.fetchGuruPembimbing();
    }

    int? selectedPembimbingId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(UkuranAplikasi.paddingBesar),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: WarnaAplikasi.textLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Verifikasi Pengajuan',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Detail items
                _buildDetailRow('Nama', _getNamaPeserta(pengajuan)),
                _buildDetailRow('Jenis', pengajuan.jenisPengajuan.label),
                _buildDetailRow('Instansi', pengajuan.namaInstansi ?? '-'),
                _buildDetailRow('Posisi', pengajuan.posisi ?? '-'),
                _buildDetailRow('Durasi', '${pengajuan.durasiBulan} bulan'),
                _buildDetailRow(
                    'Tanggal Mulai', _formatDate(pengajuan.tanggalMulai)),
                _buildDetailRow(
                    'Tanggal Selesai', _formatDate(pengajuan.tanggalSelesai)),
                _buildDetailRow('Status', pengajuan.statusPengajuan.label),
                if (pengajuan.keterangan?.isNotEmpty == true)
                  _buildDetailRow('Keterangan', pengajuan.keterangan!),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Pembimbing Allocation (Only for Admin)
                if (role == RolePengguna.adminFakultas ||
                    role == RolePengguna.adminSekolah) ...[
                  Text(
                    'Pilih Pembimbing',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Consumer<AdminRolesProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ));
                      }

                      final list = role == RolePengguna.adminFakultas
                          ? provider.dosenList
                          : provider.guruList;

                      if (list.isEmpty) {
                        return const Text(
                            'Tidak ada data pembimbing tersedia.');
                      }

                      return DropdownButtonFormField<int>(
                        value: selectedPembimbingId,
                        decoration: const InputDecoration(
                          hintText: 'Pilih Pembimbing',
                          border: OutlineInputBorder(),
                        ),
                        items: list.map((item) {
                          // item has 'id_dosen_pembimbing' or 'id_guru_pembimbing'?
                          // Check fetchDosenPembimbing query: SELECT d.* from dosen_pembimbing d.
                          // So it has 'id_dosen_pembimbing'.
                          // fetchGuruPembimbing: SELECT g.* from guru_pembimbing g.
                          // So it has 'id_guru_pembimbing'.
                          // But we need to be careful about the key name.
                          // Safer to check map keys or use 'id_user' if we saved that?
                          // In createDosen, we insert into dosen_pembimbing.
                          // The ID we need to save in 'pengajuan' is 'id_dosen_pembimbing' or 'id_guru_pembimbing'.
                          // Let's assume the API returns the PK of the pembimbing table.

                          final id = role == RolePengguna.adminFakultas
                              ? item['id_dosen_pembimbing']
                              : item['id_guru_pembimbing'];
                          final nama = item['nama'];

                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(nama ?? '-'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setSheetState(() {
                            selectedPembimbingId = val;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Action buttons
                if (pengajuan.statusPengajuan == StatusPengajuan.diajukan) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showTolakDialog(pengajuan);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: WarnaAplikasi.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Validation: Pembimbing required for Admin
                            if ((role == RolePengguna.adminFakultas ||
                                    role == RolePengguna.adminSekolah) &&
                                selectedPembimbingId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Harap pilih pembimbing terlebih dahulu')),
                              );
                              return;
                            }

                            Navigator.pop(context);
                            _verifikasi(pengajuan, true,
                                idPembimbing: selectedPembimbingId);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Setujui'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (buildDetailRow, showTolakDialog same as before)
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: WarnaAplikasi.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showTolakDialog(Pengajuan pengajuan) {
    final alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pengajuan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan alasan penolakan:'),
            const SizedBox(height: 12),
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan...',
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
            onPressed: () {
              Navigator.pop(context);
              _verifikasi(pengajuan, false, catatan: alasanController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.error,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifikasi(Pengajuan pengajuan, bool disetujui,
      {String? catatan, int? idPembimbing}) async {
    final provider = context.read<PengajuanProvider>();
    final authProvider = context.read<AuthProvider>();
    final role = authProvider.role;

    bool success = false;

    if (role == RolePengguna.adminFakultas) {
      success = await provider.approveByFakultas(
        pengajuan.idPengajuan,
        approved: disetujui,
        catatan: catatan,
        idPembimbing: idPembimbing,
      );
    } else if (role == RolePengguna.adminSekolah) {
      success = await provider.approveBySekolah(
        pengajuan.idPengajuan,
        approved: disetujui,
        catatan: catatan,
        idPembimbing: idPembimbing,
      );
    } else {
      success = await provider.verifikasiPengajuan(
        pengajuan.idPengajuan,
        disetujui: disetujui,
        catatan: catatan,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Pengajuan berhasil ${disetujui ? 'disetujui' : 'ditolak'}'
              : 'Gagal memverifikasi pengajuan'),
          backgroundColor:
              success ? WarnaAplikasi.success : WarnaAplikasi.error,
        ),
      );
    }
  }
}
