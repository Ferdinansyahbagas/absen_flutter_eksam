import 'package:flutter/material.dart';
import 'welcome_screen.dart'; // Mengimpor halaman welcome

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange,
            Colors.pink,
            const Color.fromARGB(255, 101, 19, 116),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ), //
      child: Center(
        child: Image.asset(
          'assets/image/logo simbol putih.png', // Ganti dengan path ke gambar Anda
          width: 162.0, // Sesuaikan ukuran lebar
          height: 148.0, // Sesuaikan ukuran tinggi
        ),
      ),
    ));
  }
}