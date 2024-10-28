import 'package:flutter/material.dart';
import 'loginscreen.dart';

class WelcomeScreen extends StatelessWidget {
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
        ), //, // Warna latar belakang ungu
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Welcome',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Log in first before you join us ✨',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
              ),
            ),
            SizedBox(height: 200),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen())); // Aksi saat tombol login ditekan
                  },
                  //http://127.0.0.1:8000/API/V1/auth/login
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFBD73), // Warna tombol
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
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
