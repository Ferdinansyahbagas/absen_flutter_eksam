import 'package:flutter/material.dart';
import 'login_screen.dart'; // Mengimpor halaman login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF5B2284), // Warna latar belakang ungu
      body: Center(
        child: Icon(
          Icons.alternate_email, // Menggunakan ikon 'e'
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }
}