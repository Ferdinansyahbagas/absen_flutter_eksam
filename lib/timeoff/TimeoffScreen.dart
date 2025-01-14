//nanti jangan lupa ganti nama filenya
import 'package:flutter/material.dart';
import 'package:absen/homepage/notif.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/profil/profilscreen.dart';
import 'package:absen/timeoff/tiimeoff.dart';
import 'package:absen/timeoff/timeoffsick.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimeOffScreen extends StatefulWidget {
  @override
  _TimeOffScreenState createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends State<TimeOffScreen> {
  String? limit;
  List<dynamic> historyData = []; // Tambahkan list untuk menyimpan data history

  @override
  void initState() {
    super.initState();
    getProfile();
    getHistoryData(); // Panggil fungsi untuk mengambil data history
  }

  Future<void> getProfile() async {
    {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/karyawan/get-profile');

      var request = http.MultipartRequest('GET', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());
      print(data);

      if (rp.statusCode == 200) {
        try {
          var data = jsonDecode(rp.body); // Decode JSON
          print('Parsed Data: $data');
          setState(() {
            limit =
                data['data']?['batas_cuti']?.toString() ?? '0'; // Validasi key
          });
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          localStorage.setString('id', data['data']?['id'] ?? '');
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      } else {
        print('Error retrieving profile: ${rp.statusCode}');
        print(rp.body);
      }
    }
  }

  Future<void> getHistoryData() async {
    {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/request-history/get-user-history');
      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        try {
          var data = jsonDecode(rp.body); // Decode JSON
          print('Parsed Data: $data');
          setState(() {
            historyData = data['data'] ?? []; // Validasi key
          });
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      } else {
        print('Error fetching history data: ${rp.statusCode}');
        print(rp.body);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Time Off',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remaining Leave
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 140,
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 147, 4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Teks di sebelah kiri
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Tengah vertikal
                    children: [
                      Text(
                        'Your Remaining\nLeave Is',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Angka di sebelah kanan
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline
                          .alphabetic, // Menambahkan baseline agar teks sejajar
                      children: [
                        Text(
                          limit.toString(),
                          style: TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontSize: 44,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '12',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Apply for Time Off Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 101, 19, 116),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Set Border Radius
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimeOff()),
                ); // Handle Apply for Time Off
              },
              child: Center(
                  child: Text('Apply for Time Off',
                      style: TextStyle(color: Colors.white))),
            ),

            SizedBox(height: 10),

            // Apply for Sick Rest Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 101, 19, 116),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Set Border Radius
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimeOffSick()),
                );
                // Handle Apply for Sick Rest
              },
              child: Center(
                  child: Text('Apply For Sick Rest',
                      style: TextStyle(color: Colors.white))),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'History Time Off',
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Time Off Request Card
            Expanded(
              child: ListView.builder(
                itemCount: historyData.length,
                itemBuilder: (context, index) {
                  final item = historyData[index] as Map<String, dynamic>;
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 236, 81, 109),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header dengan judul tipe dan tanggal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['type']['name']?.toString() ??
                                  'Unknown Type', // Hanya menampilkan nama tipe
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item['startdate'] ?? ''} - \n ${item['enddate'] ?? ''}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // Catatan atau deskripsi
                        Text(
                          item['notes']?.toString() ?? 'No reason provided',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Status pengajuan
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 120),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              item['status']['name']?.toString() ??
                                  'Unknown Status',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'), // Custom icon
              size: 18,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/timeoff.png'), // Custom icon
              size: 22,
              color: Colors.orange,
            ),
            label: 'Time Off',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, size: 25),
            label: 'Reimbursement',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/notifikasi.png'), // Custom icon
              size: 20,
              color: Colors.white,
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/profil.png'), // Custom icon
              size: 20,
              color: Colors.white,
            ),
            label: 'Profil',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 101, 19, 116),
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 9),
        currentIndex: 1,
        onTap: (index) {
          // Handle bottom navigation bar tap
          // Navigate to the appropriate screen
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => TimeOffScreen()),
              // );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReimbursementPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}

class TimeOffCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String status;

  TimeOffCard({
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(description),
            SizedBox(height: 5),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 10),
            Text(status, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      color: Colors.pink[400],
    );
  }
}
