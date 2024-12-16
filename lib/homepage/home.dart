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
import 'package:http/http.dart' as http; // menyambungakan ke API
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController =
      PageController(); // PageController for PageView
  String? currentCity; // Menyimpan nama kota
  String? clockInMessage; // Pesan yang ditampilkan berdasarkan waktu clock-in
  String? name = ""; // Variabel untuk name pengguna
  String _currentTime = ""; // Variabel untuk menyimpan jam saat ini
  Timer? resetNoteTimer; // Timer untuk mereset note, clock in & out, dan card
  Timer? _timer; // Timer untuk memperbarui jam setiap detik
  int currentIndex = 0; // Default to the home page
  int _currentPage = 0; // Variable to keep track of the current page
  bool isLoadingLocation = true; // Untuk menandai apakah lokasi sedang di-load
  bool hasClockedIn = false; // Variabel baru untuk status clock-in
  bool hasClockedOut = false; // Variabel baru untuk status clock-out
  bool showNote = true; // Status untuk menampilkan note
  bool isSuccess = false; // Status untuk menampilkan card
  bool isLate = false; // Status untuk card terlambat
  bool isholiday = false; //status untuk card libur
  bool isovertime = false; //status untuk card lembur

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getData();
    _startClock(); // Memulai timer untuk jam
    _resetNoteAtFiveAM();
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

  // Fungsi untuk membuat menu shortcut dengan warna ikon dan latar belakang yang bisa disesuaikan
  Column _buildMenuShortcut({
    required String label,
    TextStyle? labelStyle,
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
          style: const TextStyle(color: Colors.pink, fontSize: 14),
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

  void _updateClockInStatus(bool status) {
    setState(() {
      hasClockedIn = status;
    });
  }

  // Fungsi untuk mengambil data dari API
  Future<void> getData() async {
    // Ambil profil pengguna
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/karyawan/get-profile');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());
      setState(() {
        name = data['data']['name'];
      });
      print("Profil pengguna: ${data['data']}");
    } catch (e) {
      print("Error mengambil profil pengguna: $e");
    }

    // Cek status clock-in
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/attendance/is-clock-in');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        // Status clock-in diambil dari respons API
        hasClockedIn = data['message'] != 'belum clock-in';

        if (hasClockedIn) {
          showNote = false;

          // Periksa waktu clock-in
          final now = DateTime.now();
          if (now.hour < 8) {
            isSuccess = true; // Clock-in berhasil sebelum jam 8 pagi
          } else {
            isLate = true; // Clock-in terlambat setelah jam 8 pagi
          }
        }
      });
    } catch (e) {
      print("Error mengecek status clock-in: $e");
    }

    // Cek status clock-out
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/attendance/is-clock-out');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        hasClockedOut = data['message'] == 'sudah clock-out';
      });
    } catch (e) {
      print("Error mengecek status clock-out: $e");
    }
  }

  // Fungsi untuk mereset note pada pukul 5 pagi
  void _resetNoteAtFiveAM() {
    final now = DateTime.now();
    final fiveAM = DateTime(now.year, now.month, now.day, 5);
    final timeUntilReset = fiveAM.isBefore(now)
        ? fiveAM.add(const Duration(days: 1)).difference(now)
        : fiveAM.difference(now);

    resetNoteTimer = Timer(timeUntilReset, () {
      setState(() {
        hasClockedIn = false;
        showNote = true;
        isSuccess = false;
        isLate = false;
        isholiday = false;
        isovertime = false; //status untuk card lembur

        clockInMessage = null;
      });
    });
  }

  @override
  void dispose() {
    resetNoteTimer?.cancel(); // Membatalkan timer saat widget dibuang
    super.dispose();
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
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman profil dan kirim gambar yang dipilih
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                        ),
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
                  Text(
                    'Welcome Back,\n $name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Don\'t Forget To Clock In Today ✨',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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
                              onPressed: hasClockedIn
                                  ? null
                                  : () async {
                                      final result = await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ClockInPage(),
                                        ),
                                      );
                                      // Perbarui status jika clock-in berhasil
                                      if (result == true) {
                                        _updateClockInStatus(true);
                                      }
                                    },
                              icon: const Icon(Icons.login),
                              label: const Text('Clock In'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    hasClockedIn ? Colors.grey : Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: hasClockedIn && !hasClockedOut
                                  ? () async {
                                      final result = await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ClockOutScreen(),
                                        ),
                                      );
                                      // Perbarui status jika clock-out berhasil
                                      if (result == true) {
                                        setState(() {
                                          hasClockedOut =
                                              true; // Set status clock-out
                                        });
                                      }
                                    }
                                  : null, // Disable tombol jika belum clock-in atau sudah clock-out
                              icon: const Icon(Icons.logout),
                              label: const Text('Clock Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasClockedIn && !hasClockedOut
                                    ? Colors
                                        .white // Aktif jika clock-in sudah dilakukan
                                    : Colors
                                        .grey, // Nonaktif jika belum clock-in atau sudah clock-out
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
                        bgColor: const Color.fromRGBO(
                            101, 19, 116, 1), // Warna background
                        imagePath:
                            'assets/icon/timeoff.png', // Path gambar aset
                        iconColor:
                            Colors.white, // Warna yang diterapkan ke gambar
                        iconSize: 32, // Ukuran gambar
                        labelStyle: const TextStyle(
                          color: Colors.pink, // Warna label menjadi pink
                          fontSize: 14,
                        ),
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
                        labelStyle: const TextStyle(
                          color: Colors.pink, // Warna label menjadi pink
                          fontSize: 14,
                        ),
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
                        labelStyle: const TextStyle(
                          color: Colors.pink, // Warna label menjadi pink
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isSuccess)
                    Card(
                      color: Colors.orange,
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Teks Kiri
                            Flexible(
                              child: Text(
                                '✨ Your Absence \n Was Successful ✨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // Teks Kanan
                            Flexible(
                              child: Text(
                                'Good work and \n keep up the spirit',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isLate)
                    Card(
                      color: Colors.redAccent,
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Teks Kiri
                            Flexible(
                              child: Text(
                                '💥 You’re Late!, \n Let’s In Now 💥',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // Teks Kanan
                            Flexible(
                              child: Text(
                                'How can you be \n absent late?',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isholiday)
                    Card(
                      color: Colors.green,
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '🌴 You’re on Leave 🌴',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Enjoy your time off!',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                  SizedBox(height: 2),
                  // Note Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showNote) ...[
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
}
