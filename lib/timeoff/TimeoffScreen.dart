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
import 'package:absen/service/api_service.dart'; // Import ApiService

class TimeOffScreen extends StatefulWidget {
  const TimeOffScreen({super.key});

  @override
  _TimeOffScreenState createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends State<TimeOffScreen> {
  String? limit;
  List<dynamic> historyData = []; // Tambahkan list untuk menyimpan data history
  List<dynamic> notifications = [];
  List<Map<String, dynamic>> quotaData = [];
  bool hasUnreadNotifications = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getProfile();
    getHistoryData(); // Panggil fungsi untuk mengambil data history
    getNotif();
    getDatakuota();
  }

  // fungsi untuk memanggil bacaan notifikasi
  Future<void> getNotif() async {
    var data =
        await ApiService.sendRequest(endpoint: "other/get-self-notification");
    if (data == null || data['data'] == null) return;

    List<dynamic> loadedNotifications = List.from(data['data']).map((notif) {
      return {
        'id': notif['id'],
        'isRead': notif['isRead'] ?? false,
      };
    }).toList();

    for (var notif in loadedNotifications) {
      notif['isRead'] =
          await _isNotificationRead(notif['id']) || notif['isRead'];
    }

    setState(() {
      notifications = loadedNotifications;
      hasUnreadNotifications = notifications.any((notif) => !notif['isRead']);
    });
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
    var response = await ApiService.sendRequest(
        endpoint: "other/read-notification/$id", method: 'PUT');
    if (response != null) {
      await _markNotificationAsRead(id);
      setState(() {
        notifications = notifications.map((notif) {
          if (notif['id'] == id) notif['isRead'] = true;
          return notif;
        }).toList();
        hasUnreadNotifications = notifications.any((notif) => !notif['isRead']);
      });
    }
  }

  Future<void> getDatakuota() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/request-history/get-self-kuota');
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${localStorage.getString('token')}',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Response API Kuota: ${jsonEncode(data)}");

        if (data['data'] == null || (data['data'] as List).isEmpty) {
          setState(() {
            quotaData = [];
          });
          return;
        }

        List<Map<String, dynamic>> parsedQuota = [];

        for (var item in data['data']) {
          parsedQuota.add({
            "type": item['type']['name'],
            "remaining": item['kuota'],
            "max": item['type']['max_quota'],
          });
        }

        setState(() {
          quotaData = parsedQuota;
        });
      } else {
        print('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> deleteCuti(String id) async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/request-history/cancel-request/$id');

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final token = localStorage.getString('token');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Berhasil: $data');
        getHistoryData();
      } else {
        var errorData = jsonDecode(response.body);
        print('Gagal: ${errorData['message']}');
      }
    } catch (e) {
      print('Error saat mengirim request: $e');
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
    setState(() {
      isLoading = true;
    });
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
          print('Terjadi kesalahan saat fetchInventory: $e');
        } finally {
          setState(() {
            isLoading = false;
          });
        }
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
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Detail Kuota Cuti'),
                      content: SizedBox(
                        // Batasi tinggi maksimal agar tidak overflow
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: double.maxFinite,
                        child: quotaData.isNotEmpty
                            ? SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: quotaData.map((data) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${data['type']}'),
                                      subtitle: Text(
                                        'Sisa: ${data['remaining']}/${data['max']} hari',
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : const Center(
                                child: Text('Tidak ada data kuota tersedia.'),
                              ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Tutup'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 140,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 25.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 147, 4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : historyData.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada history time off",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: historyData.length,
                          itemBuilder: (context, index) {
                            final item =
                                historyData[index] as Map<String, dynamic>;
                            final statusName =
                                item['status']['name']?.toString() ?? '';
                            final requestId = item['id'].toString();

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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['type']['name']?.toString() ??
                                            'Unknown Type',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
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
                                  Text(
                                    item['notes']?.toString() ??
                                        'No reason provided',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Text(
                                        statusName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (statusName.toLowerCase() ==
                                      'pending') ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.center,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          deleteCuti(requestId);
                                        },
                                        icon: const Icon(Icons.cancel),
                                        label: const Text("Batalkan"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.pink,
                                          minimumSize: const Size(
                                              double.infinity,
                                              48), // width full, height 48
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
            )
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
              break;
            case 2:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReimbursementPage()),
                (route) => false,
              );
              break;
            case 3:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
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
