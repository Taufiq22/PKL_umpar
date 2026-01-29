import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/nilai.dart';
import '../../../provider/nilai_provider.dart';
import '../../komponen/empty_state.dart';

/// Halaman daftar nilai - UI/UX Upgraded
class NilaiListHalaman extends StatefulWidget {
  final int? idPengajuan;

  const NilaiListHalaman({super.key, this.idPengajuan});

  @override
  State<NilaiListHalaman> createState() => _NilaiListHalamanState();
}

class _NilaiListHalamanState extends State<NilaiListHalaman>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.idPengajuan != null) {
        context.read<NilaiProvider>().ambilNilai(widget.idPengajuan!);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<NilaiProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.daftarNilai.isEmpty) {
            return const EmptyState.nilai();
          }

          final nilaiGabungan = provider.hitungNilaiGabungan();
          final grade = _getGrade(nilaiGabungan ?? 0);

          return CustomScrollView(
            slivers: [
              // Gradient Header with Score
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
                        children: [
                          Row(
                            children: [
                              if (Navigator.canPop(context))
                                IconButton(
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                ),
                              const SizedBox(width: 8),
                              Text(
                                'Nilai Saya',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Animated Score Card
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withAlpha(50),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'RATA-RATA NILAI',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Colors.white70,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        nilaiGabungan?.toStringAsFixed(1) ??
                                            '-',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          grade,
                                          style: const TextStyle(
                                            color: WarnaAplikasi.primary,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(30),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getGradeMessage(grade),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                    // Nilai dari Pembimbing
                    if (provider.nilaiPembimbing.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Nilai dari Pembimbing',
                        Icons.school,
                        '${provider.nilaiPembimbing.length} aspek',
                      ),
                      ...provider.nilaiPembimbing
                          .map((n) => _buildModernNilaiCard(n)),
                      const SizedBox(height: 20),
                    ],

                    // Nilai dari Instansi
                    if (provider.nilaiInstansi.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Nilai dari Instansi',
                        Icons.business,
                        '${provider.nilaiInstansi.length} aspek',
                      ),
                      ...provider.nilaiInstansi
                          .map((n) => _buildModernNilaiCard(n)),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: WarnaAplikasi.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: WarnaAplikasi.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WarnaAplikasi.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNilaiCard(Nilai nilai) {
    final valueColor = _getValueColor(nilai.nilaiAngka);
    final percentage = nilai.nilaiAngka / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nilai.aspekPenilaian ?? 'Aspek Penilaian',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (nilai.komentar != null && nilai.komentar!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          nilai.komentar!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: WarnaAplikasi.textSecondary,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: valueColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      nilai.nilaiAngka.toStringAsFixed(0),
                      style: TextStyle(
                        color: valueColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: valueColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        nilai.grade,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(valueColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(double value) {
    if (value >= 80) return WarnaAplikasi.success;
    if (value >= 60) return WarnaAplikasi.warning;
    return WarnaAplikasi.error;
  }

  String _getGrade(double nilai) {
    if (nilai >= 85) return 'A';
    if (nilai >= 80) return 'A-';
    if (nilai >= 75) return 'B+';
    if (nilai >= 70) return 'B';
    if (nilai >= 65) return 'B-';
    if (nilai >= 60) return 'C+';
    if (nilai >= 55) return 'C';
    if (nilai >= 50) return 'D';
    return 'E';
  }

  String _getGradeMessage(String grade) {
    switch (grade) {
      case 'A':
        return '🌟 Sangat Baik Sekali';
      case 'A-':
        return '⭐ Sangat Baik';
      case 'B+':
        return '👍 Baik Sekali';
      case 'B':
        return '👌 Baik';
      case 'B-':
        return '✓ Cukup Baik';
      case 'C+':
        return 'Cukup';
      case 'C':
        return 'Sedang';
      default:
        return 'Perlu Perbaikan';
    }
  }
}
