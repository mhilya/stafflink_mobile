import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/welcome.dart';
import 'screens/home.dart';
import 'screens/complete_profile.dart';

void main() async {
  // Pastikan binding flutter diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi timezone database
  tz.initializeTimeZones();
  
  // Inisialisasi format tanggal bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StaffLink Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Konfigurasi lokal Indonesia
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
      ],
      // Rute aplikasi
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/complete_profile': (context) => const CompleteProfilePage(),
        '/home': (context) => const TaskManagerScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}