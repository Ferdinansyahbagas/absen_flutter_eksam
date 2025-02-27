//nanti jangan lupa ganti nama filenya
import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/homepage/notif.dart';
import 'package:absen/timeoff/tiimeoff.dart';
import 'package:absen/timeoff/timeoffsick.dart';
import 'package:absen/profil/profilscreen.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:absen/utils/notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeOffScreen extends StatefulWidget {
  const TimeOffScreen({super.key});

  @override
  _TimeOffScreenState createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends State<TimeOffScreen> {
  String? limit;
  List<dynamic> historyData = []; // Tambahkan list untuk menyimpan data history
  List<dynamic> notifications = [];
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    getProfile();
    getHistoryData(); // Panggil fungsi untuk mengambil data history
    getNotif();
  }

  Future<void> getNotif() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/other/get-self-notification');
    var request = http.MultipartRequest('GET', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (rp.statusCode == 200 && data['data'] != null) {
        List<dynamic> loadedNotifications =
            List.from(data['data']).map((notif) {
          return {
            // 'id': notif['id'],
            // 'title': notif['title']?.toString(),
            // 'description': notif['description']?.toString(),
            // 'fileUrl': notif['file'] != null
            //     ? "https://dev-portal.eksam.cloud/storage/file/${notif['file']}"
            //     : null,
            'isRead': notif['isRead'] ?? false,
          };
        }).toList();

        // Cek status dari SharedPreferences
        for (var notif in loadedNotifications) {
          notif['isRead'] = await _isNotificationRead(notif['id']) ||
              notif['isRead']; // Gabungkan status dari API dan lokal
        }

        setState(() {
          notifications = loadedNotifications;
          bool hasUnread = notifications.any((notif) => !notif['isRead']);
          NotificationHelper.setUnreadNotifications(hasUnread); // Simpan status
        });
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {});
    }
  }

  Future<bool> _isNotificationRead(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notif_read_$id') ?? false;
  }

  Future<void> _markNotificationAsRead(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_read_$id', true);
  }

  Future<void> putRead(int id) async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/other/read-notification/$id');
    var request = http.MultipartRequest('PUT', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Tandai sebagai dibaca
        await _markNotificationAsRead(id);

        // Update status unread
        bool hasUnread = notifications.any((notif) => !notif['isRead']);
        await NotificationHelper.setUnreadNotifications(hasUnread);

        setState(() {
          notifications = notifications.map((notif) {
            if (notif['id'] == id) {
              notif['isRead'] = true;
            }
            return notif;
          }).toList();
        });
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getProfile() async {
    {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');

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
          'https://portal.eksam.cloud/api/v1/request-history/get-user-history');
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
        title: const Text(
          'Time Off',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 140,
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 147, 4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Teks di sebelah kiri
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Tengah vertikal
                    children: [
                      Text(
                        'Sisa Cuti Anda \nAdalah',
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
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontSize: 44,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
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
            const SizedBox(height: 30),
            // Apply for Time Off Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 101, 19, 116),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Set Border Radius
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimeOff()),
                ); // Handle Apply for Time Off
              },
              child: const Center(
                  child: Text('Izin Untuk Cuti',
                      style: TextStyle(color: Colors.white))),
            ),

            const SizedBox(height: 10),

            // Apply for Sick Rest Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 101, 19, 116),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Set Border Radius
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimeOffSick()),
                );
                // Handle Apply for Sick Rest
              },
              child: const Center(
                  child: Text('Izin Untuk Sakit',
                      style: TextStyle(color: Colors.white))),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16.0),
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
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 81, 109),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item['startdate'] ?? ''} - \n ${item['enddate'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // Catatan atau deskripsi
                        Text(
                          item['notes']?.toString() ?? 'No reason provided',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Status pengajuan
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 110),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              item['status']['name']?.toString() ??
                                  'Unknown Status',
                              style: const TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
        items: [
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'), // Custom icon
              size: 18,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/timeoff.png'), // Custom icon
              size: 22,
              color: Colors.orange,
            ),
            label: 'Time Off',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt, size: 25),
            label: 'Reimbursement',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const ImageIcon(
                  AssetImage('assets/icon/notifikasi.png'),
                  size: 20,
                  color: Colors.white,
                ),
                FutureBuilder<bool>(
                  future: NotificationHelper.hasUnreadNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return const Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 10,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            label: 'Notification',
          ),
          const BottomNavigationBarItem(
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false, // Menghapus semua halaman sebelumnya
      );
      break;
    case 1:
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => const TimeOffScreen()),
      //   (route) => false,
      // );
      break;
    case 2:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ReimbursementPage()),
        (route) => false,
      );
      break;
    case 3:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NotificationPage()),
        (route) => false,
      );
      break;
    case 4:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
        (route) => false,
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

  const TimeOffCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.pink[400],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(description),
            const SizedBox(height: 5),
            Text(date,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(status, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
