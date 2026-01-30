/// Kartu Diperkaya
/// UMPAR Magang & PKL System
///
/// Komponen kartu dengan efek visual premium

import 'package:flutter/material.dart';
import '../../konfigurasi/konstanta.dart';

/// Kartu Gradien dengan efek glassmorphism
class KartuGradien extends StatelessWidget {
  final Widget child;
  final List<Color>? gradienWarna;
  final double radius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const KartuGradien({
    super.key,
    required this.child,
    this.gradienWarna,
    this.radius = 16,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final warna =
        gradienWarna ?? [WarnaAplikasi.primary, WarnaAplikasi.primaryDark];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              colors: warna,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: warna.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Kartu Kaca (Glassmorphism)
class KartuKaca extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets? padding;
  final Color? warnaLatar;
  final VoidCallback? onTap;

  const KartuKaca({
    super.key,
    required this.child,
    this.radius = 16,
    this.padding,
    this.warnaLatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: (warnaLatar ?? Colors.white).withValues(alpha: 0.8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Kartu Status dengan indikator warna
class KartuStatus extends StatelessWidget {
  final String judul;
  final String? deskripsi;
  final IconData ikon;
  final Color warnaStatus;
  final String? labelStatus;
  final VoidCallback? onTap;
  final Widget? trailing;

  const KartuStatus({
    super.key,
    required this.judul,
    this.deskripsi,
    required this.ikon,
    required this.warnaStatus,
    this.labelStatus,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: warnaStatus, width: 4),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: warnaStatus.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(ikon, color: warnaStatus, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (deskripsi != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        deskripsi!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (labelStatus != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: warnaStatus.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    labelStatus!,
                    style: TextStyle(
                      color: warnaStatus,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else if (trailing != null)
                trailing!
              else
                Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu Timeline untuk histori
class KartuTimeline extends StatelessWidget {
  final List<ItemTimeline> items;
  final String? judul;

  const KartuTimeline({
    super.key,
    required this.items,
    this.judul,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (judul != null) ...[
              Text(
                judul!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item.warna,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          color: Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.judul,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (item.deskripsi != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.deskripsi!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                          if (item.waktu != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.waktu!,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Item untuk KartuTimeline
class ItemTimeline {
  final String judul;
  final String? deskripsi;
  final String? waktu;
  final Color warna;

  ItemTimeline({
    required this.judul,
    this.deskripsi,
    this.waktu,
    this.warna = WarnaAplikasi.primary,
  });
}

/// Kartu Aksi Cepat
class KartuAksiCepat extends StatelessWidget {
  final String label;
  final IconData ikon;
  final Color warna;
  final VoidCallback? onTap;

  const KartuAksiCepat({
    super.key,
    required this.label,
    required this.ikon,
    this.warna = WarnaAplikasi.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(ikon, color: warna, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu Notifikasi
class KartuNotifikasi extends StatelessWidget {
  final String judul;
  final String pesan;
  final String waktu;
  final IconData? ikon;
  final Color? warnaIkon;
  final bool sudahDibaca;
  final VoidCallback? onTap;

  const KartuNotifikasi({
    super.key,
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.ikon,
    this.warnaIkon,
    this.sudahDibaca = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: sudahDibaca ? 0 : 2,
      color: sudahDibaca ? Colors.grey[50] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (warnaIkon ?? WarnaAplikasi.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  ikon ?? Icons.notifications,
                  color: warnaIkon ?? WarnaAplikasi.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            judul,
                            style: TextStyle(
                              fontWeight: sudahDibaca
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!sudahDibaca)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: WarnaAplikasi.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pesan,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      waktu,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
