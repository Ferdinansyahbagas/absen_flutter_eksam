import 'loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _deviceIdFromServer;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceLogin();
  }

  Future<void> _checkDeviceLogin() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final localDeviceId = localStorage.getString('device_id');
    final token = localStorage.getString('token');

    print('Cek token dan device_id...');
    print('Token: $token');
    print('Local Device ID: $localDeviceId');

    if (token == null || localDeviceId == null) {
      print('Belum login. Tunggu user tekan tombol login.');
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
      print('Server Device ID: $_deviceIdFromServer');

      if (_deviceIdFromServer == localDeviceId) {
        print('Device cocok. User sudah login.');
        setState(() {
          _isLoggedIn = true;
        });
      } else {
        print('Device tidak cocok. Clear data.');
        await localStorage.clear();
      }
    } catch (e) {
      print("Terjadi error saat cek device login: $e");
    }
  }

  void _handleLoginPressed() {
    if (_isLoggedIn) {
      print('Auto-login ke HomePage.');
      _navigateToHome();
    } else {
      print('User belum login, arahkan ke LoginScreen.');
      _navigateToLogin();
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
        ),
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
                  onPressed: _handleLoginPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBD73),
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
