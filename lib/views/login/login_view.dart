import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isLoading = false; // Biến kiểm soát trạng thái chờ

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true); // Bật vòng xoay loading
    try {
      // Gọi hàm đăng nhập từ AuthProvider
      await context.read<AuthProvider>().signInWithGoogle();
      
      // Đăng nhập thành công -> Chuyển sang màn hình Home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Đăng nhập thất bại -> Báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thất bại. Vui lòng thử lại!')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Tắt vòng xoay loading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Có thể thay Icon này bằng Logo thật của dự án
              const Icon(Icons.location_city, size: 100, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Smart City Reporting',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cùng nhau xây dựng thành phố tốt đẹp hơn',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              
              // Nút Đăng nhập
              _isLoading
                  ? const CircularProgressIndicator() // Đang tải thì hiện vòng xoay
                  : ElevatedButton.icon(
                      onPressed: _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'Đăng nhập bằng Google',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}