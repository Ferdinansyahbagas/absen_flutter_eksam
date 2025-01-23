import 'package:flutter/material.dart';
import 'package:absen/screen/resetpassScreen.dart';
import 'package:absen/screen/forpasscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Codecekscreen extends StatefulWidget {
  @override
  _CodecekscreenState createState() => _CodecekscreenState();
}

class _CodecekscreenState extends State<Codecekscreen> {
  String? errorMessage;
  String? _errorMessage; // Tambahkan variabel untuk pesan error
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _submit() async {
    try {
      Response response = await post(
        Uri.parse('https://dev-portal.eksam.cloud/api/v1/auth/password/code-check'),
        body: {
          'code': _emailController.text.toString(),
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data['message']);

        // Reset pesan error jika login berhasil
        setState(() {
          _errorMessage = null;
        });
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('code', _emailController.text);

        // Fungsi pindah halaman
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
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
              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
            );
          },
        ),
        title: const Text(
          'Verifikasi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Verifikasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Masukan Code Verifikasi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Verifikasi Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong Masukan Code Verifikasi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  SizedBox(height: 20),
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
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
