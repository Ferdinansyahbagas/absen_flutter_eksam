import 'package:flutter/material.dart';
import 'package:absen/homepage/notif.dart'; // Mengimpor halaman notif
import 'package:absen/Jamkelumas/ClockInPage.dart'; // Mengimpor halaman clockin
import 'package:absen/Reimbursement/Reimbursementscreen.dart'; // Mengimpor halaman Reimbursement
import 'package:absen/history/depan.dart'; // Mengimpor halaman history
import 'package:absen/timeoff/TimeoffScreen.dart'; // Mengimpor halaman timeoff
import 'package:absen/Jamkelumas/ClokOutPage.dart'; // Mengimpor halaman clockout
import 'package:absen/Jamkelumas/Clockinwfa.dart';
import 'package:absen/profil/profilscreen.dart'; // Mengimpor halaman profil
import 'dart:async'; // Untuk timer
import 'dart:convert';
import 'package:intl/intl.dart'; //unntuk format tanggal
import 'package:http/http.dart' as http; // menyambungakan ke API
import 'package:geocoding/geocoding.dart'; //kordinat
import 'package:geolocator/geolocator.dart'; //tempat
import 'package:absen/utils/notification_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:absen/service/api_service.dart'; // Import ApiService

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController =
      PageController(); // PageController for PageView
  String? name = ""; // Variabel untuk name pengguna
  String? message; //variabel untuk th messange
  String? avatarUrl; // Variable untuk avatar gambar
  String? currentCity; // Menyimpan nama kota
  String? clockInMessage; // Pesan yang ditampilkan berdasarkan waktu clock-in
  String? userStatus;
  String? wfhId; // Simpan ID WFH jika ada
  String _currentTime = ""; // Variabel untuk menyimpan jam saat ini
  Timer? _timer; // Timer untuk memperbarui jam setiap detik
  Timer? resetNoteTimer; // Timer untuk mereset note, clock in & out, dan card
  int currentIndex = 0; // Default to the home page
  int _currentIndex = 0;
  int _currentPage = 0; // Variable to keep track of the current page
  int? userId;
  bool isLoadingLocation = true; // Untuk menandai apakah lokasi sedang di-load
  bool hasClockedIn = false; // Status clock-in biasa
  bool hasClockedOut = false; // Status clock-out biasa
  bool hasCuti = false; // Status clock-out biasa
  bool isLupaClockOut = false; //status lupa clock out
  bool hasClockedInOvertime = false; // Status clock-in lembur
  bool hasClockedOutOvertime = false; // Status clock-out lembur
  bool isCuti = false; // Status untuk menampilkan card cuti
  bool showNote = true; // Status untuk menampilkan note
  bool isSuccess = false; // Status untuk menampilkan card berhasil absen
  bool isLate = false; // Status untuk card terlambat
  bool isholiday = false; //status untuk card libur
  bool isovertime = false; //status untuk card lembur
  bool isWFHRequested = false; //status mengajukan WFH
  bool isWFARequested = false; //status pengajuan WFA
  bool jarak = false;
  bool hasUnreadNotifications =
      false; //Status untuk melihat notifikasi sudah di baca atau belum
  List<dynamic> notifications = []; //variabel noifiaksi
  List<String> announcements = []; // List untuk menyimpan pesan pengumuman

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startClock(); // Memulai timer untuk jam
    Future.delayed(Duration(milliseconds: 500), () {
      getData(); // Panggil API setelah sedikit delay
      getPengumuman();
      getcancelwfh();
      getcekwfh();
      getNotif();
      getcekwfa();
      saveFirebaseToken();
      gettoken(); // Kirim token ke server setelah disimpan
    });
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    print(_startClock);
  }

