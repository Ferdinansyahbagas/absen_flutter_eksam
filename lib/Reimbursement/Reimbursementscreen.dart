import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:absen/Reimbursement/requestReimbursement.dart';
import 'package:absen/homepage/notif.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:absen/profil/profilscreen.dart';

class ReimbursementPage extends StatefulWidget {
  @override
  _ReimbursementPageState createState() => _ReimbursementPageState();
}

class _ReimbursementPageState extends State<ReimbursementPage> {
  List<dynamic> historyData = [];

  @override
  void initState() {
    super.initState();
    getHistoryData();
  }

  Future<void> getHistoryData() async {
    final url = Uri.parse(
        'https://dev-portal.eksam.cloud/api/v1/other/get-reimbursement');
    var request = http.MultipartRequest('POST', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        var data = jsonDecode(rp.body);
        setState(() {
          historyData = data['data'] ?? [];
        });
        print(historyData);
      } else {
        print('Error fetching history data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reimbursement'),
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ReimbursementForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(101, 19, 116, 1),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Request Reimbursement',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
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
          Expanded(
            child: ListView.builder(
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                return ReimbursementHistoryCard(
                  title: item['name']?.toString() ?? 'Unknown',
                  amount: item['harga']?.toString() ?? 'Unknown',
                  statusText: item['status']?.toString() ?? 'Unknown',
                  statusColor:
                      _getStatusColor(item['status']?.toString() ?? 'Unknown'),
                );
              },
            ),
          ),
        ],
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
              size: 20,
              color: Colors.white,
            ),
            label: 'Time Off',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, size: 27),
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
        currentIndex: 2,
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TimeOffScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ReimbursementPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
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

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'submission':
      return Colors.pink;
    case 'submission accepted':
      return Colors.green;
    case 'submission rejected':
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

  ReimbursementHistoryCard({
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    amount,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
      ),
    );
  }
}
