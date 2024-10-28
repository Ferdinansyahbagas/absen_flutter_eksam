import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  final DateTime? checkInTime; // jam absen pengguna, null jika belum absen

  AttendanceScreen({this.checkInTime});

  @override
  Widget build(BuildContext context) {
    // Menentukan apakah pengguna absen sebelum atau sesudah jam 8
    bool isBefore8AM = checkInTime != null && checkInTime!.hour < 8;

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Menampilkan gambar berdasarkan jam absen
          Image.asset(
            isBefore8AM ? 'assets/image_left.png' : 'assets/image_right.png',
            width: 200,
            height: 200,
          ),
          
          // Menyembunyikan bagian note jika sudah absen
          if (checkInTime == null) ...[
            SizedBox(height: 20),
            Text(
              'Note: Jangan lupa untuk absen sebelum jam 8!',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