// Fungsi untuk memperbarui waktu setiap detik
  void _startClock() {
    _timer?.cancel(); // Pastikan timer lama dihentikan sebelum buat baru
    _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (!mounted) return; // Cegah update jika widget sudah dihapus
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  void _showClockInPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Clock In"),
          content:
              const Text("Lokasi Anda tidak dalam radius kantor. Ajukan WFH? "),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup pop-up
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup pop-up
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClockInPage()),
                );
              },
              child: const Text("Ajukan WFH"),
            ),
          ],
        );
      },
    );
  }

  void _showClockInPopupWFA(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Clock In"),
          content:
              const Text("Lokasi Anda tidak dalam radius kantor. Ajukan WFA? "),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup pop-up
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup pop-up
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClockInPage()),
                );
              },
              child: const Text("Ajukan WFA"),
            ),
          ],
        );
      },
    );
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
        Container(
          width: 100,
          padding: const EdgeInsets.all(8.0), // Padding di dalam container
          decoration: BoxDecoration(
            color: Colors.transparent, // Warna latar belakang
            borderRadius: BorderRadius.circular(8.0), // Sudut melengkung
          ),
          child: Column(
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
                        BorderRadius.circular(50), // Membuat sudut melengkung
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
                style: const TextStyle(
                    color: Colors.pink,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
        currentCity = 'Lokasi tidak tersedia';
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
          currentCity = 'Lokasi tidak tersedia';
          isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Jika izin lokasi ditolak selamanya, tampilkan pesan "Location not available"
      setState(() {
        currentCity = 'Lokasi tidak tersedia';
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
        currentCity = 'Lokasi tidak tersedia';
        isLoadingLocation = false;
      });
    }
  }

// fungsi untuk memanggil bacaan notifikasi
  Future<void> getNotif() async {
    await Future.delayed(
        Duration(milliseconds: 200)); // Biarkan UI tetap responsif
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
    await Future.delayed(
        Duration(milliseconds: 200)); // Biarkan UI tetap responsif
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
  //notif read sampai sini

  Future<void> getPengumuman() async {
    await Future.delayed(
        Duration(milliseconds: 200)); // Biarkan UI tetap responsif
    var data = await ApiService.sendRequest(endpoint: "other/get-th");
    if (data == null) return;

    setState(() {
      announcements = List<String>.from(data['data']
          .where((item) => item['status']['id'] == 1)
          .map((item) => item['message']));
      _startAutoSlide();
    });
  }

  void _startAutoSlide() {
    _timer?.cancel(); // Hentikan timer jika sebelumnya sudah berjalan
    if (announcements.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_currentIndex < announcements.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0; // Balik ke awal jika sudah di akhir
        }
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hentikan timer saat widget dihapus
    _pageController.dispose();
    super.dispose();
  }

  void saveFirebaseToken() async {
    await Future.delayed(
        Duration(milliseconds: 200)); // Biarkan UI tetap responsif
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('firebase_token', token);
      gettoken();
    }
  }

  Future<void> gettoken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? token = localStorage.getString('firebase_token');

    if (token == null || token.isEmpty) {
      print("Token Firebase tidak ditemukan!");
      return;
    }

    var response = await ApiService.sendRequest(
      endpoint: "other/send-token",
      method: 'POST',
      body: {'firebase_token': token},
    );

    if (response != null) {
      print("Token Firebase berhasil dikirim: $token");
    }
  }

  Future<void> getcekwfa() async {
    await Future.delayed(
        Duration(milliseconds: 200)); // Biarkan UI tetap responsif
    var data =
        await ApiService.sendRequest(endpoint: 'request-history/is-wfa-today');

    if (data != null && data['message'] == 'User sudah mengajukan WFA') {
      setState(() {
        isWFARequested = true;
        showNote = false;
        hasClockedIn = false;
        hasClockedOut = true;
        wfhId = data['data']['id'].toString();
      });
    } else {
      setState(() {
        isWFARequested = false;
        wfhId = null;
      });
    }
  }

  // Fungsi untuk cek status WFH
  Future<void> getcekwfh() async {
    await Future.delayed(
        Duration(milliseconds: 200)); // Biarkan UI tetap responsif
    var data = await ApiService.sendRequest(endpoint: 'attendance/is-wfh');

    if (data != null && data['message'] == 'User mengajukan WFH') {
      setState(() {
        isWFHRequested = true;
        showNote = false;
        wfhId = data['data']['id'].toString();
      });
    } else {
      setState(() {
        isWFHRequested = false;
        wfhId = null;
      });
    }
  }

  Future<bool> getcancelwfh() async {
    await Future.delayed(
        Duration(milliseconds: 200)); // Biarkan UI tetap responsif
    if (wfhId == null) {
      print("Gagal membatalkan WFH: wfhId tidak ditemukan");
      return false;
    }

    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/cancel-wfh/$wfhId');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var headers = {
      'Authorization': 'Bearer ${localStorage.getString('token')}',
      'Accept':
          'application/json', // Tambahkan ini untuk memastikan format JSON
    };

    try {
      var response = await http.delete(url, headers: headers);

      // Debugging output
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Response API cancel-wfh: $data");

        setState(() {
          isWFHRequested = false;
          wfhId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WFH berhasil dibatalkan'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        print("Gagal membatalkan WFH. Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  // Fungsi untuk mengambil data dari API
  Future<void> getData() async {
    await Future.delayed(
        Duration(milliseconds: 200)); // Biarkan UI tetap responsif

    try {
      // Ambil lokasi user
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      // Ambil profil pengguna
      var profileData =
          await ApiService.sendRequest(endpoint: 'karyawan/get-profile');
      if (profileData != null) {
        setState(() {
          userStatus = profileData['data']['user_level_id'].toString();
          name = profileData['data']['name'];
          wfhId = profileData['data']['id'].toString(); // ID WFH

          double officeLatitude =
              double.tryParse(profileData['data']['latitude'].toString()) ??
                  0.0;
          double officeLongitude =
              double.tryParse(profileData['data']['longitude'].toString()) ??
                  0.0;

          // Hitung jarak user dengan kantor
          double distance = Geolocator.distanceBetween(
              userLatitude, userLongitude, officeLatitude, officeLongitude);

          print("Jarak dari kantor: $distance meter");
          if (userStatus == "1" || userStatus == "2") {
            jarak = distance > 500;
          }
        });
      }

      // Cek status clock-in
      var clockInData =
          await ApiService.sendRequest(endpoint: 'attendance/is-clock-in');
      if (clockInData != null) {
        setState(() {
          hasClockedIn = clockInData['message'] != 'belum clock-in';
          if (hasClockedIn) {
            showNote = false;
            isholiday = false;
            clockInData['data']['attendance_status_id'] == 5;
            isSuccess = true; // Clock-in berhasil sebelum jam 8
            isovertime = false;
          }
        });
      }

      // Cek status clock-out
      var clockOutData =
          await ApiService.sendRequest(endpoint: 'attendance/is-clock-out');
      if (clockOutData != null) {
        setState(() {
          hasClockedOut = clockOutData['message'] == 'sudah clock-out';
        });
      }
      // Cek status clock-out-lupa
      var clockOutLupaData = await ApiService.sendRequest(
          endpoint: 'attendance/is-lupa'); // Ganti endpoint jika perlu

      if (clockOutLupaData != null && clockOutLupaData['lupa'] != null) {
        setState(() {
          isLupaClockOut =
              clockOutLupaData['lupa']; // true jika lupa, false jika tidak
        });
      }

      // Cek status lembur masuk
      if (userStatus == "1" || userStatus == "2") {
        var overtimeInData =
            await ApiService.sendRequest(endpoint: 'attendance/is-lembur-in');
        if (overtimeInData != null) {
          setState(() {
            hasClockedInOvertime =
                overtimeInData['message'] != 'belum clock-in';
            if (hasClockedInOvertime) {
              showNote = false;
              isholiday = false;
              isSuccess = false;
              isovertime = true;
            }
          });
        }
        // Cek status lembur keluar
        var overtimeOutData =
            await ApiService.sendRequest(endpoint: 'attendance/is-lembur-out');
        if (overtimeOutData != null) {
          setState(() {
            hasClockedOutOvertime =
                overtimeOutData['message'] != 'belum clock-out';
          });
        }
      }

      //     var cutiData =
      //         await ApiService.sendRequest(endpoint: 'attendance/is-cuti');
      //     if (cutiData != null
      //         // && cutiData['message'] == 'sedang cuti'
      //         ) {
      //       setState(() {
      //         // hasCuti = true;
      //         hasCuti = cutiData['message'] != 'sedang cuti';
      //         if (hasCuti) {
      //           showNote = false;
      //           isholiday = true;
      //           isSuccess = false;
      //           isovertime = false;
      //         }
      //       });
      //     } else {
      //       setState(() {
      //         hasCuti = false;
      //       });
      //     }
    } catch (e) {
      print("Error saat cek cuti: $e");
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
                    Color.fromARGB(255, 101, 19, 116)
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
                        onTap: () async {
                          // Navigasi ke halaman profil dan tunggu hasilnya
                          final updatedAvatarUrl = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );

                          // Perbarui avatar jika ada perubahan
                          if (updatedAvatarUrl != null) {
                            setState(() {
                              avatarUrl = updatedAvatarUrl;
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: avatarUrl != null
                              ? const NetworkImage('avatarUrl')
                              : const AssetImage('assets/image/logo_circle.png')
                                  as ImageProvider,
                        ),
                      ),
                      // Menampilkan waktu yang di-update setiap detik
                      Text(
                        _currentTime,
                        style: const TextStyle(
                          fontSize: 16,
                          color:
                              Color.fromARGB(255, 255, 255, 255), // Warna teks
                        ),
                      ),
                      // notifikasi icon
                      IconButton(
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications,
                                color: Colors.white),
                            FutureBuilder<bool>(
                              future:
                                  NotificationHelper.hasUnreadNotifications(),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NotificationPage()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // menamplakan nama pengguna
                  Text(
                    'Selamat Datang, \n$name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Jangan Lupa Absen Hari ini✨',
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
                        // untuk melihat kota / lokasi terkini
                        Text(
                          isLoadingLocation
                              ? 'Memuat lokasi Anda...'
                              : 'Lokasi Anda Sekarang Ada Di $currentCity',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        //menampilkan hari dan tanggal
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (userStatus == "3") ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: (hasClockedIn)
                                    ? null
                                    : () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ClockInPage(),
                                          ),
                                        );
                                        if (result == true) {
                                          setState(() {
                                            hasClockedIn = true;
                                            hasClockedOut = false;
                                          });
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
                                onPressed: (hasClockedIn && !hasClockedOut)
                                    ? () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ClockOutScreen(),
                                          ),
                                        );
                                        if (result == true) {
                                          setState(() {
                                            hasClockedOut = true;
                                            hasClockedIn = false;
                                          });

                                          // Reset tombol setelah 1 detik
                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            if (mounted) {
                                              setState(() {
                                                hasClockedIn = false;
                                                hasClockedOut = false;
                                              });
                                            }
                                          });
                                        }
                                      }
                                    : null,
                                icon: const Icon(Icons.logout),
                                label: const Text('Clock Out'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      (hasClockedIn && !hasClockedOut)
                                          ? Colors.white
                                          : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ] else if
                            // hasClockedOut &&
                            (userStatus == "1" || userStatus == "2") ...[
                          if (isWFHRequested) ...[
                            // Jika user level 1 atau 2 telah request WFH
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed:
                                      null, // Tombol Pending selalu disabled
                                  icon: const Icon(Icons.hourglass_empty),
                                  label: const Text('Pending'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final success =
                                        await getcancelwfh(); // Fungsi untuk membatalkan WFH
                                    if (success) {
                                      setState(() {
                                        isWFHRequested = false;
                                        hasClockedIn =
                                            false; // Clock In aktif kembali
                                        hasClockedInOvertime = false;
                                        hasClockedOutOvertime = false;
                                        hasClockedOut = false; // Clock Out mati
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Batalkan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          ] else ...[
                            // Jika belum request WFH, cek apakah sudah clock out
                            Column(
                              children: [
                                // Tampilkan Clock In & Out jika belum Clock Out
                                if (!hasClockedOut) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: hasClockedIn
                                            ? null
                                            : () async {
                                                if (isWFARequested) {
                                                  _showClockInPopupWFA(context);
                                                } else if (jarak) {
                                                  _showClockInPopup(
                                                      context); // Jika user di luar kantor, tampilkan pop-up
                                                } else {
                                                  // Jika tidak WFH, langsung Clock In tanpa pop-up
                                                  final result =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ClockInPage(),
                                                    ),
                                                  );
                                                  if (result == true) {
                                                    setState(() {
                                                      hasClockedIn = true;
                                                      hasClockedOut = false;
                                                    });
                                                  }
                                                }
                                              },
                                        icon: const Icon(Icons.login),
                                        label: const Text('Clock In'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: hasClockedIn
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed:
                                            (hasClockedIn && !hasClockedOut)
                                                ? () async {
                                                    final result =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ClockOutScreen(),
                                                      ),
                                                    );
                                                    if (result == true) {
                                                      setState(() {
                                                        hasClockedOut = true;
                                                        hasClockedIn = false;
                                                      });
                                                    }
                                                  }
                                                : null,
                                        icon: const Icon(Icons.logout),
                                        label: const Text('Clock Out'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              (hasClockedIn && !hasClockedOut)
                                                  ? Colors.white
                                                  : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else
                                  // Jika sudah Clock Out, tampilkan Overtime In & Out, dan sembunyikan Clock In & Out
                                  ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: hasClockedInOvertime
                                            ? null
                                            : () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ClockInPage(),
                                                  ),
                                                );
                                                if (result == true) {
                                                  setState(() {
                                                    hasClockedInOvertime = true;
                                                    hasClockedOutOvertime =
                                                        false;
                                                  });
                                                }
                                              },
                                        icon: const Icon(Icons.timer),
                                        label: const Text('Overtime In'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: hasClockedInOvertime
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: (hasClockedInOvertime &&
                                                !hasClockedOutOvertime)
                                            ? () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ClockOutScreen(),
                                                  ),
                                                );
                                                if (result == true) {
                                                  setState(() {
                                                    hasClockedOutOvertime =
                                                        false;
                                                    hasClockedInOvertime =
                                                        false;
                                                  });
                                                }
                                              }
                                            : null,
                                        icon: const Icon(Icons.timer_off),
                                        label: const Text('Overtime Out'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              (hasClockedInOvertime &&
                                                      !hasClockedOutOvertime)
                                                  ? Colors.white
                                                  : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                              ],
                            )
                          ]
                        ]
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Column(
                        children: [
                          // Bagian atas (Time Off, Reimbursement, History)
                          Wrap(
                            alignment:
                                WrapAlignment.start, // Meratakan item di tengah
                            spacing: 15.0, // Jarak horizontal antar item
                            runSpacing: 15.0, // Jarak vertikal antar baris
                            children: [
                              _buildMenuShortcut(
                                label: 'Time Off',
                                targetPage: const TimeOffScreen(),
                                bgColor: const Color.fromRGBO(101, 19, 116, 1),
                                imagePath: 'assets/icon/timeoff.png',
                                iconColor: Colors.white,
                                iconSize: 32,
                                labelStyle: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 14,
                                ),
                              ),
                              _buildMenuShortcut(
                                label: 'Reimbursement',
                                targetPage: const ReimbursementPage(),
                                bgColor:
                                    const Color.fromARGB(255, 101, 19, 116),
                                iconData: Icons.receipt,
                                iconColor: Colors.white,
                                iconSize: 30,
                                labelStyle: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 14,
                                ),
                              ),
                              _buildMenuShortcut(
                                label: 'History',
                                targetPage: const HistoryScreen(),
                                bgColor:
                                    const Color.fromARGB(255, 101, 19, 116),
                                imagePath: 'assets/icon/history.png',
                                iconColor: Colors.white,
                                iconSize: 26,
                                labelStyle: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 14,
                                ),
                              ),
                              _buildMenuShortcut(
                                label: 'Request WFA',
                                targetPage: ClockinwfaPage(),
                                bgColor: const Color.fromRGBO(101, 19, 116, 1),
                                imagePath: 'assets/icon/WFA.png',
                                iconColor: Colors.white,
                                iconSize: 32,
                                labelStyle: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  //card untuk absen biasa
                  if (isSuccess)
                    Card(
                      color: Colors.orange,
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 1, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Teks Kiri
                            Flexible(
                              child: Text(
                                '✨Absen Anda \nTelah Berhasil ✨',
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
                                'Kerja bagus dan \ntetap semangat',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  //card untuk lembur
                  if (isovertime //&& userStatus != "3"
                      )
                    Card(
                      color: Colors.redAccent,
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 1, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Teks Kiri
                            Flexible(
                              child: Text(
                                '💥Anda Sedang \nLembur Sekarang💥',
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
                                'Kerja bagus dan \ntetap semangat',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  //card untuk cuti
                  if (isholiday)
                    Card(
                      color: Colors.green,
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 1, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '🌴Selamat Liburan/ \n Istirahat🌴',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Nikmati waktu \nistirahat Anda!',
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
                  // Bagian Announcement
                  const Text(
                    'Pengumuman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 101, 19, 116),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // // Slider untuk pengumuman
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[300],
                    ),
                    child: announcements.isEmpty
                        ? const Center(
                            child: Text(
                              'Hari ini tidak ada pengumuman',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: announcements.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final message = announcements[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AnnouncementDetailPage(
                                            message: message,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Html(
                                          data: message,
                                          style: {
                                            "body": Style(
                                              textAlign: TextAlign.center,
                                              fontSize: FontSize(16.0),
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 101, 19, 116),
                                            ),
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Indikator halaman
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: SmoothPageIndicator(
                                    controller: _pageController,
                                    count: announcements.length,
                                    effect: const ExpandingDotsEffect(
                                      activeDotColor:
                                          Color.fromARGB(255, 101, 19, 116),
                                      dotColor: Colors.grey,
                                      dotHeight: 8,
                                      dotWidth: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  // Note Section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showNote) ...[
                          const Text(
                            'Note',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 101, 19, 116),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 18),
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
                                  'Jangan Lupa Absen Hari Ini👏',
                                  style: TextStyle(fontSize: 11),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (isWFARequested) {
                                      _showClockInPopupWFA(context);
                                    } else if (jarak) {
                                      _showClockInPopup(
                                          context); // Jika user di luar kantor, tampilkan pop-up
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ClockInPage()),
                                      ); // Jika dalam kantor, langsung ke halaman Clock In
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.orange, // Warna tombol
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Melengkungkan pinggiran tombol
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
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
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const TimeOffScreen()),
                (route) => false,
              );
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
        items: [
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'), // Custom icon
              size: 20,
              color: Colors.orange,
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/timeoff.png'), // Custom icon
              size: 20,
              color: Colors.white,
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
      ),
    );
  }
}

class AnnouncementDetailPage extends StatelessWidget {
  final String message;

  const AnnouncementDetailPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Announcement'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Html(
          data: message,
        ),
      ),
    );
  }
}
