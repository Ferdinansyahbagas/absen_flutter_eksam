import 'package:flutter/material.dart';
import 'package:absen/homepage/notif.dart'; // Mengimpor halaman notif
import 'package:absen/jamkelumas/ClockInPage.dart'; // Mengimpor halaman clockin
import 'package:absen/Reimbursement/Reimbursementscreen.dart'; // Mengimpor halaman Reimbursement
import 'package:absen/history/depan.dart'; // Mengimpor halaman history
import 'package:absen/timeoff/TimeoffScreen.dart'; // Mengimpor halaman timeoff
import 'package:absen/jamkelumas/clokOutPage.dart'; // Mengimpor halaman clockout
import 'package:absen/profil/profilscreen.dart'; // Mengimpor halaman profil
import 'package:geolocator/geolocator.dart'; //tempat
import 'package:geocoding/geocoding.dart'; //kordinat
import 'package:intl/intl.dart'; //unntuk format tanggal
import 'dart:async'; // Untuk timer
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? currentCity; // Menyimpan nama kota
  bool isLoadingLocation = true; // Untuk menandai apakah lokasi sedang di-load
  String _currentTime = ""; // Variabel untuk menyimpan jam saat ini
  Timer? _timer; // Timer untuk memperbarui jam setiap detik
  int currentIndex = 0; // Default to the home page
  int _currentPage = 0; // Variable to keep track of the current page
  PageController _pageController =
      PageController(); // PageController for PageView

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startClock(); // Memulai timer untuk jam
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  // Fungsi untuk memulai jam dan memperbaruinya setiap detik
  void _startClock() {
    _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Menghentikan timer saat widget dihapus
    _pageController.dispose(); // Dispose of the PageController
    super.dispose();
  }

  // Fungsi untuk membuat menu shortcut dengan warna ikon dan latar belakang yang bisa disesuaikan
  Column _buildMenuShortcut({
    required String label,
    required Widget targetPage,
    Color bgColor =
        const Color.fromARGB(255, 101, 19, 116), // Warna background default
    IconData? iconData, // Opsional untuk menggunakan Icon Flutter
    String? imagePath, // Opsional untuk menggunakan gambar dari asset
    Color iconColor = Colors.white, // Warna icon atau filter warna
    double? iconSize = 30, // Ukuran default untuk ikon atau gambar
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          },
          child: Container(
            width: 60, // Lebar container shortcut
            height: 60, // Tinggi container shortcut
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
                  BorderRadius.circular(12), // Membuat sudut melengkung
            ),
            child: Center(
              child: imagePath != null
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        iconColor, // Warna filter yang diterapkan
                        BlendMode.srcIn, // Mengatur mode blending
                      ),
                      child: Image.asset(
                        imagePath,
                        width: iconSize, // Sesuaikan ukuran gambar
                        height: iconSize, // Sesuaikan ukuran gambar
                        fit: BoxFit.contain,
                      ),
                    )
                  : Icon(
                      iconData,
                      color: iconColor,
                      size: iconSize,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.purple),
        ),
      ],
    );
  }

  // Fungsi untuk mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Mengecek apakah layanan lokasi tersedia
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika layanan lokasi tidak aktif, tampilkan pesan "Location not available"
      setState(() {
        currentCity = 'Location not available';
        isLoadingLocation = false;
      });
      return;
    }

    // Meminta izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Jika izin lokasi ditolak, tampilkan pesan "Location not available"
        setState(() {
          currentCity = 'Location not available';
          isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Jika izin lokasi ditolak selamanya, tampilkan pesan "Location not available"
      setState(() {
        currentCity = 'Location not available';
        isLoadingLocation = false;
      });
      return;
    }

    // Mendapatkan posisi pengguna jika semua syarat terpenuhi
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Menggunakan geocoding untuk mendapatkan nama kota dari koordinat
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          currentCity = placemarks.first.locality; // Mengambil nama kota
          isLoadingLocation = false; // Lokasi selesai di-load
        });
      }
    } catch (e) {
      // Jika ada error lainnya, tampilkan pesan "Location not available"
      setState(() {
        currentCity = 'Location not available';
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange,
                    Colors.pink,
                    const Color.fromARGB(255, 101, 19, 116)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(
                            'assets/image/agas.png'), // Ganti dengan path image profile
                      ),
                      Text(
                        _currentTime, // Menampilkan waktu yang di-update setiap detik
                        style: const TextStyle(
                          fontSize: 16,
                          color:
                              Color.fromARGB(255, 255, 255, 255), // Warna teks
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationPage()),
                          ); // Tambahkan aksi untuk notification
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back,\nMaegareta wokahholic',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Don\'t Forget To Clock In Today ✨',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isLoadingLocation
                              ? 'Loading your location...'
                              : 'Your Location Is Now In $currentCity',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ClockInPage())); // Aksi Clock In
                              },
                              icon: const Icon(Icons.login),
                              label: const Text('Clock In'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ClockOutScreen())); // Aksi Clock Out
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Clock Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bagian Middle
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Shortcut
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceAround, // Memberi jarak di antara shortcut
                    children: [
                      // Menggunakan gambar dari aset dan mengatur ukuran gambar
                      _buildMenuShortcut(
                        label: 'Time Off',
                        targetPage: TimeOffScreen(),
                        bgColor: const Color.fromARGB(
                            255, 101, 19, 116), // Warna background
                        imagePath:
                            'assets/icon/timeoff.png', // Path gambar aset
                        iconColor:
                            Colors.white, // Warna yang diterapkan ke gambar
                        iconSize: 32, // Ukuran gambar
                      ),
                      // Menggunakan ikon bawaan Flutter dengan ukuran yang sama
                      _buildMenuShortcut(
                        label: 'Reimbursement',
                        targetPage: ReimbursementPage(),
                        bgColor: const Color.fromARGB(
                            255, 101, 19, 116), // Warna background
                        iconData: Icons.receipt, // Ikon bawaan Flutter
                        iconColor: Colors.white, // Warna ikon
                        iconSize: 30, // Ukuran ikon
                      ),
                      // Menggunakan gambar dari aset dan mengatur ukuran gambar
                      _buildMenuShortcut(
                        label: 'History',
                        targetPage: HistoryScreen(),
                        bgColor: const Color.fromARGB(
                            255, 101, 19, 116), // Warna background
                        imagePath:
                            'assets/icon/history.png', // Path gambar aset
                        iconColor:
                            Colors.white, // Warna yang diterapkan ke gambar
                        iconSize: 26, // Ukuran gambar
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildStatusCard('✨ Your Absence Was Successful ✨',
                      Colors.orange, 'Good work and keep up the spirit'),
                  const SizedBox(height: 20),
// Announcement Section
                  const Text(
                    'Announcement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),
// PageView for slideshow of announcements with indicators
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[300],
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: 3, // Jumlah slide
                          itemBuilder: (context, index) {
                            final imagePaths = [
                              'assets/announcement/messi.jpeg',
                              'assets/announcement/dodo.jpeg',
                              'assets/announcement/neymar.jpeg',
                            ];
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage(imagePaths[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          onPageChanged: (int index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                        ),
                        // Tambahkan indikator
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller:
                                  _pageController, // Gunakan _pageController yang dideklarasikan
                              count: 3, // Jumlah slide
                              effect: ExpandingDotsEffect(
                                activeDotColor:
                                    Colors.purple, // Warna dot aktif
                                dotColor: Colors.white, // Warna dot tidak aktif
                                dotHeight: 8, // Tinggi dot
                                dotWidth: 8, // Lebar dot
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Note Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Note',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(
                            height: 10), // Jarak antara "Note" dan konten
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3), // posisi bayangan
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Today was Good, good work 👏',
                                style: TextStyle(fontSize: 11),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ClockInPage()),
                                  ); // Aksi ketika tombol ditekan
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.orange, // Warna tombol
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        4), // Melengkungkan pinggiran tombol
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 101, 19, 116),
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 9),
        currentIndex: currentIndex, // Update the currentIndex here
        onTap: (int index) {
          setState(() {
            currentIndex = index; // Update the selected index
          });

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
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'), // Custom icon
              size: 20,
              color: Colors.orange,
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
      ),
    );
  }

  Widget _buildStatusCard(String title, Color color, String subtitle) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
