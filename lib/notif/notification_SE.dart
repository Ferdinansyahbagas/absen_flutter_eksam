import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/screen/forpasscreen.dart';
import 'package:absen/screen/welcome_screen.dart';
import 'package:absen/utils/preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _errorMessage;
  bool _showPassword = false;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _login() {
    setState(() {
      _isEmailValid = _emailController.text.contains('@');
      _isPasswordValid = _passwordController.text.length >= 6;

      if (_isEmailValid && _isPasswordValid) {
        _isLoading = true;
        login2();
      }
    });
  }

  void login2() async {
    try {
      final response = await http.post(
        Uri.parse('https://portal.eksam.cloud/api/v1/auth/login'),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String token = data['data']['token'];

        // Simpan token ke SharedPreferences
        await Preferences.setToken(token);

        // Simpan token Firebase
        saveFirebaseToken();

        // Pindah ke halaman Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } else {
        var data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Terjadi kesalahan. Coba lagi nanti.";
      });
    }
  }

  void saveFirebaseToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    String? userToken = await Preferences.getToken();

    if (fcmToken != null && userToken != null) {
      try {
        final response = await http.post(
          Uri.parse('https://portal.eksam.cloud/api/v1/auth/save-token'),
          headers: {
            'Authorization': 'Bearer $userToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'firebase_token': fcmToken}),
        );

        if (response.statusCode == 200) {
          print("FCM Token berhasil disimpan!");
        } else {
          print("Gagal menyimpan FCM Token: ${response.body}");
        }
      } catch (e) {
        print("Error menyimpan FCM Token: $e");
      }
    } else {
      print("FCM Token atau User Token tidak tersedia");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          },
        ),
        title: const Text(
          'Log In',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Silakan Login Terlebih Dahulu Sebelum Masuk✨",
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    errorText: _isEmailValid ? null : 'Email tidak valid',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    errorText:
                        _isPasswordValid ? null : 'Password minimal 6 karakter',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 32.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.pink, Colors.purple],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text('Forgot Your Password?'),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
