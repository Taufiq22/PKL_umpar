import 'package:flutter/material.dart';
import 'konfigurasi/tema.dart';
import 'konfigurasi/rute.dart';
import 'konfigurasi/konstanta.dart';

/// Widget utama aplikasi MagangKu
class Aplikasi extends StatelessWidget {
  const Aplikasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TeksAplikasi.namaAplikasi,
      debugShowCheckedModeBanner: false,
      theme: TemaAplikasi.tema,
      initialRoute: RuteAplikasi.ruteAwal,
      onGenerateRoute: RuteAplikasi.generateRoute,
    );
  }
}
