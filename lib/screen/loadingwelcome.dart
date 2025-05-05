import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Tambahkan import ini
import 'welcome_screen.dart'; // Mengimpor halaman welcome

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Cek lokasi saat splash screen
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _navigateToWelcome(); // Tetap lanjut meskipun lokasi tidak aktif
      return;
    }

    // Cek dan minta izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _navigateToWelcome();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _navigateToWelcome();
      return;
    }

    // Jika sudah mendapatkan izin, lanjutkan
    _navigateToWelcome();
  }

  void _navigateToWelcome() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange,
              Colors.pink,
              Color.fromARGB(255, 101, 19, 116),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/image/logo simbol putih.png',
            width: 162.0,
            height: 148.0,
          ),
        ),
      ),
    );
  }
}
