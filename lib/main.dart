import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'aplikasi.dart';
import 'provider/auth_provider.dart';
import 'provider/pengajuan_provider.dart';
import 'provider/laporan_provider.dart';
import 'provider/nilai_provider.dart';
import 'provider/users_provider.dart';
import 'provider/notifikasi_provider.dart';
import 'provider/cetak_provider.dart';
import 'provider/instansi_provider.dart';
import 'provider/kehadiran_provider.dart';
import 'provider/bimbingan_provider.dart';
import 'provider/admin_roles_provider.dart';
import 'provider/dashboard_provider.dart';
// import 'provider/pembimbing_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Set orientasi layar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set style status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PengajuanProvider()),
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
        ChangeNotifierProvider(create: (_) => NilaiProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider(create: (_) => CetakProvider()),
        ChangeNotifierProvider(create: (_) => InstansiProvider()),
        ChangeNotifierProvider(create: (_) => KehadiranProvider()),
        ChangeNotifierProvider(create: (_) => BimbinganProvider()),
        ChangeNotifierProvider(create: (_) => AdminRolesProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const Aplikasi(),
    ),
  );
}
