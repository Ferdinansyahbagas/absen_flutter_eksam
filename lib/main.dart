import 'package:absen/screen/loadingwelcome.dart'; // Mengimpor SplashScreen
import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/screen/resetpassScreen.dart';
import 'package:absen/screen/codecekscreen.dart';
import 'package:absen/image_picker_channel.dart';
import 'package:absen/profil/ChagePassPage.dart';

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
