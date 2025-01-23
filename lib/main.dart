import 'package:flutter/material.dart';
import 'package:absen/screen/loadingwelcome.dart'; // Mengimpor SplashScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Halaman pertama adalah SplashScreen
    );
  }
}
