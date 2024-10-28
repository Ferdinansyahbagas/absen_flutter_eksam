import 'package:absen/homepage/notif.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0; // Untuk mengatur indeks dari BottomNavigationBar

  @override
  void dispose() {
    _pageController.dispose(); // Pastikan untuk membersihkan PageController
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Mengatur indeks halaman yang dipilih
    });
    _pageController.jumpToPage(index); // Mengganti animateToPage dengan jumpToPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index; // Sinkronisasi indeks ketika halaman berganti
          });
        },
        children: [
          // Halaman Profile
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.deepPurple,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/profile_picture.png'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Hello!',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      Text(
                        'Maegareta workaholic',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildProfileItem(
                          'Email', 'Maegaretawokahholic@gmail.com'),
                      buildProfileItem('Password', '****'),
                      buildProfileItem('Phone Number', '080-345-7893'),
                      buildProfileItem('Address',
                          'Jl. Kembangan Selatan, Blok H-1, Jakarta, Special Capital Region of Jakarta, Indonesia, 11610'),
                      buildProfileItem('ID Card Address',
                          'Jl. Kembangan Selatan, Blok H-1, Jakarta, Special Capital Region of Jakarta, Indonesia, 11610'),
                      buildProfileItem('ID Card Picture', 'No image available'),
                      buildProfileItem('CV', 'No CV uploaded'),
                      buildProfileItem(
                          'Employment Contract Start', '12 October 2024'),
                      buildProfileItem(
                          'Employment Contract End', '12 October 2024'),
                      buildProfileItem('Education', 'SMA/SMK'),
                      buildProfileItem('Subdistrict Number', '1234567'),
                      buildProfileItem('License Limit', '12 Days'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Halaman lainnya
          TimeOffScreen(),
          ReimbursementPage(),
          NotificationPage(),
        ],
      ),
       bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
       items: const [
          BottomNavigationBarItem(
          icon :ImageIcon(
             AssetImage('assets/icon/home.png'), // Custom icon
              size: 20,
              color: Colors.white,
          ),
            label: 'Home',  
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/timeoff.png'), // Custom icon
              size: 18,
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
              AssetImage('assets/icon/notifikasi.png'), // Custom icon
              size: 20,
              color: Colors.white,
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/profil.png'), // Custom icon
              size: 22,
              color: Colors.orange,
            ),
            label: 'Profil',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 101, 19, 116),
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 9),
        currentIndex: 4,
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

  Widget buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(value),
              ],
            ),
          ),
          Icon(Icons.edit, color: Colors.orange),
        ],
      ),
    );
  }
}
