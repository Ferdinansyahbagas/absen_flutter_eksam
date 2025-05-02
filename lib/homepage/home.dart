import 'package:flutter/material.dart';
import 'package:absen/history/depan.dart'; // Mengimpor halaman history
import 'package:absen/homepage/notif.dart'; // Mengimpor halaman notif
import 'package:absen/profil/profilscreen.dart'; // Mengimpor halaman profil
import 'package:absen/inventaris/peraturan.dart'; // Mengimpor halaman peraturan
import 'package:absen/timeoff/TimeoffScreen.dart'; // Mengimpor halaman timeoff
import 'package:absen/Jamkelumas/Clockinwfa.dart'; // Mengimpor halaman pengajuan wfa
import 'package:absen/inventaris/inventaris.dart'; // Mengimpor halaman inventaris
import 'package:absen/Jamkelumas/ClockInPage.dart'; // Mengimpor halaman clock in
import 'package:absen/Jamkelumas/ClokOutPage.dart'; // Mengimpor halaman clock out
import 'package:absen/Jamkelumas/ClockoutLupa.dart'; // Mengimpor halaman clock out lupa
import 'package:absen/Reimbursement/Reimbursementscreen.dart'; // Mengimpor halaman Reimbursement
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absen/utils/notification_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:absen/service/api_service.dart'; // Import ApiService
import 'package:geolocator/geolocator.dart'; // Mengimpor tempat
import 'package:geocoding/geocoding.dart'; // Mengimpor kordinat
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // untuk format tanggal
import 'dart:convert';
import 'dart:async'; // Untuk timer

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentTime = ""; // Variabel untuk menyimpan jam saat ini
  String? Id; // Simpan ID WFH jika ada
  String? message; //variabel untuk th messange
  String? avatarUrl; // Variable untuk avatar gambar
  String? name = ""; // Variabel untuk name pengguna
  String? userStatus;
  String? currentCity; // Menyimpan nama kota
  String? clockInMessage; // Pesan yang ditampilkan berdasarkan waktu clock-in
  Timer? _timer; // Timer untuk memperbarui jam setiap detik
  Timer? resetNoteTimer; // Timer untuk mereset note, clock in & out, dan card
  int? userId;
  int currentIndex = 0; // Default to the home page
  int _currentIndex = 0;
  // ignore: unused_field
  int _currentPage = 0; // Variable to keep track of the current page
  int hariBulanIni = 0;
  int menitBulanIni = 0;
  int telatBulanIni = 0;
  int cutiBulanIni = 0;
  int hariBulanLalu = 0;
  int menitBulanLalu = 0;
  int telatBulanLalu = 0;
  int cutiBulanLalu = 0;
  int hadirHariIni = 0;
  int hadirMenitIni = 0;
  int targetHariIni = 0;
  int targetMenitIni = 0;
  int hadirHariSebelumnya = 0;
  int hadirMenitSebelumnya = 0;
  int targetHariSebelumnya = 0;
  int targetMenitSebelumnya = 0;
  bool isLoadingLocation = true; // Untuk menandai apakah lokasi sedang di-load
  bool hasClockedIn = false; // Status clock-in biasa
  bool hasClockedOut = false; // Status clock-out biasa
  bool hasCuti = false; // Status clock-out biasa
  bool isLupaClockOut = false; //status lupa clock out
  bool hasClockedInOvertime = false; // Status clock-in lembur
  bool hasClockedOutOvertime = false; // Status clock-out lembur
  bool hasholiday = false; //status untuk libur holiday
  bool isCuti = false; // Status untuk menampilkan card cuti
  bool showNote = true; // Status untuk menampilkan note
  bool isSuccess = false; // Status untuk menampilkan card berhasil absen
  bool isLate = false; // Status untuk card terlambat
  bool isholiday = false; //status untuk card libur
  bool isovertime = false; //status untuk card lembur
  bool isWFHRequested = false; //status mengajukan WFH
  bool isWFARequested = false; //status pengajuan WFA
  bool jarak = false; // status untuk jarak kantor
  bool jarakclockout = false; // status untuk jarak kantor
  // ignore: unused_field
  bool _isApiLoaded = false; // Status apakah API sudah selesai dimuat
  bool hasUnreadNotifications =
      false; //Status untuk melihat notifikasi sudah di baca atau belum
  List<dynamic> notifications = []; //variabel noifiaksi
  List<String> announcements = []; // List untuk menyimpan pesan pengumuman
  Map<String, dynamic> targetData = {};
  Position? lastKnownPosition; // Simpan lokasi terakhir
  final PageController _pageController =
      PageController(); // PageController for PageView

  @override
  void initState() {
    super.initState();
    _startClock(); // Memulai timer untuk jam
    _getCurrentLocation();
    Future.delayed(Duration(milliseconds: 500), () {
      getData(); // Panggil API setelah sedikit delay
      getNotif();
      getcekwfa();
      getTarget();
      getUserInfo();
      getPengumuman();
    });
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
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

  void _showFakeGpsWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Peringatan!"),
          content: Text(
              "Aplikasi mendeteksi penggunaan Fake GPS. Mohon matikan dan coba lagi."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
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
          title: const Text("Konfirmasi Clock In WFA"),
          content: const Text(
              "Anda berada di luar jangkauan kantor. Apakah ingin mengajukan WFA?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClockinwfaPage(),
                  ),
                );
                if (result == true) {
                  setState(() {
                    hasClockedIn = true;
                    hasClockedOut = false;
                  });
                }
              },
              child: const Text("Ajukan WFA"),
            ),
          ],
        );
      },
    );
  }

  void _showClockoutPopupjarak(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Clock out"),
          content: const Text(
              "Anda berada di luar jangkauan kantor. Clock out sekarang?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClockOutLupaScreen(),
                  ),
                );
                if (result == true) {
                  setState(() {
                    hasClockedIn = true;
                    hasClockedOut = false;
                  });
                }
              },
              child: const Text("Clock Out"),
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
    Widget? targetPage, // Diubah ke nullable
    VoidCallback? onTap, // Tambahkan ini untuk handle custom aksi
    Color bgColor = const Color.fromARGB(255, 101, 19, 116),
    IconData? iconData,
    String? imagePath,
    Color iconColor = Colors.white,
    double? iconSize = 30,
  }) {
    return Column(
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: onTap ??
                    () {
                      if (targetPage != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => targetPage),
                        );
                      }
                    },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: imagePath != null
                        ? ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              imagePath,
                              width: iconSize,
                              height: iconSize,
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
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

