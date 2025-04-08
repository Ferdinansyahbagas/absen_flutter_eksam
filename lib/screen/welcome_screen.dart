import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'loginscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _deviceIdFromServer;

  @override
  void initState() {
    super.initState();
    _checkDeviceLogin();
  }

  Future<void> _checkDeviceLogin() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final localDeviceId =
        localStorage.getString('device_id'); // device id lokal (set saat login)
    final token = localStorage.getString('token');

    if (token == null || localDeviceId == null) {
      _navigateToLogin(); // kalau token atau device_id belum ada, langsung login
      return;
    }

    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] = 'Bearer $token';
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body);

      _deviceIdFromServer = data['data']['device_id'];

      print('Local Device ID: $localDeviceId');
      print('Server Device ID: $_deviceIdFromServer');

      if (_deviceIdFromServer == localDeviceId) {
        _navigateToHome();
      } else {
        // Logout otomatis karena login di device lain
        await localStorage.clear(); // hapus token, device_id, dll
        _navigateToLogin();
      }
    } catch (e) {
      print("Error saat cek device login: $e");
      _navigateToLogin(); // fallback
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
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
                    _navigateToLogin();
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
