import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absen App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasClockedIn = false; // Status apakah sudah clock-in
  bool isSuccess = false; // Status card sukses
  bool isLate = false; // Status card terlambat
  bool isOnLeave = false; // Status cuti
  bool showNote = true; // Status untuk Note
  DateTime? lastResetTime;

  @override
  void initState() {
    super.initState();
    _checkResetTime();
    _checkClockInStatus();
  }

  void _checkResetTime() {
    final now = DateTime.now();
    if (lastResetTime == null || now.difference(lastResetTime!).inHours >= 24 || now.hour >= 5) {
      setState(() {
        // Reset semua status setiap pukul 5 pagi
        isSuccess = false;
        isLate = false;
        isOnLeave = false;
        showNote = true;
        hasClockedIn = false;
        lastResetTime = now;
      });
    }
  }

  Future<void> _checkClockInStatus() async {
    // Cek status clock-in dan cuti
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/attendance/is-clock-in');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        hasClockedIn = data['message'] != 'belum clock-in';

        // Jika user sedang cuti
        if (data['is_on_leave'] == true) {
          isOnLeave = true;
          isSuccess = false;
          isLate = false;
          showNote = false;
        } else if (hasClockedIn) {
          showNote = false;

          // Cek jam clock-in
          final clockInTime = DateTime.parse(data['clock_in_time']);
          if (clockInTime.hour < 8) {
            isSuccess = true; // Absen sukses sebelum jam 8 pagi
            isLate = false;
          } else {
            isLate = true; // Absen terlambat setelah jam 8 pagi
            isSuccess = false;
          }
        }
      });
    } catch (e) {
      print("Error mengecek status clock-in: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showNote)
            Card(
              color: Colors.blue[50],
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Note: Please clock in to start your work.',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isSuccess)
            Card(
              color: Colors.orange,
              elevation: 5,
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '✨ Your Absence Was Successful ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Good work and keep up the spirit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          if (isLate)
            Card(
              color: Colors.red,
              elevation: 5,
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '💥 You’re Late! Let’s In Now 💥',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'How can you be absent late?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          if (isOnLeave)
            Card(
              color: Colors.green,
              elevation: 5,
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🌴 You’re on Leave 🌴',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Enjoy your time off!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ElevatedButton(
            onPressed: _checkClockInStatus,
            child: Text('Refresh Status'),
          ),
        ],
      ),
    );
  }
}