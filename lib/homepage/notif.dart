import 'package:flutter/material.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:absen/profil/profilscreen.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.pink, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: List.generate(4, (index) {
            return NotificationItem();
          }),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'),
              size: 18,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/timeoff.png'),
              size: 20,
              color: Colors.white,
            ),
            label: 'Time Off',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, size: 25),
            label: 'Reimbursement',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/notifikasi.png'),
              size: 22,
              color: Colors.orange,
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
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
        currentIndex: 3,
        onTap: (index) {
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

class NotificationItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text("This month's payslip has just been sent ✨"),
        subtitle: Text(
          'Click To View',
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PayslipDetailPage()),
          );
        },
      ),
    );
  }
}

// Halaman detail sesuai gambar yang diberikan
class PayslipDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, color: Colors.red, size: 12),
                SizedBox(width: 8),
                Text("This month's payslip has just been sent ✨"),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Ornare cursus magna mauris sit elementum morbi. Magna massa dolor suspendisse nunc...",
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 16),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text("Payslip Placeholder"),
            ),
            SizedBox(height: 8),
            Text(
              "Download File",
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
