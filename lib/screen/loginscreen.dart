import 'package:absen/homepage/home.dart';
import 'package:absen/screen/forpasscreen.dart';
import 'package:absen/screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  String? _errorMessage; // Tambahkan variabel untuk pesan error

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _login() {
    setState(() {
      // Validasi sederhana
      _isEmailValid = _emailController.text.contains('@');
      _isPasswordValid = _passwordController.text.length >= 6;

      if (_isEmailValid && _isPasswordValid) {
        // Jika login berhasil, Anda bisa menambahkan logika di sini
        login2();
      }
    });
  }

  void login2() async {
    try {
      Response response = await post(
        Uri.parse('https://dev-portal.eksam.cloud/api/v1/auth/login'),
        body: {
          'email': _emailController.text.toString(),
          'password': _passwordController.text.toString(),
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data['data']['token']);

        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', data['data']['token']);
        // Reset pesan error jika login berhasil
        setState(() {
          _errorMessage = null;
        });

        // Fungsi pindah halaman
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TimeOffScreen()),
        );
      } else {
        var data = jsonDecode(response.body.toString());
        setState(() {
          _errorMessage = data['message']; // Set pesan error dari server
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _errorMessage =
            "Terjadi kesalahan. Coba lagi nanti."; // Pesan error umum
      });
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
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            ); // Aksi kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'Log In',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "log in",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              "Log in first before you join us ✨",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.0),
            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                errorText: _isEmailValid ? null : 'Email tidak valid',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
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
            SizedBox(height: 16.0),
            // Tampilkan pesan error jika ada
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 32.0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.pink, Colors.purple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.0),
            Align(
                alignment: Alignment.center,
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()));
                    },
                    child: const Text('Forgot Your Password?'))),
          ],
        ),
      ),
    );
  }
}
