import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'loginscreen.dart';
import 'package:absen/utils/preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // bool _hasToken = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _checkToken();
  // }

  // void _checkToken() async {
  //   String? token = await Preferences.getToken();
  //   if (token != null) {
  //     // Jika token tersedia, set state
  //     setState(() {
  //       _hasToken = true;
  //     });
  //   }
  // }

  bool _hasDeviceId = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceId();
  }

  // ✅ Cek apakah device ID tersedia di API
  void _checkDeviceId() async {
    String? token = await Preferences.getToken(); // Ambil token dari storage

    try {
      final response = await http.get(
        Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profil'),
        headers: {
          'Authorization': 'Bearer $token', // Kirim token di header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        bool hasDeviceId = data['device_id'] != null;

        setState(() {
          _hasDeviceId = hasDeviceId;
        });

        print("✅ Device ID ditemukan: ${data['device_id']}");
      } else {
        print("⚠️ Gagal mendapatkan Device ID: ${response.body}");
      }
    } catch (e) {
      print("❌ Error mendapatkan Device ID: $e");
    }
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
        ), //, // Warna latar belakang ungu
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const Text(
              'Hi,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Selamat Datang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Silakan Login Terlebih Dahulu Sebelum Masuk✨',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 200),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_hasDeviceId) {
                      // Jika token ada, langsung ke HomePage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    } else {
                      // Jika tidak ada token, ke LoginScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBD73), // Warna tombol
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
