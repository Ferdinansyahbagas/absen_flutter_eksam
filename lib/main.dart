import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:absen/firebase_api.dart';
import 'package:absen/screen/loadingwelcome.dart'; // SplashScreen
import 'package:absen/utils/device_utils.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initialize();
  await DeviceUtils.initializeDeviceId(); // Panggil fungsi dari DeviceUtils

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
      home: const SplashScreen(), // Halaman pertama adalah SplashScreen
    );
  }
}