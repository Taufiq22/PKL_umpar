/// Kehadiran List Page
/// UMPAR Magang & PKL System
///
/// Displays attendance list with statistics and filtering

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/kehadiran.dart';
import '../../../provider/kehadiran_provider.dart';
import '../../../provider/pengajuan_provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../konfigurasi/rute.dart';
import '../../../layanan/layanan_lokasi.dart';

class KehadiranHalaman extends StatefulWidget {
  final int? idPengajuan;

  const KehadiranHalaman({super.key, this.idPengajuan});

  @override
  State<KehadiranHalaman> createState() => _KehadiranHalamanState();
}

class _KehadiranHalamanState extends State<KehadiranHalaman> {
  int? _selectedPengajuanId;
  StatusKehadiran? _filterStatus;

  @override
  void initState() {
    super.initState();
    _selectedPengajuanId = widget.idPengajuan;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fallback: If no ID passed, try to get from provider
      if (_selectedPengajuanId == null) {
        final pengajuanProvider = context.read<PengajuanProvider>();
        setState(() {
          _selectedPengajuanId = pengajuanProvider.pengajuanAktif?.idPengajuan;
        });
      }
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_selectedPengajuanId != null) {
      await context
          .read<KehadiranProvider>()
          .fetchKehadiran(_selectedPengajuanId!);
    }
  }

  List<Kehadiran> get _filteredList {
    final provider = context.read<KehadiranProvider>();
    if (_filterStatus == null) {
      return provider.daftarKehadiran;
    }
    return provider.getByStatus(_filterStatus!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kehadiran'),
        backgroundColor: WarnaAplikasi.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<KehadiranProvider>(
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

          return RefreshIndicator(
            onRefresh: _loadData,
            child: CustomScrollView(
              slivers: [
                // Statistics Header
                SliverToBoxAdapter(
                  child: _buildStatisticsCard(provider.statistik),
                ),

                // Today's Check-in Card
                if (provider.kehadiranHariIni == null &&
                    _selectedPengajuanId != null)
                  SliverToBoxAdapter(
                    child: _buildCheckinCard(),
                  ),

                // Filter Chips
                SliverToBoxAdapter(
                  child: _buildFilterChips(),
                ),

                // Attendance List
                if (_filteredList.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final kehadiran = _filteredList[index];
                          return Padding(
                            key: ValueKey(kehadiran.idKehadiran),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildKehadiranCard(kehadiran),
                          );
                        },
                        childCount: _filteredList.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _selectedPengajuanId != null
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToInput(),
              icon: const Icon(Icons.add),
              label: const Text('Input Kehadiran'),
              backgroundColor: WarnaAplikasi.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildStatisticsCard(StatistikKehadiran? stats) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [WarnaAplikasi.primary, WarnaAplikasi.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: WarnaAplikasi.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Statistik Kehadiran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${stats.persentaseHadir.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Hadir', stats.hadir, StatusKehadiran.hadir.color),
              _buildStatItem('Izin', stats.izin, StatusKehadiran.izin.color),
              _buildStatItem('Sakit', stats.sakit, StatusKehadiran.sakit.color),
              _buildStatItem('Alpha', stats.alpha, StatusKehadiran.alpha.color),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: stats.persentaseHadir / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckinCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fingerprint, color: Colors.green, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belum Check-in Hari Ini',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Tekan tombol untuk check-in sekarang',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _doCheckin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Check-in'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Semua', null),
          const SizedBox(width: 8),
          _buildFilterChip('Hadir', StatusKehadiran.hadir),
          const SizedBox(width: 8),
          _buildFilterChip('Izin', StatusKehadiran.izin),
          const SizedBox(width: 8),
          _buildFilterChip('Sakit', StatusKehadiran.sakit),
          const SizedBox(width: 8),
          _buildFilterChip('Alpha', StatusKehadiran.alpha),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, StatusKehadiran? status) {
    final isSelected = _filterStatus == status;
    final color = status?.color ?? WarnaAplikasi.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
      },
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildKehadiranCard(Kehadiran kehadiran) {
    return Card(
      margin:
          EdgeInsets.zero, // Margin moved to parent padding for Key stability
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailDialog(kehadiran),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kehadiran.statusKehadiran.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kehadiran.tanggal.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kehadiran.statusKehadiran.color,
                      ),
                    ),
                    Text(
                      _getMonthAbbr(kehadiran.tanggal.month),
                      style: TextStyle(
                        fontSize: 12,
                        color: kehadiran.statusKehadiran.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          kehadiran.statusKehadiran.icon,
                          size: 16,
                          color: kehadiran.statusKehadiran.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          kehadiran.statusKehadiran.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kehadiran.statusKehadiran.color,
                          ),
                        ),
                        if (kehadiran.isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: WarnaAplikasi.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Hari Ini',
                              style: TextStyle(
                                fontSize: 10,
                                color: WarnaAplikasi.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (kehadiran.jamMasuk != null ||
                        kehadiran.jamKeluar != null)
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${kehadiran.jamMasukFormatted} - ${kehadiran.jamKeluarFormatted}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (kehadiran.durasi != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(${kehadiran.durasiFormatted})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    if (kehadiran.keterangan != null &&
                        kehadiran.keterangan!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          kehadiran.keterangan ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada data kehadiran',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk input kehadiran',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month];
  }

  Future<void> _doCheckin() async {
    if (_selectedPengajuanId == null) return;

    final provider = context.read<KehadiranProvider>();
    final layanan = LayananLokasi();

    // 1. Cek Lokasi & Permission
    final posisi = await layanan.ambilLokasiSekarang();
    if (posisi == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengambil lokasi. Pastikan GPS aktif.'),
            backgroundColor: WarnaAplikasi.error,
          ),
        );
      }
      return;
    }

    // 2. Submit dengan Koordinat
    final result = await provider.checkin(
      _selectedPengajuanId!,
      latitude: posisi.latitude,
      longitude: posisi.longitude,
      akurasi: posisi.accuracy,
    );

    if (mounted) {
      if (result != null) {
        String pesan = 'Check-in berhasil';
        if (result.containsKey('jam_keluar')) {
          pesan = 'Check-out berhasil: ${result['jam_keluar']}';
        } else if (result.containsKey('jam_masuk')) {
          pesan = 'Check-in berhasil: ${result['jam_masuk']}';
        }

        // Tampilkan info lokasi jika ada response jarak
        if (result.containsKey('jarak')) {
          pesan += '\nJarak: ${result['jarak']}m dari lokasi instansi';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesan),
            backgroundColor: WarnaAplikasi.success,
          ),
        );
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: WarnaAplikasi.error,
          ),
        );
      }
    }
  }

  void _navigateToInput() {
    Navigator.pushNamed(
      context,
      RuteAplikasi.kehadiranInput,
      arguments: {'id_pengajuan': _selectedPengajuanId},
    ).then((_) {
      if (mounted) {
        // Schedule load to avoid 'during device update' assertion
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Kehadiran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterOption('Semua', null),
                  ...StatusKehadiran.values.map(
                    (s) => _buildFilterOption(s.label, s),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, StatusKehadiran? status) {
    final isSelected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showDetailDialog(Kehadiran kehadiran) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kehadiran.statusKehadiran.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      kehadiran.statusKehadiran.icon,
                      color: kehadiran.statusKehadiran.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kehadiran.tanggalFormatted,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          kehadiran.statusKehadiran.label,
                          style: TextStyle(
                            color: kehadiran.statusKehadiran.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow(
                  Icons.login, 'Jam Masuk', kehadiran.jamMasukFormatted),
              _buildDetailRow(
                  Icons.logout, 'Jam Keluar', kehadiran.jamKeluarFormatted),
              _buildDetailRow(Icons.timer, 'Durasi', kehadiran.durasiFormatted),
              if (kehadiran.keterangan != null)
                _buildDetailRow(
                    Icons.note, 'Keterangan', kehadiran.keterangan!),
              if (kehadiran.lokasiCheckin != null)
                _buildDetailRow(
                    Icons.location_on, 'Lokasi', kehadiran.lokasiCheckin!),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
