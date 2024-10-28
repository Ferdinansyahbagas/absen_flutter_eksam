//nanti jangan lupa ganti nama filenya
import 'package:flutter/material.dart';
import 'package:absen/homepage/notif.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/profil/profilscreen.dart';
import 'package:absen/timeoff/tiimeoff.dart';
import 'package:absen/timeoff/timeoffsick.dart';

class TimeOffScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Off'),
        leading: Icon(Icons.arrow_back), // Back button icon
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remaining Leave
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Remaining Leave Is',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Row(
                    children: [
                      Text('3',
                          style: TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text('/12',
                          style: TextStyle(fontSize: 24, color: Colors.white)),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 20),

            // Apply for Time Off Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 16.0)),
              onPressed: () {
                Navigator.pushReplacement(
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
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 16.0)),
              onPressed: () {
                Navigator.pushReplacement(
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

            // Time Off Request Card
            Expanded(
              child: ListView(
                children: [
                  TimeOffCard(
                    title: 'Annual Vacation',
                    description: 'I have a family event',
                    date: '12-13 Oktober 2024',
                    status: 'application approved',
                  ),
                  TimeOffCard(
                    title: 'Annual Vacation',
                    description: 'I have a family event',
                    date: '12-13 Oktober 2024',
                    status: 'application approved',
                  ),
                ],
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
