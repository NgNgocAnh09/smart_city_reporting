import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'views/login/login_view.dart';
import 'views/home/home_view.dart';
import 'views/create_report/create_report_view.dart';
import 'views/detail/detail_view.dart';
import 'views/my_reports/my_reports_view.dart'; // NHỚ IMPORT FILE THẬT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()..fetchRealtime()),
      ],
      child: const SmartCityApp(),
    ),
  );
}

class SmartCityApp extends StatelessWidget {
  const SmartCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
        '/detail': (context) => const DetailView(),
        '/create': (context) => const CreateReportView(),
        '/my_reports': (context) => const MyReportsView(), // SỬA: Dùng màn hình thật
      },
    );
  }
}