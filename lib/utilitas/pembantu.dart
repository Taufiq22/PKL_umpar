/// Utilitas Pembantu
/// UMPAR Magang & PKL System
///
/// Helper functions dan utilities

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pembantu Format Tanggal
class FormatTanggal {
  static final DateFormat _formatPendek = DateFormat('dd/MM/yyyy');
  static final DateFormat _formatPanjang = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _formatWaktu = DateFormat('HH:mm');
  static final DateFormat _formatLengkap =
      DateFormat('dd MMMM yyyy HH:mm', 'id_ID');

  /// Format tanggal singkat: 01/01/2024
  static String pendek(DateTime? tanggal) {
    if (tanggal == null) return '-';
    return _formatPendek.format(tanggal);
  }

  /// Format tanggal panjang: 01 Januari 2024
  static String panjang(DateTime? tanggal) {
    if (tanggal == null) return '-';
    return _formatPanjang.format(tanggal);
  }

  /// Format waktu: 14:30
  static String waktu(DateTime? tanggal) {
    if (tanggal == null) return '-';
    return _formatWaktu.format(tanggal);
  }

  /// Format lengkap: 01 Januari 2024 14:30
  static String lengkap(DateTime? tanggal) {
    if (tanggal == null) return '-';
    return _formatLengkap.format(tanggal);
  }

  /// Format relatif: Baru saja, 5 menit lalu, dll
  static String relatif(DateTime? tanggal) {
    if (tanggal == null) return '-';

    final now = DateTime.now();
    final diff = now.difference(tanggal);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} minggu lalu';
    } else {
      return pendek(tanggal);
    }
  }

  /// Nama hari dalam bahasa Indonesia
  static String namaHari(DateTime? tanggal) {
    if (tanggal == null) return '-';
    const hari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    return hari[tanggal.weekday % 7];
  }

  /// Nama bulan dalam bahasa Indonesia
  static String namaBulan(int bulan) {
    const bulanList = [
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
    return bulanList[bulan.clamp(1, 12)];
  }
}

/// Pembantu Validasi
class Validasi {
  /// Validasi email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validasi tidak kosong
  static String? wajibDiisi(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }
    return null;
  }

  /// Validasi angka
  static String? angka(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Field'} harus berupa angka';
    }
    return null;
  }

  /// Validasi nomor telepon
  static String? telepon(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (value.length < 10 || value.length > 15) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }
}

/// Pembantu Snackbar
class TampilkanPesan {
  /// Tampilkan snackbar sukses
  static void sukses(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(pesan)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Tampilkan snackbar error
  static void error(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(pesan)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Tampilkan snackbar info
  static void info(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(pesan)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Tampilkan snackbar warning
  static void peringatan(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(pesan)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Pembantu Dialog
class TampilkanDialog {
  /// Dialog konfirmasi
  static Future<bool?> konfirmasi(
    BuildContext context, {
    required String judul,
    required String pesan,
    String labelYa = 'Ya',
    String labelTidak = 'Batal',
    Color? warnaYa,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(judul),
        content: Text(pesan),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(labelTidak),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: warnaYa ?? Colors.red,
            ),
            child: Text(labelYa),
          ),
        ],
      ),
    );
  }

  /// Dialog loading
  static void loading(BuildContext context, {String pesan = 'Memuat...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Text(pesan),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Tutup dialog loading
  static void tutupLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Extension untuk String
extension StringExtension on String {
  /// Kapitalisasi kata pertama
  String kapital() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Kapitalisasi setiap kata
  String kapitalSemuaKata() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.kapital()).join(' ');
  }

  /// Truncate dengan ellipsis
  String potong(int panjang) {
    if (length <= panjang) return this;
    return '${substring(0, panjang)}...';
  }
}

/// Extension untuk List
extension ListExtension<T> on List<T> {
  /// Safe get element at index
  T? ambil(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
