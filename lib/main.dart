import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'views/login/login_view.dart';

// ĐÃ XÓA CÁC DÒNG IMPORT BỊ LỖI Ở ĐÂY

void main() async {
  try {
    // Đảm bảo khởi tạo nền tảng
    WidgetsFlutterBinding.ensureInitialized();

    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Chạy app
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => IncidentProvider()..fetchRealtime()), // Nhớ bỏ cái  đi nhé
        ],
        child: const SmartCityApp(),
      ),
    );
    
  } catch (e, stacktrace) {
    // NẾU CÓ LỖI, NÓ SẼ IN ĐỎ CHÓT RA MÀN HÌNH MÁY TÍNH
    debugPrint('🚨🚨🚨 LỖI KHỞI ĐỘNG Ở HÀM MAIN: $e');
    debugPrint(stacktrace.toString());
  }
}

class SmartCityApp extends StatelessWidget {
  const SmartCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart City Reporting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '/', 
      routes: {
        // Tạm thời trỏ tới các Màn hình giả (Dummy Views) ở bên dưới
        '/': (context) => const LoginView(),             
        '/home': (context) => const DummyHomeView(),           
        '/detail': (context) => const DummyDetailView(),       
        '/create': (context) => const DummyCreateView(), 
        '/my_reports': (context) => const DummyMyReportsView(), 
      },
    );
  }
}

// =========================================================================
// MÀN HÌNH GIẢ (DUMMY VIEWS) - DÙNG TẠM ĐỂ CHẠY APP KHÔNG BỊ CRASH
// CÁC THÀNH VIÊN UI SẼ TỰ TẠO FILE THẬT VÀ SỬA LẠI ROUTES SAU
// =========================================================================

class DummyLoginView extends StatelessWidget {
  const DummyLoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          child: const Text('Đăng nhập giả (Vào Home)'),
        ),
      ),
    );
  }
}

class DummyHomeView extends StatelessWidget {
  const DummyHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Màn hình 1 - Home (TV 2)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/detail'), child: const Text('Tới Detail')),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/create'), child: const Text('Tới Create')),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/my_reports'), child: const Text('Tới My Reports')),
          ],
        ),
      ),
    );
  }
}

class DummyDetailView extends StatelessWidget { const DummyDetailView({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Màn hình 2 - Detail (TV 3)'))); }
class DummyCreateView extends StatelessWidget { const DummyCreateView({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Màn hình 3 - Create (TV 4)'))); }
class DummyMyReportsView extends StatelessWidget { const DummyMyReportsView({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Màn hình 4 - My Reports (TV 5)'))); }