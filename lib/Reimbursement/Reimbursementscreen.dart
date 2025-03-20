import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/homepage/notif.dart';
import 'package:absen/profil/profilscreen.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:absen/Reimbursement/requestReimbursement.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absen/utils/notification_helper.dart';
import 'package:absen/service/api_service.dart'; // Import ApiService
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class ReimbursementPage extends StatefulWidget {
  const ReimbursementPage({super.key});

  @override
  _ReimbursementPageState createState() => _ReimbursementPageState();
}

class _ReimbursementPageState extends State<ReimbursementPage> {
  List<dynamic> historyData = [];
  List<dynamic> notifications = [];
  bool isLoading = true; // Menambahkan status loading
    bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    getHistoryData(); // Fetch history data when the page loads
    getNotif();
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

  Future<void> getHistoryData() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/other/get-self-reimbursement');
    var request = http.Request('GET', url);

    // Ambil token dari shared preferences
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        var data = jsonDecode(rp.body);

        if (data != null && data['data'] != null) {
          // Ambil data dan update state
          setState(() {
            historyData = data['data'] ?? []; // Validasi key
            isLoading = false; // Selesai memuat
          });
        } else {
          setState(() {
            isLoading = false; // Data tidak ditemukan, stop loading
          });
        }
      } else {
        setState(() {
          isLoading = false; // Error fetching data, stop loading
        });
        print('Error fetching history data: ${rp.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Error terjadi, stop loading
      });
      print('Error occurred while fetching data: $e');
    }
  }

  String formatCurrency(String amount) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'IDR. ', decimalDigits: 0);
    return currencyFormatter.format(double.tryParse(amount) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reimbursement',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReimbursementForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(101, 19, 116, 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Request Reimbursement',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'History Reimbursement',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // Menunggu data
                  )
                : historyData.isEmpty
                    ? const Center(
                        child: Text(
                          'Anda belum request.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: historyData.length,
                        itemBuilder: (context, index) {
                          final item =
                              historyData[index] as Map<String, dynamic>;
                          return ReimbursementHistoryCard(
                            title: item['name'] ?? 'Unknown Type',
                            amount: formatCurrency(
                                item['harga']?.toString() ?? '0'),
                            statusText: item['status']['name']?.toString() ??
                                'Unknown Status',
                            statusColor: _getStatusColor(
                                item['status']['id']?.toString() ?? ''),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'),
              size: 18,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/timeoff.png'),
              size: 20,
              color: Colors.white,
            ),
            label: 'Time Off',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt, size: 27),
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
              AssetImage('assets/icon/profil.png'),
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
        currentIndex: 2,
        onTap: (index) {
          // Handle bottom navigation bar tap
          switch (index) {
              case 0:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false, // Menghapus semua halaman sebelumnya
      );
      break;
    case 1:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TimeOffScreen()),
        (route) => false,
      );
      break;
    case 2:
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

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case '1':
      return Colors.purple;
    case '2':
      return Colors.grey;
    case '3':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class ReimbursementHistoryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String statusText;
  final Color statusColor;

  const ReimbursementHistoryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
