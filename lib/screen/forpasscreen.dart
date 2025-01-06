import 'package:absen/screen/loginscreen.dart';
import 'package:absen/screen/codecekscreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String? errorMessage;
  String? _errorMessage; // Tambahkan variabel untuk pesan error
  bool _isEmailValid = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _submit() async {
    if (!_isEmailValid) {
      setState(() {
        _errorMessage = 'Email tidak sesuai format yang diharapkan';
      });
      return;
    }

    try {
      Response response = await post(
        Uri.parse('https://dev-portal.eksam.cloud/api/v1/auth/password/email'),
        body: {
          'email': _emailController.text.toString(),
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data['message']);

        // Reset pesan error jika login berhasil
        setState(() {
          _errorMessage = null;
        });

        // Fungsi pindah halaman
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Codecekscreen()),
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
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
        title: const Text(
          'Forgot Password',
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
              'Forgot Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Enter your registered email',
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
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      errorText: !_isEmailValid
                          ? 'Email tidak sesuai format yang diharapkan'
                          : _errorMessage,
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        // Memeriksa apakah email sesuai format
                        _isEmailValid = RegExp(r'\S+@\S+\.\S+').hasMatch(value);
                      });
                    },
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
