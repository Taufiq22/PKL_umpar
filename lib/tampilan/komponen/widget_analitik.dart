/// Widget Analitik
/// UMPAR Magang & PKL System
///
/// Komponen widget untuk chart dan statistik dashboard

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../konfigurasi/konstanta.dart';

/// Widget Chart Lingkaran untuk menampilkan distribusi data
class ChartLingkaran extends StatelessWidget {
  final Map<String, int> data;
  final Map<String, Color> warna;
  final String judul;
  final double ukuran;
  final bool tampilkanLegenda;

  const ChartLingkaran({
    super.key,
    required this.data,
    required this.warna,
    required this.judul,
    this.ukuran = 150,
    this.tampilkanLegenda = true,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: ukuran,
                  height: ukuran,
                  child: CustomPaint(
                    painter: _PieChartPainter(data: data, warna: warna),
                  ),
                ),
                if (tampilkanLegenda) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.entries.map((e) {
                        final persen =
                            (e.value / total * 100).toStringAsFixed(1);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: warna[e.key] ?? Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Text(
                                '${e.value} ($persen%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Icon(Icons.pie_chart, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text('Belum ada data', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

/// Painter untuk Pie Chart
class _PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final Map<String, Color> warna;

  _PieChartPainter({required this.data, required this.warna});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;

    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      paint.color = warna[entry.key] ?? Colors.grey;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Widget Bar Chart Horizontal
class ChartBarHorizontal extends StatelessWidget {
  final Map<String, int> data;
  final Color warnaPrimary;
  final String judul;

  const ChartBarHorizontal({
    super.key,
    required this.data,
    this.warnaPrimary = WarnaAplikasi.primary,
    required this.judul,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = data.values.isEmpty ? 1 : data.values.reduce(math.max);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              Center(
                child: Text(
                  'Belum ada data',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              )
            else
              ...data.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                e.key,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              e.value.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: warnaPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: e.value / maxValue,
                            minHeight: 8,
                            backgroundColor: warnaPrimary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(warnaPrimary),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

/// Widget Kartu Statistik dengan ikon dan trend
class KartuStatistik extends StatelessWidget {
  final String judul;
  final String nilai;
  final IconData ikon;
  final Color warna;
  final String? subJudul;
  final double? trendPersen;
  final bool trendNaik;

  const KartuStatistik({
    super.key,
    required this.judul,
    required this.nilai,
    required this.ikon,
    this.warna = WarnaAplikasi.primary,
    this.subJudul,
    this.trendPersen,
    this.trendNaik = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [warna, warna.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(ikon, color: Colors.white, size: 24),
                ),
                if (trendPersen != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendNaik ? Icons.trending_up : Icons.trending_down,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trendPersen!.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              nilai,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              judul,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            if (subJudul != null) ...[
              const SizedBox(height: 2),
              Text(
                subJudul!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget Progress Mingguan
class ProgressMingguan extends StatelessWidget {
  final List<int> dataMingguan; // 7 hari
  final String judul;
  final Color warna;

  const ProgressMingguan({
    super.key,
    required this.dataMingguan,
    required this.judul,
    this.warna = WarnaAplikasi.primary,
  });

  @override
  Widget build(BuildContext context) {
    final hariList = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final maxValue = dataMingguan.isEmpty ? 1 : dataMingguan.reduce(math.max);

    // Pad data to 7 days if needed
    final data = List<int>.from(dataMingguan);
    while (data.length < 7) {
      data.add(0);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final tinggi = maxValue > 0 ? (data[i] / maxValue * 80) : 0.0;
                  final isHariIni = i == DateTime.now().weekday - 1;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        data[i].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isHariIni ? warna : Colors.grey[600],
                          fontWeight:
                              isHariIni ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: tinggi.clamp(4.0, 80.0),
                        decoration: BoxDecoration(
                          color: isHariIni ? warna : warna.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hariList[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: isHariIni ? warna : Colors.grey[600],
                          fontWeight:
                              isHariIni ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget Ring Progress
class RingProgress extends StatelessWidget {
  final double persentase;
  final String label;
  final Color warna;
  final double ukuran;

  const RingProgress({
    super.key,
    required this.persentase,
    required this.label,
    this.warna = WarnaAplikasi.primary,
    this.ukuran = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: ukuran,
          height: ukuran,
          child: Stack(
            children: [
              SizedBox(
                width: ukuran,
                height: ukuran,
                child: CircularProgressIndicator(
                  value: persentase / 100,
                  strokeWidth: 10,
                  backgroundColor: warna.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(warna),
                ),
              ),
              Center(
                child: Text(
                  '${persentase.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: ukuran / 5,
                    fontWeight: FontWeight.bold,
                    color: warna,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