//fungsi untuuk menampilkan pop up comiing soon
  // void _showComingSoonDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Coming Soon"),
  //       content: const Text("Fitur ini akan tersedia segera."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Oke"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
    await Future.delayed(const Duration(seconds: 3)); // Simulasi loading API
    setState(() {
      _isApiLoaded = true; // API selesai dimuat
    });
    _startClock(); // Mulai jam setelah API selesai
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
    await Future.delayed(const Duration(seconds: 3)); // Simulasi loading API
    setState(() {
      _isApiLoaded = true; // API selesai dimuat
    });
    _startClock(); // Mulai jam setelah API selesai
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
    await Future.delayed(const Duration(seconds: 3)); // Simulasi loading API
    setState(() {
      _isApiLoaded = true; // API selesai dimuat
    });
    _startClock(); // Mulai jam setelah API selesai
    var data = await ApiService.sendRequest(endpoint: "other/get-th");
    if (data == null) return;

    setState(() {
      announcements = List<String>.from(data['data']
          .where((item) => item['status']['id'] == 1)
          .map((item) => item['message']));
      _startAutoSlide();
      _isApiLoaded = true;
      _startClock(); // Mulai timer hanya setelah data selesai di-load
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

  Future<void> getcekwfa() async {
    var data =
        await ApiService.sendRequest(endpoint: 'request-history/is-wfa-today');
    if (data != null && data['message'] == 'User sudah mengajukan WFA') {
      setState(() {
        isWFARequested = true;
        Id = data['data']['id'].toString();
      });
    } else {
      setState(() {
        isWFARequested = false;
        Id = null;
        _isApiLoaded = true;
        _startClock(); // Mulai timer hanya setelah data selesai di-load
      });
    }
  }

  bool _isFakeLocation(Position position) {
    // Cek apakah lokasi di-mock (hanya support di beberapa device Android)
    if (position.isMocked) {
      print("Deteksi Fake GPS dari isMocked!");
      return true;
    }

    // Cek perubahan lokasi yang tiba-tiba (lompat jauh dalam waktu singkat)
    if (lastKnownPosition != null) {
      double distance = Geolocator.distanceBetween(
        lastKnownPosition!.latitude,
        lastKnownPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      double timeDiff = position.timestamp
          .difference(lastKnownPosition!.timestamp)
          .inSeconds
          .toDouble();
      double speed =
          distance / (timeDiff > 0 ? timeDiff : 1); // Kecepatan dalam m/s

      print("Jarak berpindah: $distance meter, Kecepatan: $speed m/s");

      if (speed > 50) {
        // Kalau kecepatan lebih dari 50 m/s (180 km/jam), kemungkinan fake
        print("Deteksi Fake GPS dari kecepatan tinggi!");
        return true;
      }
    }

    return false;
  }

  // Fungsi untuk mengambil data dari API
  Future<void> getData() async {
    try {
      // Ambil lokasi user
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // Cek apakah lokasi menggunakan Fake GPS
      bool isFake = _isFakeLocation(position);

      if (isFake) {
        _showFakeGpsWarning();
        return; // Hentikan proses selanjutnya kalau fake GPS terdeteksi
      }

      // Simpan lokasi terakhir buat perbandingan nanti
      lastKnownPosition = position;

      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      // Ambil profil pengguna
      var profileData =
          await ApiService.sendRequest(endpoint: 'karyawan/get-profile');
      if (profileData != null) {
        setState(() {
          userStatus = profileData['data']['user_level_id'].toString();
          name = profileData['data']['name'];
          Id = profileData['data']['id'].toString(); // ID WFH

          double officeLatitude = double.tryParse(
                  profileData['data']['gedung']['latitude'].toString()) ??
              0.0;
          double officeLongitude = double.tryParse(
                  profileData['data']['gedung']['longitude'].toString()) ??
              0.0;

          // Hitung jarak user dengan kantor
          double distance = Geolocator.distanceBetween(
              userLatitude, userLongitude, officeLatitude, officeLongitude);

          print("Jarak dari kantor: $distance meter");
          if (userStatus == "1" || userStatus == "2") {
            if (!isWFARequested) {
              // Jika tidak request WFA, cek jarak
              print("Jarak dari kantor: $distance meter");
              jarak = distance > 500; // Jarak untuk Clock In dihitung
            } else {
              jarak = false; // Jika user request WFA, jarak tidak berjalan
            }
            jarakclockout =
                distance > 500; // Jarak untuk Clock Out selalu dihitung
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
            isovertime = false;

            final hasHoliday =
                clockInData['data']['attendance_status_id'] ?? false;
            if (hasHoliday == 5) {
              isholiday = true;
            } else {
              isSuccess = true; // Clock-in berhasil sebelum jam 8 pagi
            }
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

      // Cek status cuti
      var cutiData =
          await ApiService.sendRequest(endpoint: 'attendance/is-cuti');
      if (cutiData != null && cutiData['message'] != null) {
        setState(() {
          hasCuti = cutiData['message'] == 'sedang cuti';
        });
      }

      // Cek status clock-out-lupa
      var liburData = await ApiService.sendRequest(
          endpoint: 'other/cek-libur'); // Ganti endpoint jika perlu

      if (liburData != null && liburData['libur'] != null) {
        setState(() {
          hasholiday = liburData['libur']; // true jika lupa, false jika tidak
        });
      }

      // Setelah semua API selesai, baru mulai timer
      setState(() {
        _isApiLoaded = true;
        _startClock(); // Mulai timer hanya setelah data selesai di-load
      });
    } catch (e) {
      print("Error saat cek cuti: $e");
    }
  }

  Future<void> getUserInfo({int cutOff = 0}) async {
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/karyawan/get-user-info?cutOff=$cutOff');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      final token = localStorage.getString('token');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final bulanIni = data['data_bulan_ini'];
        final bulanLalu = data['data_bulan_lalu'];

        setState(() {
          name = data['data']['nama'];
          hariBulanIni = bulanIni['hari'];
          menitBulanIni = bulanIni['menit'];
          telatBulanIni = bulanIni['menit_telat'];
          cutiBulanIni = bulanIni['cuti'];

          hariBulanLalu = bulanLalu['hari'];
          menitBulanLalu = bulanLalu['menit'];
          telatBulanLalu = bulanLalu['menit_telat'];
          cutiBulanLalu = bulanLalu['cuti'];

          // Ambil kehadiran aktual dari getUserInfo untuk bulan ini dan sebelumnya
          hadirHariIni = bulanIni['hari'];
          hadirMenitIni = bulanIni['menit'];
          hadirHariSebelumnya = bulanLalu['hari'];
          hadirMenitSebelumnya = bulanLalu['menit'];
        });
      } else {
        print('Error fetching user info: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Widget buildRekapBox(String title, int hari, int menit, int telat, int cuti) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatItem("$hari", "Masuk", Colors.blue, "Hari"),
              buildStatItem("$menit", "Durasi Kerja", Colors.green, "Menit"),
              buildStatItem("$telat", "Durasi Terlambat", Colors.red, "Menit"),
              buildStatItem("$cuti", "Cuti", Colors.orange, "Hari"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatItem(String value, String label, Color color, String unit) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Future<void> getTarget() async {
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/attendance/get-target-hour');
      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (rp.statusCode == 200) {
        final bulanIni = data['data']['bulan_ini'];
        final bulanSebelumnya = data['data']['bulan_sebelumnya'];

        setState(() {
          targetHariIni = bulanIni['target_hari'];
          targetMenitIni = bulanIni['target_menit'];

          targetHariSebelumnya = bulanSebelumnya['target_hari'];
          targetMenitSebelumnya = bulanSebelumnya['target_menit'];
        });
      } else {
        print('Error fetching target data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Widget buildProgressBox({
    required String title,
    required int hariMasuk,
    required int totalHari,
    required int menitMasuk,
    required int totalMenit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Masuk'),
          LinearProgressIndicator(
            value: totalHari == 0 ? 0 : hariMasuk / totalHari,
            color: Colors.lightBlue,
            backgroundColor: Colors.grey[300],
            minHeight: 10,
          ),
          Center(child: Text('$hariMasuk/$totalHari Hari')),
          const SizedBox(height: 10),
          Text('Durasi Kerja'),
          LinearProgressIndicator(
            value: totalMenit == 0 ? 0 : menitMasuk / totalMenit,
            color: Colors.green,
            backgroundColor: Colors.grey[300],
            minHeight: 10,
          ),
          Center(child: Text('$menitMasuk/$totalMenit Menit')),
        ],
      ),
    );
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
                    child: Column(children: [
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
                        DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
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
                              onPressed: hasClockedIn
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
                              onPressed: (hasClockedIn &&
                                      !hasClockedOut) // Disable jika belum Clock In atau sedang cuti
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
                                backgroundColor: (hasClockedIn &&
                                        !hasClockedOut) // Disable jika belum Clock In atau sedang cuti
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ] else if
                          // hasClockedOut &&
                          (userStatus == "1" || userStatus == "2") ...[
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
                                    onPressed:
                                        hasClockedIn // Disable jika sudah Clock In atau sedang cuti
                                            ? null
                                            : () async {
                                                if (jarak) {
                                                  _showClockInPopupWFA(
                                                      context); // Tampilkan pop-up WFA jika request WFA
                                                } else {
                                                  // Jika tidak WFH/WFA, langsung Clock In tanpa pop-up
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
                                    onPressed: (hasClockedIn &&
                                            !hasClockedOut) // Disable jika belum Clock In atau sedang cuti
                                        ? () async {
                                            if (jarak) {
                                              _showClockoutPopupjarak(context);
                                            } else {
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

                                                // Reset tombol setelah 1 detik
                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  if (mounted) {
                                                    setState(() {
                                                      hasClockedIn = false;
                                                      hasClockedOut = false;
                                                    });
                                                  }
                                                });
                                              }
                                            }
                                          }
                                        : null,
                                    icon: const Icon(Icons.logout),
                                    label: const Text('Clock Out'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (hasClockedIn &&
                                              !hasClockedOut) // Disable jika belum Clock In atau sedang cuti
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
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ClockInPage(),
                                              ),
                                            );
                                            if (result == true) {
                                              setState(() {
                                                hasClockedInOvertime = true;
                                                hasClockedOutOvertime = false;
                                              });
                                            }
                                          },
                                    icon: const Icon(Icons.timer),
                                    label: const Text(
                                      'Overtime In',
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ClockOutScreen(),
                                              ),
                                            );
                                            if (result == true) {
                                              setState(() {
                                                hasClockedOutOvertime = false;
                                                hasClockedInOvertime = false;
                                              });
                                            }
                                          }
                                        : null,
                                    icon: const Icon(Icons.timer_off),
                                    label: const Text(
                                      'Overtime Out',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (hasClockedInOvertime &&
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
                    ]),
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
                              _buildMenuShortcut(
                                label: 'Inventaris',
                                // onTap: () => _showComingSoonDialog(
                                //     context), // ubah ke onTap
                                targetPage: InventoryScreen(),
                                bgColor: const Color.fromRGBO(101, 19, 116, 1),
                                imagePath: 'assets/icon/gudang.png',
                                iconColor: Colors.white,
                                iconSize: 32,
                                labelStyle: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 14,
                                ),
                              ),
                              _buildMenuShortcut(
                                label: 'Peraturan \n kantor',
                                // onTap: () => _showComingSoonDialog(
                                //     context), // ubah ke onTap
                                targetPage: PeraturanScreen(),
                                bgColor: const Color.fromRGBO(101, 19, 116, 1),
                                imagePath: 'assets/icon/policy.png',
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
                  if (isovertime)
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
                  // Target Kehadiran
                  buildProgressBox(
                    title: "Target Kehadiran Bulan Berjalan",
                    hariMasuk: hadirHariIni,
                    totalHari: targetHariIni,
                    menitMasuk: hadirMenitIni,
                    totalMenit: targetMenitIni,
                  ),
                  buildRekapBox("Rekap Kehadiran Bulan Ini", hariBulanIni,
                      menitBulanIni, telatBulanIni, cutiBulanIni),
                  buildProgressBox(
                    title: "Target Kehadiran Bulan Sebelumnya",
                    hariMasuk: hadirHariSebelumnya,
                    totalHari: targetHariSebelumnya,
                    menitMasuk: hadirMenitSebelumnya,
                    totalMenit: targetMenitSebelumnya,
                  ),
                  buildRekapBox("Rekap Kehadiran Bulan Lalu", hariBulanLalu,
                      menitBulanLalu, telatBulanLalu, cutiBulanLalu),
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ClockInPage()),
                                    ); // Jika dalam kantor, langsung ke halaman Clock In
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
