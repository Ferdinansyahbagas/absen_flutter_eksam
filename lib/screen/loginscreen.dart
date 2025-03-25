import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/screen/forpasscreen.dart';
import 'package:absen/screen/welcome_screen.dart';
import 'package:absen/utils/preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absen/service/api_service.dart'; // Import ApiService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _errorMessage;
  String? Id; // Simpan ID WFH jika ada
  bool _showPassword = false;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   saveFirebaseToken();
  // }

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
        await saveAndSendFirebaseToken();
        saveDeviceId(); // Kirim Device ID setelah login

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

  void saveDeviceId() async {
    String? userToken = await Preferences.getToken();

    if (userToken == null) return;

    try {
      // Ambil device ID
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId;

      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // ID perangkat Android
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "Unknown"; // ID perangkat iOS
      }

      final response = await http.post(
        Uri.parse('https://portal.eksam.cloud/api/v1/other/send-device-id'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'device_id': deviceId}),
      );

      if (response.statusCode == 200) {
        print("Device ID berhasil dikirim!");
      } else {
        print("Gagal mengirim Device ID: ${response.body}");
      }
    } catch (e) {
      print("Error mengirim Device ID: $e");
    }
  }

  Future<void> getProfil() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        Id = data['data']['user_level_id'].toString();
      });

      print("Profil pengguna: ${data['data']}");
    } catch (e) {
      print("Error mengambil profil pengguna: $e");
    }
  }

  /// *Menyimpan Token Firebase & Mengirim ke API*
  Future<void> saveAndSendFirebaseToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? tokenFirebase = await messaging.getToken();
    String? userToken = await Preferences.getToken(); // Token user untuk auth

    if (tokenFirebase == null) {
      print("❌ Token Firebase tidak ditemukan!");
      return;
    }

    if (userToken == null) {
      print("❌ Token autentikasi tidak ditemukan!");
      return;
    }

    // Simpan token Firebase ke SharedPreferences
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    await localStorage.setString('firebase_token', tokenFirebase);

    var url = Uri.parse('https://portal.eksam.cloud/api/v1/other/send-token');

    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'firebase_token': tokenFirebase}),
      );

      if (response.statusCode == 200) {
        print("✅ Token Firebase berhasil dikirim ke server!");
      } else {
        print("❌ Gagal mengirim Token Firebase: ${response.body}");
      }
    } catch (e) {
      print("❌ Error saat mengirim Token Firebase: $e");
    }
  }

  // void saveFirebaseToken() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //   String? token = await messaging.getToken();

  //   if (token != null) {
  //     SharedPreferences localStorage = await SharedPreferences.getInstance();
  //     await localStorage.setString('firebase_token', token);
  //     gettoken();
  //   }
  // }

  // Future<void> gettoken() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   String? tokenFirebase = localStorage.getString('firebase_token');
  //   String? userToken =
  //       await Preferences.getToken(); // Ambil token user dari SharedPreferences

  //   if (tokenFirebase == null || tokenFirebase.isEmpty) {
  //     print("Token Firebase tidak ditemukan!");
  //     return;
  //   }

  //   if (userToken == null) {
  //     print("Token autentikasi tidak ditemukan!");
  //     return;
  //   }

  //   var url = Uri.parse('https://portal.eksam.cloud/api/v1/other/send-token');

  //   try {
  //     var response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $userToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'firebase_token': tokenFirebase,
  //         'user_id':
  //             null, // Jika user_id diperlukan, bisa diganti dengan nilai yang sesuai
  //       }),
  //     );

  //     var responseData = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       String message = responseData['message'] ?? 'Sukses';
  //       String updatedToken = responseData['token'] ?? tokenFirebase;

  //       print("✅ Token Firebase berhasil diperbarui!");
  //       print("🔹 Pesan dari server: $message");
  //       print("🔹 Token terbaru: $updatedToken");
  //     } else {
  //       print(
  //           "❌ Gagal memperbarui token Firebase! Status Code: ${response.statusCode}");
  //       print("❌ Response dari server: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("❌ Error saat mengirim token Firebase: $e");
  //   }
  // }
  // Future<void> saveFirebaseToken() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   // Hapus token lama
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   await localStorage.remove('firebase_token');

  //   String? token = await messaging.getToken();
  //   print("🔹 FCM Token didapat: $token");

  //   if (token != null) {
  //     await localStorage.setString('firebase_token', token);
  //     gettoken();
  //   } else {
  //     print("❌ Gagal mendapatkan token Firebase");
  //   }
  // }

  // Future<void> gettoken() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   String? tokenFirebase = localStorage.getString('firebase_token');
  //   String? userToken = await Preferences.getToken();

  //   if (tokenFirebase == null || tokenFirebase.isEmpty) {
  //     print("❌ Token Firebase tidak ditemukan!");
  //     return;
  //   }

  //   if (userToken == null) {
  //     print("❌ Token autentikasi tidak ditemukan!");
  //     return;
  //   }

  //   var url = Uri.parse('https://portal.eksam.cloud/api/v1/other/send-token');

  //   try {
  //     var response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $userToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'firebase_token': tokenFirebase,
  //       }),
  //     );

  //     String? cekToken = await FirebaseMessaging.instance.getToken();
  //     print("🔍 Token setelah logout: $cekToken"); // Harusnya null atau berubah

  //     print("🔹 Response status: ${response.statusCode}");
  //     print("🔹 Response body: ${response.body}");

  //     if (response.statusCode == 200) {
  //       print("✅ Token Firebase berhasil dikirim ke server!");
  //     } else {
  //       print("❌ Gagal memperbarui token Firebase!");
  //     }
  //   } catch (e) {
  //     print("❌ Error saat mengirim token Firebase: $e");
  //   }
  // }
  // void saveFirebaseToken() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   try {
  //     String? token = await messaging.getToken();
  //     if (token == null) {
  //       print("🔴 Gagal mendapatkan token Firebase, mencoba refresh...");
  //       messaging.onTokenRefresh.listen((newToken) async {
  //         await gettoken(newToken);
  //       });
  //       return;
  //     }

  //     await gettoken(token);
  //   } catch (e) {
  //     print("🔴 Error saat mengambil token Firebase: $e");
  //   }
  // }

  // Future<void> gettoken(String token) async {
  //   try {
  //     SharedPreferences localStorage = await SharedPreferences.getInstance();
  //     await localStorage.setString('firebase_token', token);

  //     String? userToken = await Preferences.getToken();
  //     if (userToken == null || userToken.isEmpty) {
  //       print(
  //           "🔴 Token user tidak ditemukan, tidak bisa mengirim Firebase Token!");
  //       return;
  //     }

  //     var url = Uri.parse('https://portal.eksam.cloud/api/v1/other/send-token');
  //     var response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $userToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'firebase_token': token,
  //         'user_id': null, // Bisa diganti jika user_id diperlukan
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       print("✅ Token Firebase berhasil dikirim ke server!");
  //     } else {
  //       print(
  //           "❌ Gagal mengirim token Firebase! Status Code: ${response.statusCode}");
  //       print("❌ Response dari server: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("❌ Error saat mengirim token Firebase: $e");
  //   }
  // }

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
