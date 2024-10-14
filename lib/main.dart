import 'package:flutter/material.dart';
import 'screen/splash_screen.dart'; // Mengimpor SplashScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Halaman pertama adalah SplashScreen
    );
  }
}