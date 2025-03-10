// import 'package:flutter/material.dart';
// import 'package:absen/homepage/notif.dart'; // Mengimpor halaman notif
// import 'package:absen/Jamkelumas/ClockInPage.dart'; // Mengimpor halaman clockin
// import 'package:absen/Reimbursement/Reimbursementscreen.dart'; // Mengimpor halaman Reimbursement
// import 'package:absen/history/depan.dart'; // Mengimpor halaman history
// import 'package:absen/timeoff/TimeoffScreen.dart'; // Mengimpor halaman timeoff
// import 'package:absen/Jamkelumas/ClokOutPage.dart'; // Mengimpor halaman clockout
// import 'package:absen/Jamkelumas/Clockinwfa.dart';
// import 'package:absen/profil/profilscreen.dart'; // Mengimpor halaman profil
// import 'dart:async'; // Untuk timer
// import 'dart:convert';
// import 'package:intl/intl.dart'; //unntuk format tanggal
// import 'package:http/http.dart' as http; // menyambungakan ke API
// import 'package:geocoding/geocoding.dart'; //kordinat
// import 'package:geolocator/geolocator.dart'; //tempat
// import 'package:absen/utils/notification_helper.dart';
// import 'package:absen/utils/preferences.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:flutter_html/flutter_html.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final PageController _pageController =
//       PageController(); // PageController for PageView
//   String? name = ""; // Variabel untuk name pengguna
//   String? message; //variabel untuk th messange
//   String? avatarUrl; // Variable untuk avatar gambar
//   String? currentCity; // Menyimpan nama kota
//   String? clockInMessage; // Pesan yang ditampilkan berdasarkan waktu clock-in
//   String? userStatus;
//   String? wfhId; // Simpan ID WFH jika ada
//   String? _token;
//   String _currentTime = ""; // Variabel untuk menyimpan jam saat ini
//   Timer? _timer; // Timer untuk memperbarui jam setiap detik
//   Timer? resetNoteTimer; // Timer untuk mereset note, clock in & out, dan card
//   int currentIndex = 0; // Default to the home page
//   int _currentIndex = 0;
//   int _currentPage = 0;
//   // Variable to keep track of the current page
//   int? userId;
//   bool isLoadingLocation = true; // Untuk menandai apakah lokasi sedang di-load
//   bool hasClockedIn = false; // Status clock-in biasa
//   bool hasClockedOut = false; // Status clock-out biasa
//   bool hasClockedInOvertime = false; // Status clock-in lembur
//   bool hasClockedOutOvertime = false; // Status clock-out lembur
//   bool isCuti = false; // Status untuk menampilkan card cuti
//   bool showNote = true; // Status untuk menampilkan note
//   bool isSuccess = false; // Status untuk menampilkan card berhasil absen
//   bool isLate = false; // Status untuk card terlambat
//   bool isholiday = false; //status untuk card libur
//   bool isovertime = false; //status untuk card lembur
//   bool isWFHRequested = false; //status mengajukan WFH
//   bool jarak = false;
//   bool hasUnreadNotifications =
//       false; //Status untuk melihat notifikasi sudah di baca atau belum
//   List<dynamic> notifications = []; //variabel noifiaksi
//   List<String> announcements = []; // List untuk menyimpan pesan pengumuman

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     getData();
//     getPengumuman();
//     _startClock(); // Memulai timer untuk jam
//     // _resetNoteAtFiveAM();
//     getcancelwfh();
//     getcekwfh();
//     getNotif();
//     _loadToken();
//     saveFirebaseToken();
//     gettoken(); // Kirim token ke server setelah disimpan
//     _pageController.addListener(() {
//       _fetchUserProfile(); // Ambil data profil saat widget diinisialisasi
//       setState(() {
//         _currentPage = _pageController.page!.round();
//       });
//     });
//   }

//   Future<void> _fetchUserProfile() async {
//     try {
//       // Panggil API untuk mendapatkan URL avatar
//       final response = await http.get(Uri.parse('URL_API_PROFIL'));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           avatarUrl = data['avatarUrl']; // Pastikan key sesuai dengan API
//         });
//       }
//     } catch (e) {
//       print('Gagal memuat profil: $e');
//     }
//   }

//   // Fungsi untuk memulai jam dan memperbaruinya setiap detik
//   void _startClock() {
//     _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
//     _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
//       setState(() {
//         _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
//       });
//     });
//   }

//   // Fungsi untuk membuat menu shortcut dengan warna ikon dan latar belakang yang bisa disesuaikan
//   Column _buildMenuShortcut({
//     required String label,
//     TextStyle? labelStyle,
//     required Widget targetPage,
//     Color bgColor =
//         const Color.fromARGB(255, 101, 19, 116), // Warna background default
//     IconData? iconData, // Opsional untuk menggunakan Icon Flutter
//     String? imagePath, // Opsional untuk menggunakan gambar dari asset
//     Color iconColor = Colors.white, // Warna icon atau filter warna
//     double? iconSize = 30, // Ukuran default untuk ikon atau gambar
//   }) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => targetPage),
//             );
//           },
//           child: Container(
//             width: 60, // Lebar container shortcut
//             height: 60, // Tinggi container shortcut
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius:
//                   BorderRadius.circular(12), // Membuat sudut melengkung
//             ),
//             child: Center(
//               child: imagePath != null
//                   ? ColorFiltered(
//                       colorFilter: ColorFilter.mode(
//                         iconColor, // Warna filter yang diterapkan
//                         BlendMode.srcIn, // Mengatur mode blending
//                       ),
//                       child: Image.asset(
//                         imagePath,
//                         width: iconSize, // Sesuaikan ukuran gambar
//                         height: iconSize, // Sesuaikan ukuran gambar
//                         fit: BoxFit.contain,
//                       ),
//                     )
//                   : Icon(
//                       iconData,
//                       color: iconColor,
//                       size: iconSize,
//                     ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.pink, fontSize: 14),
//         ),
//       ],
//     );
//   }

//   // Fungsi untuk mendapatkan lokasi saat ini
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Mengecek apakah layanan lokasi tersedia
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Jika layanan lokasi tidak aktif, tampilkan pesan "Location not available"
//       setState(() {
//         currentCity = 'Lokasi tidak tersedia';
//         isLoadingLocation = false;
//       });
//       return;
//     }

//     // Meminta izin lokasi
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Jika izin lokasi ditolak, tampilkan pesan "Location not available"
//         setState(() {
//           currentCity = 'Lokasi tidak tersedia';
//           isLoadingLocation = false;
//         });
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Jika izin lokasi ditolak selamanya, tampilkan pesan "Location not available"
//       setState(() {
//         currentCity = 'Lokasi tidak tersedia';
//         isLoadingLocation = false;
//       });
//       return;
//     }

//     // Mendapatkan posisi pengguna jika semua syarat terpenuhi
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       // Menggunakan geocoding untuk mendapatkan nama kota dari koordinat
//       List<Placemark> placemarks =
//           await placemarkFromCoordinates(position.latitude, position.longitude);

//       if (placemarks.isNotEmpty) {
//         setState(() {
//           currentCity = placemarks.first.locality; // Mengambil nama kota
//           isLoadingLocation = false; // Lokasi selesai di-load
//         });
//       }
//     } catch (e) {
//       // Jika ada error lainnya, tampilkan pesan "Location not available"
//       setState(() {
//         currentCity = 'Lokasi tidak tersedia';
//         isLoadingLocation = false;
//       });
//     }
//   }

//   void _updateClockInStatusRegular(bool status) {
//     setState(() {
//       hasClockedIn = status;
//     });
//   }

//   void _updateClockInStatusOvertime(bool status) {
//     setState(() {
//       hasClockedInOvertime = status;
//     });
//   }

// // fungsi untuk memanggil bacaan notifikasi
//   Future<void> getNotif() async {
//     final url = Uri.parse(
//         'https://portal.eksam.cloud/api/v1/other/get-self-notification');
//     var request = http.MultipartRequest('GET', url);
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';

//     try {
//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (rp.statusCode == 200 && data['data'] != null) {
//         List<dynamic> loadedNotifications =
//             List.from(data['data']).map((notif) {
//           return {
//             // 'id': notif['id'],
//             // 'title': notif['title']?.toString(),
//             // 'description': notif['description']?.toString(),
//             // 'fileUrl': notif['file'] != null
//             //     ? "https://dev-portal.eksam.cloud/storage/file/${notif['file']}"
//             //     : null,
//             'isRead': notif['isRead'] ?? false,
//           };
//         }).toList();

//         // Cek status dari SharedPreferences
//         for (var notif in loadedNotifications) {
//           notif['isRead'] = await _isNotificationRead(notif['id']) ||
//               notif['isRead']; // Gabungkan status dari API dan lokal
//         }

//         setState(() {
//           notifications = loadedNotifications;
//           bool hasUnread = notifications.any((notif) => !notif['isRead']);
//           NotificationHelper.setUnreadNotifications(hasUnread); // Simpan status
//         });
//       } else {
//         setState(() {});
//       }
//     } catch (e) {
//       setState(() {});
//     }
//   }

//   Future<bool> _isNotificationRead(int id) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('notif_read_$id') ?? false;
//   }

//   Future<void> _markNotificationAsRead(int id) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('notif_read_$id', true);
//   }

//   Future<void> putRead(int id) async {
//     final url = Uri.parse(
//         'https://portal.eksam.cloud/api/v1/other/read-notification/$id');
//     var request = http.MultipartRequest('PUT', url);
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';

//     try {
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         // Tandai sebagai dibaca
//         await _markNotificationAsRead(id);

//         // Update status unread
//         bool hasUnread = notifications.any((notif) => !notif['isRead']);
//         await NotificationHelper.setUnreadNotifications(hasUnread);

//         setState(() {
//           notifications = notifications.map((notif) {
//             if (notif['id'] == id) {
//               notif['isRead'] = true;
//             }
//             return notif;
//           }).toList();
//         });
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }
//   //sampai sini buat notifikasi

//   // Fungsi untuk mengambil data dari API townhall
//   // Future<void> getPengumuman() async {
//   //   final url =
//   //       // Uri.parse('https://portal.eksam.cloud/api/v1/other/get-self-th');
//   //       Uri.parse('https://portal.eksam.cloud/api/v1/other/get-th');

//   //   var request = http.MultipartRequest('GET', url);
//   //   SharedPreferences localStorage = await SharedPreferences.getInstance();
//   //   request.headers['Authorization'] =
//   //       'Bearer ${localStorage.getString('token')}';

//   //   try {
//   //     var response = await request.send();
//   //     var rp = await http.Response.fromStream(response);
//   //     var data = jsonDecode(rp.body.toString());
//   //     print(data);

//   //     if (rp.statusCode == 200) {
//   //       setState(() {
//   //         announcements = List<String>.from(data['data']
//   //             .where((item) => item['status']['id'] == 1)
//   //             .map((item) => item['message'])).toList();
//   //       });
//   //       print(announcements);
//   //     } else {
//   //       print('Error fetching announcements: ${rp.statusCode}');
//   //       print(rp.body);
//   //     }
//   //   } catch (e) {
//   //     print('Error occurred: $e');
//   //   }
//   // }
//   Future<void> getPengumuman() async {
//     final url = Uri.parse('https://portal.eksam.cloud/api/v1/other/get-th');
//     var request = http.MultipartRequest('GET', url);
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';

//     try {
//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (rp.statusCode == 200) {
//         setState(() {
//           announcements = List<String>.from(data['data']
//               .where((item) => item['status']['id'] == 1)
//               .map((item) => item['message']));
//         });
//         _startAutoSlide();
//       } else {
//         print('Error fetching announcements: ${rp.statusCode}');
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   void _startAutoSlide() {
//     _timer?.cancel(); // Hentikan timer jika sebelumnya sudah berjalan
//     if (announcements.isNotEmpty) {
//       _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
//         if (_currentIndex < announcements.length - 1) {
//           _currentIndex++;
//         } else {
//           _currentIndex = 0; // Balik ke awal jika sudah di akhir
//         }
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel(); // Hentikan timer saat widget dihapus
//     _pageController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadToken() async {
//     String? token = await Preferences.getToken();
//     setState(() {
//       _token = token;
//     });
//   }

//   void saveFirebaseToken() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     String? token = await messaging.getToken(); // Ambil token Firebase

//     if (token != null) {
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       await localStorage.setString('firebase_token', token);
//       print("Token Firebase disimpan: $token");

//       gettoken(); // Kirim token ke server setelah disimpan
//     }
//   }

//   Future<void> gettoken() async {
//     final url = Uri.parse('https://portal.eksam.cloud/api/v1/other/send-token');

//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     String? token = localStorage
//         .getString('firebase_token'); // Ambil token Firebase dari local storage

//     if (token == null || token.isEmpty) {
//       print("Token Firebase tidak ditemukan!");
//       return;
//     }

//     var request = http.MultipartRequest('POST', url);
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';
//     request.fields['firebase_token'] = token; // Kirim token Firebase ke API

//     try {
//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (rp.statusCode == 200) {
//         print("Token Firebase berhasil dikirim: $token");
//       } else {
//         print("Error mengirim token Firebase: ${rp.statusCode}");
//         print(rp.body);
//       }
//     } catch (e) {
//       print("Error occurred: $e");
//     }
//   }

//   Future<void> getcekwfh() async {
//     final url =
//         Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-wfh');
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     var headers = {
//       'Authorization': 'Bearer ${localStorage.getString('token')}'
//     };

//     try {
//       var response = await http.get(url, headers: headers);
//       var data = jsonDecode(response.body.toString());
//       print("Response API is-wfh: $data");

//       setState(() {
//         if (response.statusCode == 200 &&
//             data['message'] == 'User mengajukan WFH') {
//           isWFHRequested = true;
//           wfhId =
//               data['data']['id'].toString(); // Simpan ID WFH untuk pembatalan
//         } else {
//           isWFHRequested = false;
//           wfhId = null;
//         }
//       });
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   // Future getcekwfh() async {
//   //   final url =
//   //       Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-wfh');
//   //   SharedPreferences localStorage = await SharedPreferences.getInstance();
//   //   var headers = {
//   //     'Authorization': 'Bearer ${localStorage.getString('token')}'
//   //   };

//   //   try {
//   //     var response = await http.get(url, headers: headers);
//   //     var data = jsonDecode(response.body.toString());
//   //     print("Response API is-wfh: $data");
//   //     if (response.statusCode == 200) {
//   //       setState(() {
//   //         isWFHRequested = true;
//   //         wfhId =
//   //             data['data']['id'].toString(); // Simpan ID WFH untuk pembatalan
//   //       });
//   //     } else {
//   //       setState(() {
//   //         isWFHRequested = false;
//   //         wfhId = null;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print('Error occurred: $e');
//   //   }
//   // }

//   // Future<void> getcancelwfh() async {
//   //   if (wfhId == null) return; // Pastikan ada ID WFH

//   //   final url = Uri.parse(
//   //       'https://portal.eksam.cloud/api/v1/attendance/cancel-wfh/$wfhId');
//   //   SharedPreferences localStorage = await SharedPreferences.getInstance();
//   //   var headers = {
//   //     'Authorization': 'Bearer ${localStorage.getString('token')}'
//   //   };

//   //   try {
//   //     var response = await http.delete(url, headers: headers);
//   //     var data = jsonDecode(response.body.toString());
//   //     print("Response API cancel-wfh: $data");
//   //     if (response.statusCode == 200) {
//   //       setState(() {
//   //         isWFHRequested = false;
//   //         wfhId = null;
//   //       });

//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //             content: Text('WFH berhasil dibatalkan'),
//   //             backgroundColor: Colors.green),
//   //       );
//   //     } else {
//   //       print('Gagal membatalkan WFH: ${data['message']}');
//   //     }
//   //   } catch (e) {
//   //     print('Error occurred: $e');
//   //   }
//   // }

//   // Future<bool> getcancelwfh() async {
//   //   if (wfhId == null)
//   //   //  return true
//   //    ; // Pastikan ada ID WFH

//   //   final url = Uri.parse(
//   //       'https://portal.eksam.cloud/api/v1/attendance/cancel-wfh/$wfhId');
//   //   SharedPreferences localStorage = await SharedPreferences.getInstance();
//   //   var headers = {
//   //     'Authorization': 'Bearer ${localStorage.getString('token')}'
//   //   };

//   //   try {
//   //     var response = await http.delete(url, headers: headers);
//   //     var data = jsonDecode(response.body.toString());
//   //     print("Response API cancel-wfh: $data");
//   //     print("Full Response: $data");
//   //     if (response.statusCode == 200) {
//   //       setState(() {
//   //         isWFHRequested = false;
//   //         wfhId = null;
//   //       });

//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //             content: Text('WFH berhasil dibatalkan'),
//   //             backgroundColor: Colors.green),
//   //       );

//   //       return true; // Berhasil membatalkan WFH
//   //     } else {
//   //       print('Gagal membatalkan WFH: ${data['message']}');
//   //       return false;
//   //     }
//   //   } catch (e) {
//   //     print('Error occurred: $e');
//   //     return false;
//   //   }
//   // }

//   Future<bool> getcancelwfh() async {
//     if (wfhId == null) {
//       print("Gagal membatalkan WFH: wfhId tidak ditemukan");
//       return false;
//     }

//     final url = Uri.parse(
//         'https://portal.eksam.cloud/api/v1/attendance/cancel-wfh/$wfhId');
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     var headers = {
//       'Authorization': 'Bearer ${localStorage.getString('token')}',
//       'Accept':
//           'application/json', // Tambahkan ini untuk memastikan format JSON
//     };

//     try {
//       var response = await http.delete(url, headers: headers);

//       // Debugging output
//       print("Response Status Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         print("Response API cancel-wfh: $data");

//         setState(() {
//           isWFHRequested = false;
//           wfhId = null;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('WFH berhasil dibatalkan'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         return true;
//       } else {
//         print("Gagal membatalkan WFH. Status Code: ${response.statusCode}");
//         print("Response Body: ${response.body}");
//         return false;
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//       return false;
//     }
//   }

//   // Fungsi untuk mengambil data dari API
//   Future<void> getData() async {
//     // Ambil profil pengguna
//     try {
//       // Ambil lokasi user
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       double userLatitude = position.latitude;
//       double userLongitude = position.longitude;

//       final url =
//           Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (rp.statusCode == 200) {
//         setState(() {
//           userStatus = data['data']['user_level_id'].toString();
//           name = data['data']['name'];
//           wfhId =
//               data['data']['id'].toString(); // Simpan ID WFH untuk pembatalan

//           double officeLatitude =
//               double.tryParse(data['data']['latitude'].toString()) ?? 0.0;
//           double officeLongitude =
//               double.tryParse(data['data']['longitude'].toString()) ?? 0.0;

//           // _compareDistance(officeLongitude, officeLatitude);

//           // Hitung jarak antara user dan kantor
//           double distance = Geolocator.distanceBetween(
//               userLatitude, userLongitude, officeLatitude, officeLongitude);

//           print("Jarak dari kantor: $distance meter");
//           print("Lokasi User: $userLatitude, $userLongitude");
//           print("Lokasi Kantor: $officeLatitude, $officeLongitude");
//           print("Jarak antara User dan Kantor: $distance meter");

//           print("Jarak dari kantor: $distance meter");
//           print("User level: $userStatus");

//           if (distance > 500) {
//             // Jika lebih dari 500 meter, hanya munculkan WFH
//             jarak = true;
//           } else {
//             // Jika kurang dari 500 meter, munculkan semua opsi
//             jarak = false;
//           }
//         });
//       } else {
//         print("Error mengambil profil pengguna: ${rp.statusCode}");
//       }
//     } catch (e) {
//       print("Error mengambil data lokasi: $e");
//     }

//     // Cek status clock-in
//     try {
//       final url =
//           Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-clock-in');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       setState(() {
//         // Status clock-in diambil dari respons API
//         hasClockedIn = data['message'] != 'belum clock-in';
//         print(data['data']);
//         if (hasClockedIn) {
//           showNote = false;

//           final hasHoliday = data['data']['attendance_status_id'] ?? false;
//           if (hasHoliday == 5) {
//             isholiday = true;
//           } else {
//             isSuccess = true; // Clock-in berhasil sebelum jam 8 pagi
//           }
//         }
//       });
//     } catch (e) {
//       print("Error mengecek status clock-in: $e");
//     }

//     // Cek status clock-out
//     try {
//       final url = Uri.parse(
//           'https://portal.eksam.cloud/api/v1/attendance/is-clock-out');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       setState(() {
//         print(hasClockedOut);
//         hasClockedOut = data['message'] == 'sudah clock-out';
//       });
//     } catch (e) {
//       print("Error mengecek status clock-out: $e");
//     }

//     // Cek status lembur masuk
//     if (userStatus == "1" || userStatus == "2"
//         // userStatus != "3"
//         ) {
//       try {
//         final url = Uri.parse(
//             'https://portal.eksam.cloud/api/v1/attendance/is-lembur-in');
//         SharedPreferences localStorage = await SharedPreferences.getInstance();

//         var request = http.MultipartRequest('GET', url);
//         request.headers['Authorization'] =
//             'Bearer ${localStorage.getString('token')}';

//         var response = await request.send();
//         var rp = await http.Response.fromStream(response);
//         var data = jsonDecode(rp.body.toString());

//         setState(() {
//           hasClockedInOvertime = data['message'] != 'belum clock-in';
//           if (hasClockedInOvertime) {
//             showNote = false;
//             isSuccess = false;
//             isholiday = false;
//             isovertime = true;
//           }
//         });
//       } catch (e) {
//         print("Error mengecek status clock-out: $e");
//       }
//       // Cek status lembur keluar
//       try {
//         final url = Uri.parse(
//             'https://portal.eksam.cloud/api/v1/attendance/is-lembur-out');
//         SharedPreferences localStorage = await SharedPreferences.getInstance();

//         var request = http.MultipartRequest('GET', url);
//         request.headers['Authorization'] =
//             'Bearer ${localStorage.getString('token')}';

//         var response = await request.send();
//         var rp = await http.Response.fromStream(response);
//         var data = jsonDecode(rp.body.toString());

//         setState(() {
//           hasClockedOutOvertime = data['message'] != 'belum clock-out';
//         });
//       } catch (e) {
//         print("Error mengecek status clock-out: $e");
//       }
//     }
//   }

//   // Fungsi untuk mereset status setiap jam 5 pagi
//   // void _resetNoteAtFiveAM() {
//   //   final now = DateTime.now();
//   //   final fiveAM = DateTime(now.year, now.month, now.day, 5);
//   //   final timeUntilReset = fiveAM.isBefore(now)
//   //       ? fiveAM.add(const Duration(days: 1)).difference(now)
//   //       : fiveAM.difference(now);

//   //   resetNoteTimer = Timer(timeUntilReset, () {
//   //     setState(() {
//   //       hasClockedIn = false;
//   //       hasClockedOut = false;
//   //       hasClockedInOvertime = false;
//   //       hasClockedOutOvertime = false;
//   //       showNote = true;
//   //       isSuccess = false;
//   //       isLate = false;
//   //       isholiday = false;
//   //       isovertime = false;
//   //       clockInMessage = null;
//   //     });
//   //   });
//   // }

//   // @override
//   // void dispose() {
//   //   resetNoteTimer?.cancel(); // Membatalkan timer saat widget dibuang
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Bagian Header
//             Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.orange,
//                     Colors.pink,
//                     Color.fromARGB(255, 101, 19, 116)
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       GestureDetector(
//                         onTap: () async {
//                           // Navigasi ke halaman profil dan tunggu hasilnya
//                           final updatedAvatarUrl = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const ProfileScreen(),
//                             ),
//                           );

//                           // Perbarui avatar jika ada perubahan
//                           if (updatedAvatarUrl != null) {
//                             setState(() {
//                               avatarUrl = updatedAvatarUrl;
//                             });
//                           }
//                         },
//                         child: CircleAvatar(
//                           radius: 25,
//                           backgroundColor: Colors.grey[200],
//                           backgroundImage: avatarUrl != null
//                               ? const NetworkImage('avatarUrl')
//                               : const AssetImage('assets/image/logo_circle.png')
//                                   as ImageProvider,
//                           // child: avatarUrl == null
//                           //     ? Icon(Icons.person, color: Colors.grey)
//                           //     : null,
//                         ),
//                       ),
//                       // Menampilkan waktu yang di-update setiap detik
//                       Text(
//                         _currentTime,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color:
//                               Color.fromARGB(255, 255, 255, 255), // Warna teks
//                         ),
//                       ),
//                       // notifikasi icon
//                       IconButton(
//                         icon: Stack(
//                           children: [
//                             const Icon(Icons.notifications,
//                                 color: Colors.white),
//                             FutureBuilder<bool>(
//                               future:
//                                   NotificationHelper.hasUnreadNotifications(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData && snapshot.data == true) {
//                                   return const Positioned(
//                                     right: 0,
//                                     top: 0,
//                                     child: Icon(
//                                       Icons.circle,
//                                       color: Colors.red,
//                                       size: 10,
//                                     ),
//                                   );
//                                 }
//                                 return const SizedBox.shrink();
//                               },
//                             ),
//                           ],
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const NotificationPage()),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // menamplakan nama pengguna
//                   Text(
//                     'Selamat Datang, \n$name',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Text(
//                     'Jangan Lupa Absen Hari ini✨',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Column(
//                       children: [
//                         // untuk melihat kota / lokasi terkini
//                         Text(
//                           isLoadingLocation
//                               ? 'Memuat lokasi Anda...'
//                               : 'Lokasi Anda Sekarang Ada Di $currentCity',
//                           style: const TextStyle(
//                               color: Colors.black54, fontSize: 12),
//                         ),
//                         const SizedBox(height: 8),
//                         //menampilkan hari dan tanggal
//                         Text(
//                           DateFormat('EEEE, dd MMMM yyyy')
//                               .format(DateTime.now()),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 18),
//                         // if (
//                         //     // userStatus == "1" ||
//                         //     //   userStatus == "2" ||
//                         //     userStatus == "3") ...[
//                         //   // if (hasClockedOut) ...[
//                         //   // Clock In & Clock Out buttons
//                         //   Row(
//                         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         //     children: [
//                         //       ElevatedButton.icon(
//                         //         onPressed: hasClockedIn
//                         //             ? null
//                         //             : () async {
//                         //                 final result = await Navigator.push(
//                         //                   context,
//                         //                   MaterialPageRoute(
//                         //                     builder: (context) =>
//                         //                         const ClockInPage(),
//                         //                   ),
//                         //                 );
//                         //                 if (result == true) {
//                         //                   setState(() {
//                         //                     hasClockedIn = true;
//                         //                     hasClockedOut = false;
//                         //                   });
//                         //                 }
//                         //               },
//                         //         icon: const Icon(Icons.login),
//                         //         label: const Text('Clock In'),
//                         //         style: ElevatedButton.styleFrom(
//                         //           backgroundColor:
//                         //               hasClockedIn ? Colors.grey : Colors.white,
//                         //         ),
//                         //       ),
//                         //       ElevatedButton.icon(
//                         //         onPressed: hasClockedIn && !hasClockedOut
//                         //             ? () async {
//                         //                 final result = await Navigator.push(
//                         //                   context,
//                         //                   MaterialPageRoute(
//                         //                     builder: (context) =>
//                         //                         const ClockOutScreen(),
//                         //                   ),
//                         //                 );
//                         //                 if (result == true) {
//                         //                   setState(() {
//                         //                     hasClockedOut = true;
//                         //                   });
//                         //                 }
//                         //               }
//                         //             : null,
//                         //         icon: const Icon(Icons.logout),
//                         //         label: const Text('Clock Out'),
//                         //         style: ElevatedButton.styleFrom(
//                         //           backgroundColor:
//                         //               hasClockedIn && !hasClockedOut
//                         //                   ? Colors.white
//                         //                   : Colors.grey,
//                         //         ),
//                         //       ),
//                         //     ],
//                         //   ),
//                         // ]
//                         if (userStatus == "3") ...[
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               ElevatedButton.icon(
//                                 onPressed: hasClockedIn
//                                     ? null
//                                     : () async {
//                                         final result = await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 const ClockInPage(),
//                                           ),
//                                         );
//                                         if (result == true) {
//                                           setState(() {
//                                             hasClockedIn = true;
//                                             hasClockedOut = false;
//                                           });
//                                         }
//                                       },
//                                 icon: const Icon(Icons.login),
//                                 label: const Text('Clock In'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                       hasClockedIn ? Colors.grey : Colors.white,
//                                 ),
//                               ),
//                               ElevatedButton.icon(
//                                 onPressed: hasClockedIn && !hasClockedOut
//                                     ? () async {
//                                         final result = await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 const ClockOutScreen(),
//                                           ),
//                                         );
//                                         if (result == true) {
//                                           setState(() {
//                                             hasClockedOut = true;
//                                             hasClockedIn = false;
//                                           });

//                                           // Reset tombol setelah 1 detik
//                                           Future.delayed(
//                                               const Duration(seconds: 1), () {
//                                             if (mounted) {
//                                               setState(() {
//                                                 hasClockedIn = false;
//                                                 hasClockedOut = false;
//                                               });
//                                             }
//                                           });
//                                         }
//                                       }
//                                     : null,
//                                 icon: const Icon(Icons.logout),
//                                 label: const Text('Clock Out'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                       hasClockedIn && !hasClockedOut
//                                           ? Colors.white
//                                           : Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ] else if
//                             // hasClockedOut &&
//                             (userStatus == "1" || userStatus == "2") ...[
//                           if (isWFHRequested) ...[
//                             // Jika user level 1 atau 2 telah request WFH
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 ElevatedButton.icon(
//                                   onPressed:
//                                       null, // Tombol Pending selalu disabled
//                                   icon: const Icon(Icons.hourglass_empty),
//                                   label: const Text('Pending'),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.grey,
//                                     foregroundColor: Colors.white,
//                                   ),
//                                 ),
//                                 ElevatedButton.icon(
//                                   onPressed: () async {
//                                     final success =
//                                         await getcancelwfh(); // Fungsi untuk membatalkan WFH
//                                     if (success) {
//                                       setState(() {
//                                         isWFHRequested = false;
//                                         hasClockedIn =
//                                             false; // Clock In aktif kembali
//                                         hasClockedInOvertime = false;
//                                         hasClockedOutOvertime = false;
//                                         hasClockedOut = false; // Clock Out mati
//                                       });
//                                     }
//                                   },
//                                   icon: const Icon(Icons.cancel),
//                                   label: const Text('Batalkan'),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red,
//                                     foregroundColor: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           ] else ...[
//                             // Jika belum request WFH, cek apakah sudah clock out
//                             Column(
//                               children: [
//                                 // Tampilkan Clock In & Out jika belum Clock Out
//                                 if (!hasClockedOut) ...[
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       // ElevatedButton.icon(
//                                       //   onPressed: hasClockedIn
//                                       //       ? null
//                                       //       : () async {
//                                       //           final result =
//                                       //               await Navigator.push(
//                                       //             context,
//                                       //             MaterialPageRoute(
//                                       //               builder: (context) =>
//                                       //                   const ClockInPage(),
//                                       //             ),
//                                       //           );
//                                       //           if (result == true) {
//                                       //             setState(() {
//                                       //               hasClockedIn = true;
//                                       //               hasClockedOut = false;
//                                       //             });
//                                       //           }
//                                       //         },
//                                       //   icon: const Icon(Icons.login),
//                                       //   label: const Text('Clock In'),
//                                       //   style: ElevatedButton.styleFrom(
//                                       //     backgroundColor: hasClockedIn
//                                       //         ? Colors.grey
//                                       //         : Colors.white,
//                                       //   ),
//                                       // ),
//                                       ElevatedButton.icon(
//                                         onPressed: hasClockedIn
//                                             ? null
//                                             : () async {
//                                                 if (jarak) {
//                                                   // Jika user WFH, tampilkan pop-up konfirmasi
//                                                   bool? confirm =
//                                                       await showDialog(
//                                                     context: context,
//                                                     builder: (context) =>
//                                                         AlertDialog(
//                                                       title: const Text(
//                                                           "Konfirmasi Clock In"),
//                                                       content: const Text(
//                                                           "Lokasi Anda tidak dalam radius kantor. Ajukan WFH? "),
//                                                       actions: [
//                                                         ElevatedButton(
//                                                           onPressed: () {
//                                                             Navigator.pop(
//                                                                 context,
//                                                                 false); // Tutup pop-up
//                                                           },
//                                                           child: const Text(
//                                                               "Cancel"),
//                                                         ),
//                                                         ElevatedButton(
//                                                           onPressed: () {
//                                                             Navigator.pop(
//                                                                 context,
//                                                                 true); // Lanjut Clock In
//                                                           },
//                                                           child: const Text(
//                                                               "Ajukan WFH"),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );

//                                                   // Jika user memilih "Clock In", baru navigasi ke halaman Clock In
//                                                   if (confirm == true) {
//                                                     final result =
//                                                         await Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             const ClockInPage(),
//                                                       ),
//                                                     );
//                                                     if (result == true) {
//                                                       setState(() {
//                                                         hasClockedIn = true;
//                                                         hasClockedOut = false;
//                                                       });
//                                                     }
//                                                   }
//                                                 } else {
//                                                   // Jika tidak WFH, langsung Clock In tanpa pop-up
//                                                   final result =
//                                                       await Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           const ClockInPage(),
//                                                     ),
//                                                   );
//                                                   if (result == true) {
//                                                     setState(() {
//                                                       hasClockedIn = true;
//                                                       hasClockedOut = false;
//                                                     });
//                                                   }
//                                                 }
//                                               },
//                                         icon: const Icon(Icons.login),
//                                         label: const Text('Clock In'),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: hasClockedIn
//                                               ? Colors.grey
//                                               : Colors.white,
//                                         ),
//                                       ),
//                                       ElevatedButton.icon(
//                                         onPressed:
//                                             hasClockedIn && !hasClockedOut
//                                                 ? () async {
//                                                     final result =
//                                                         await Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             const ClockOutScreen(),
//                                                       ),
//                                                     );
//                                                     if (result == true) {
//                                                       setState(() {
//                                                         hasClockedOut = true;
//                                                         hasClockedIn = false;
//                                                       });
//                                                     }
//                                                   }
//                                                 : null,
//                                         icon: const Icon(Icons.logout),
//                                         label: const Text('Clock Out'),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor:
//                                               hasClockedIn && !hasClockedOut
//                                                   ? Colors.white
//                                                   : Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ] else
//                                   // const SizedBox(height: 10), // Jarak antar tombol
//                                   // Jika sudah Clock Out, tampilkan Overtime In & Out, dan sembunyikan Clock In & Out
//                                   ...[
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       ElevatedButton.icon(
//                                         onPressed: hasClockedInOvertime
//                                             ? null
//                                             : () async {
//                                                 final result =
//                                                     await Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         const ClockInPage(),
//                                                   ),
//                                                 );
//                                                 if (result == true) {
//                                                   setState(() {
//                                                     hasClockedInOvertime = true;
//                                                     hasClockedOutOvertime =
//                                                         false;
//                                                   });
//                                                 }
//                                               },
//                                         icon: const Icon(Icons.timer),
//                                         label: const Text('Overtime In'),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: hasClockedInOvertime
//                                               ? Colors.grey
//                                               : Colors.white,
//                                         ),
//                                       ),
//                                       ElevatedButton.icon(
//                                         onPressed: hasClockedInOvertime &&
//                                                 !hasClockedOutOvertime
//                                             ? () async {
//                                                 final result =
//                                                     await Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         const ClockOutScreen(),
//                                                   ),
//                                                 );
//                                                 if (result == true) {
//                                                   setState(() {
//                                                     hasClockedOutOvertime =
//                                                         false;
//                                                     hasClockedInOvertime =
//                                                         false;
//                                                   });
//                                                 }
//                                               }
//                                             : null,
//                                         icon: const Icon(Icons.timer_off),
//                                         label: const Text('Overtime Out'),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor:
//                                               hasClockedInOvertime &&
//                                                       !hasClockedOutOvertime
//                                                   ? Colors.white
//                                                   : Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ]
//                               ],
//                             )
//                           ]
//                         ]
//                         //     (userStatus == "1" || userStatus == "2") ...[
//                         //   if (!hasClockedOut) ...[
//                         //     // Overtime In & Overtime Out buttons
//                         //     Row(
//                         //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         //       children: [
//                         //         ElevatedButton.icon(
//                         //           onPressed: hasClockedIn
//                         //               ? null
//                         //               : () async {
//                         //                   final result = await Navigator.push(
//                         //                     context,
//                         //                     MaterialPageRoute(
//                         //                       builder: (context) =>
//                         //                           const ClockInPage(),
//                         //                     ),
//                         //                   );
//                         //                   if (result == true) {
//                         //                     setState(() {
//                         //                       hasClockedIn = true;
//                         //                       hasClockedOut = false;
//                         //                     });
//                         //                   }
//                         //                 },
//                         //           icon: const Icon(Icons.login),
//                         //           label: const Text('Clock In'),
//                         //           style: ElevatedButton.styleFrom(
//                         //             backgroundColor: hasClockedIn
//                         //                 ? Colors.grey
//                         //                 : Colors.white,
//                         //           ),
//                         //         ),
//                         //         ElevatedButton.icon(
//                         //           onPressed: hasClockedIn && !hasClockedOut
//                         //               ? () async {
//                         //                   final result = await Navigator.push(
//                         //                     context,
//                         //                     MaterialPageRoute(
//                         //                       builder: (context) =>
//                         //                           const ClockOutScreen(),
//                         //                     ),
//                         //                   );
//                         //                   if (result == true) {
//                         //                     setState(() {
//                         //                       hasClockedOut = true;
//                         //                       hasClockedIn = false;
//                         //                     });
//                         //                   }
//                         //                 }
//                         //               : null,
//                         //           icon: const Icon(Icons.logout),
//                         //           label: const Text('Clock Out'),
//                         //           style: ElevatedButton.styleFrom(
//                         //             backgroundColor:
//                         //                 hasClockedIn && !hasClockedOut
//                         //                     ? Colors.white
//                         //                     : Colors.grey,
//                         //           ),
//                         //         ),
//                         //       ],
//                         //     ),
//                         //   ] else ...[
//                         //     Row(
//                         //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         //       children: [
//                         //         ElevatedButton.icon(
//                         //           onPressed: hasClockedInOvertime
//                         //               ? null
//                         //               : () async {
//                         //                   final result = await Navigator.push(
//                         //                     context,
//                         //                     MaterialPageRoute(
//                         //                         builder: (context) =>
//                         //                             const ClockInPage()),
//                         //                   );
//                         //                   if (result == true) {
//                         //                     setState(() {
//                         //                       hasClockedInOvertime = true;
//                         //                       hasClockedOutOvertime = false;
//                         //                     });
//                         //                   }
//                         //                 },
//                         //           icon: const Icon(Icons.login),
//                         //           label: const Text(
//                         //             'Overtime In',
//                         //             // 'Clock In',
//                         //             style: TextStyle(
//                         //               fontSize: 12,
//                         //             ),
//                         //           ),
//                         //           style: ElevatedButton.styleFrom(
//                         //             backgroundColor: hasClockedInOvertime
//                         //                 ? Colors.grey
//                         //                 : Colors.white,
//                         //           ),
//                         //         ),
//                         //         ElevatedButton.icon(
//                         //           onPressed: hasClockedInOvertime &&
//                         //                   !hasClockedOutOvertime
//                         //               ? () async {
//                         //                   final result = await Navigator.push(
//                         //                     context,
//                         //                     MaterialPageRoute(
//                         //                         builder: (context) =>
//                         //                             const ClockOutScreen()),
//                         //                   );
//                         //                   if (result == true) {
//                         //                     setState(() {
//                         //                       hasClockedOutOvertime = true;
//                         //                       hasClockedInOvertime = false;
//                         //                     });
//                         //                   }
//                         //                 }
//                         //               : null,
//                         //           icon: const Icon(Icons.logout),
//                         //           label: const Text(
//                         //             'Overtime Out',
//                         //             // 'Clock out',
//                         //             style: TextStyle(
//                         //               fontSize: 12,
//                         //             ),
//                         //           ),
//                         //           style: ElevatedButton.styleFrom(
//                         //             backgroundColor: hasClockedInOvertime &&
//                         //                     !hasClockedOutOvertime
//                         //                 ? Colors.white
//                         //                 : Colors.grey,
//                         //           ),
//                         //         ),
//                         //       ],
//                         //     ),
//                         //   ]
//                         // ] else if (isWFHRequested &&
//                         //     (userStatus == "1" || userStatus == "2")) ...[
//                         //   Row(
//                         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         //     children: [
//                         //       ElevatedButton.icon(
//                         //         onPressed:
//                         //             null, // Tombol Pending selalu disabled
//                         //         icon: const Icon(Icons.hourglass_empty),
//                         //         label: const Text('Pending'),
//                         //         style: ElevatedButton.styleFrom(
//                         //           backgroundColor: Colors.grey,
//                         //           foregroundColor: Colors.white,
//                         //         ),
//                         //       ),
//                         //       ElevatedButton.icon(
//                         //         onPressed: getcancelwfh,
//                         //         icon: const Icon(Icons.cancel),
//                         //         label: const Text('Batalkan WFH'),
//                         //         style: ElevatedButton.styleFrom(
//                         //           backgroundColor: Colors.red,
//                         //           foregroundColor: Colors.white,
//                         //         ),
//                         //       ),
//                         //     ],
//                         //   )
//                         // ]
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Bagian Middle
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Menu Shortcut
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment
//                         .spaceAround, // Memberi jarak di antara shortcut
//                     children: [
//                       // Menggunakan gambar dari aset dan mengatur ukuran gambar
//                       _buildMenuShortcut(
//                         label: 'Time Off',
//                         targetPage: const TimeOffScreen(),
//                         bgColor: const Color.fromRGBO(
//                             101, 19, 116, 1), // Warna background
//                         imagePath:
//                             'assets/icon/timeoff.png', // Path gambar aset
//                         iconColor:
//                             Colors.white, // Warna yang diterapkan ke gambar
//                         iconSize: 32, // Ukuran gambar
//                         labelStyle: const TextStyle(
//                           color: Colors.pink, // Warna label menjadi pink
//                           fontSize: 14,
//                         ),
//                       ),
//                       // Menggunakan ikon bawaan Flutter dengan ukuran yang sama
//                       _buildMenuShortcut(
//                         label: 'Reimbursement',
//                         targetPage: const ReimbursementPage(),
//                         bgColor: const Color.fromARGB(
//                             255, 101, 19, 116), // Warna background
//                         iconData: Icons.receipt, // Ikon bawaan Flutter
//                         iconColor: Colors.white, // Warna ikon
//                         iconSize: 30, // Ukuran ikon
//                         labelStyle: const TextStyle(
//                           color: Colors.pink, // Warna label menjadi pink
//                           fontSize: 14,
//                         ),
//                       ),
//                       // Menggunakan gambar dari aset dan mengatur ukuran gambar
//                       _buildMenuShortcut(
//                         label: 'History',
//                         targetPage: const HistoryScreen(),
//                         bgColor: const Color.fromARGB(
//                             255, 101, 19, 116), // Warna background
//                         imagePath:
//                             'assets/icon/history.png', // Path gambar aset
//                         iconColor:
//                             Colors.white, // Warna yang diterapkan ke gambar
//                         iconSize: 26, // Ukuran gambar
//                         labelStyle: const TextStyle(
//                           color: Colors.pink, // Warna label menjadi pink
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   // Menu Shortcut
//                   Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.start, // Biar mulai dari kiri
//                     children: [
//                       Expanded(
//                         flex: 1, // Buat lebar shortcut lebih fleksibel
//                         child: _buildMenuShortcut(
//                           label: 'Request WFA',
//                           targetPage: ClockinwfaPage(),
//                           bgColor: const Color.fromRGBO(101, 19, 116, 1),
//                           imagePath: 'assets/icon/WFA.png',
//                           iconColor: Colors.white,
//                           iconSize: 32,
//                           labelStyle: const TextStyle(
//                             color: Colors.pink,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       const Spacer(), // Tambahkan spacer biar ke kiri
//                     ],
//                   ),
//                   // // Menggunakan ikon bawaan Flutter dengan ukuran yang sama
//                   // _buildMenuShortcut(
//                   //   label: 'Reimbursement',
//                   //   targetPage: const ReimbursementPage(),
//                   //   bgColor: const Color.fromARGB(
//                   //       255, 101, 19, 116), // Warna background
//                   //   iconData: Icons.receipt, // Ikon bawaan Flutter
//                   //   iconColor: Colors.white, // Warna ikon
//                   //   iconSize: 30, // Ukuran ikon
//                   //   labelStyle: const TextStyle(
//                   //     color: Colors.pink, // Warna label menjadi pink
//                   //     fontSize: 14,
//                   //   ),
//                   // ),
//                   // // Menggunakan gambar dari aset dan mengatur ukuran gambar
//                   // _buildMenuShortcut(
//                   //   label: 'History',
//                   //   targetPage: const HistoryScreen(),
//                   //   bgColor: const Color.fromARGB(
//                   //       255, 101, 19, 116), // Warna background
//                   //   imagePath:
//                   //       'assets/icon/history.png', // Path gambar aset
//                   //   iconColor:
//                   //       Colors.white, // Warna yang diterapkan ke gambar
//                   //   iconSize: 26, // Ukuran gambar
//                   //   labelStyle: const TextStyle(
//                   //     color: Colors.pink, // Warna label menjadi pink
//                   //     fontSize: 14,
//                   //   ),
//                   // ),
//                   //   ],
//                   // ),
//                   const SizedBox(height: 20),
//                   //card untuk absen biasa
//                   if (isSuccess)
//                     Card(
//                       color: Colors.orange,
//                       elevation: 5,
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 1, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.symmetric(
//                             vertical: 30.0, horizontal: 16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // Teks Kiri
//                             Flexible(
//                               child: Text(
//                                 '✨Absen Anda \nTelah Berhasil ✨',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                             // Teks Kanan
//                             Flexible(
//                               child: Text(
//                                 'Kerja bagus dan \ntetap semangat',
//                                 textAlign: TextAlign.right,
//                                 style: TextStyle(
//                                     color: Colors.white70, fontSize: 10),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   //card untuk lembur
//                   if (isovertime //&& userStatus != "3"
//                       )
//                     Card(
//                       color: Colors.redAccent,
//                       elevation: 5,
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 1, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.symmetric(
//                             vertical: 30.0, horizontal: 16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // Teks Kiri
//                             Flexible(
//                               child: Text(
//                                 '💥Anda Sedang \nLembur Sekarang💥',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                             // Teks Kanan
//                             Flexible(
//                               child: Text(
//                                 'Kerja bagus dan \ntetap semangat',
//                                 textAlign: TextAlign.right,
//                                 style: TextStyle(
//                                     color: Colors.white70, fontSize: 12),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   //card untuk cuti
//                   if (isholiday)
//                     Card(
//                       color: Colors.green,
//                       elevation: 5,
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 1, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.symmetric(
//                             vertical: 30.0, horizontal: 16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               '🌴Selamat Liburan/ \n Istirahat🌴',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20,
//                               ),
//                             ),
//                             Flexible(
//                               child: Text(
//                                 'Nikmati waktu \nistirahat Anda!',
//                                 textAlign: TextAlign.right,
//                                 style: TextStyle(
//                                     color: Colors.white70, fontSize: 14),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                   // Bagian Announcement
//                   const Text(
//                     'Pengumuman',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(255, 101, 19, 116),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   // // Slider untuk pengumuman
//                   Container(
//                     height: 150,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.grey[300],
//                     ),
//                     child: announcements.isEmpty
//                         ? const Center(
//                             child: Text(
//                               'Hari ini tidak ada pengumuman',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.purple,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           )
//                         : Stack(
//                             alignment: Alignment.bottomCenter,
//                             children: [
//                               PageView.builder(
//                                 controller: _pageController,
//                                 itemCount: announcements.length,
//                                 onPageChanged: (index) {
//                                   setState(() {
//                                     _currentIndex = index;
//                                   });
//                                 },
//                                 itemBuilder: (context, index) {
//                                   final message = announcements[index];
//                                   return GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               AnnouncementDetailPage(
//                                             message: message,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       padding: const EdgeInsets.all(10),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(12),
//                                         color: Colors.white,
//                                       ),
//                                       child: Html(
//                                         data: message,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                   ),
//                   // Container(
//                   //   height: 150,
//                   //   decoration: BoxDecoration(
//                   //     borderRadius: BorderRadius.circular(12),
//                   //     color: Colors.grey[300],
//                   //   ),
//                   //   child: announcements.isEmpty
//                   //       ? const Center(
//                   //           child: Text(
//                   //             'Hari ini tidak ada pengumuman',
//                   //             style: TextStyle(
//                   //               fontSize: 16,
//                   //               fontWeight: FontWeight.bold,
//                   //               color: Colors.purple,
//                   //             ),
//                   //             textAlign: TextAlign.center,
//                   //           ),
//                   //         )
//                   //       : Stack(
//                   //           alignment: Alignment.bottomCenter,
//                   //           children: [
//                   //             PageView.builder(
//                   //               controller: _pageController,
//                   //               itemCount: announcements.length,
//                   //               itemBuilder: (context, index) {
//                   //                 final message = announcements[index];

//                   //                 return GestureDetector(
//                   //                   onTap: () {
//                   //                     Navigator.push(
//                   //                       context,
//                   //                       MaterialPageRoute(
//                   //                         builder: (context) =>
//                   //                             AnnouncementDetailPage(
//                   //                           message: message,
//                   //                         ),
//                   //                       ),
//                   //                     );
//                   //                   },
//                   //                   child: Container(
//                   //                     padding: const EdgeInsets.all(10),
//                   //                     decoration: BoxDecoration(
//                   //                       borderRadius: BorderRadius.circular(12),
//                   //                       color: Colors.white,
//                   //                     ),
//                   //                     child: Center(
//                   //                       child: Text(
//                   //                         message,
//                   //                         style: const TextStyle(
//                   //                           fontSize: 16,
//                   //                           fontWeight: FontWeight.bold,
//                   //                           color: Color.fromARGB(
//                   //                               255, 101, 19, 116),
//                   //                         ),
//                   //                         textAlign: TextAlign.center,
//                   //                       ),
//                   //                     ),
//                   //                   ),
//                   //                 );
//                   //               },
//                   //               onPageChanged: (int index) {
//                   //                 setState(() {
//                   //                   _currentPage = index;
//                   //                 });
//                   //               },
//                   //             ),
//                   //             // Tambahkan indikator
//                   //             Positioned(
//                   //               bottom: 10,
//                   //               left: 0,
//                   //               right: 0,
//                   //               child: Center(
//                   //                 child: SmoothPageIndicator(
//                   //                   controller: _pageController,
//                   //                   count: announcements.length,
//                   //                   effect: const ExpandingDotsEffect(
//                   //                     activeDotColor:
//                   //                         Color.fromARGB(255, 101, 19, 116),
//                   //                     dotColor: Colors.grey,
//                   //                     dotHeight: 8,
//                   //                     dotWidth: 8,
//                   //                   ),
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //           ],
//                   //         ),
//                   // ),
//                   // ini fungsi kalo tidak ada pengumuman maka kosong
//                   // Container(
//                   //   height: 150,
//                   //   decoration: BoxDecoration(
//                   //     borderRadius: BorderRadius.circular(12),
//                   //     color: Colors.grey[300],
//                   //   ),
//                   //   child: Stack(
//                   //     alignment: Alignment.bottomCenter,
//                   //     children: [
//                   //       PageView.builder(
//                   //         controller: _pageController,
//                   //         itemCount: announcements.length,
//                   //         itemBuilder: (context, index) {
//                   //           final message = announcements[index];

//                   //           return GestureDetector(
//                   //             onTap: () {
//                   //               Navigator.push(
//                   //                 context,
//                   //                 MaterialPageRoute(
//                   //                   builder: (context) =>
//                   //                       AnnouncementDetailPage(
//                   //                     message: message,
//                   //                   ),
//                   //                 ),
//                   //               );
//                   //             },
//                   //             child: Container(
//                   //               padding: const EdgeInsets.all(10),
//                   //               decoration: BoxDecoration(
//                   //                 borderRadius: BorderRadius.circular(12),
//                   //                 color: Colors.white,
//                   //               ),
//                   //               child: Center(
//                   //                 child: Text(
//                   //                   message,
//                   //                   style: const TextStyle(
//                   //                     fontSize: 16,
//                   //                     fontWeight: FontWeight.bold,
//                   //                   ),
//                   //                   textAlign: TextAlign.center,
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //           );
//                   //         },
//                   //         onPageChanged: (int index) {
//                   //           setState(() {
//                   //             _currentPage = index;
//                   //           });
//                   //         },
//                   //       ),
//                   //       // Tambahkan indikator
//                   //       Positioned(
//                   //         bottom: 10,
//                   //         left: 0,
//                   //         right: 0,
//                   //         child: Center(
//                   //           child: SmoothPageIndicator(
//                   //             controller: _pageController,
//                   //             count: announcements.length,
//                   //             effect: ExpandingDotsEffect(
//                   //               activeDotColor:
//                   //                   const Color.fromARGB(255, 101, 19, 116),
//                   //               dotColor: Colors.grey,
//                   //               dotHeight: 8,
//                   //               dotWidth: 8,
//                   //             ),
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     ],
//                   //   ),
//                   // ),

// //ini fungsi jika mau annoouncement nya menghilang
//                   //    if (announcements.isNotEmpty) ...[
//                   //   const Text(
//                   //     'Announcement',
//                   //     style: TextStyle(
//                   //       fontSize: 18,
//                   //       fontWeight: FontWeight.bold,
//                   //       color: Colors.purple,
//                   //     ),
//                   //   ),
//                   //   const SizedBox(height: 10),
//                   //   // Slider untuk pengumuman
//                   //   Container(
//                   //     height: 150,
//                   //     decoration: BoxDecoration(
//                   //       borderRadius: BorderRadius.circular(12),
//                   //       color: Colors.grey[300],
//                   //     ),
//                   //     child: Stack(
//                   //       alignment: Alignment.bottomCenter,
//                   //       children: [
//                   //         PageView.builder(
//                   //           controller: _pageController,
//                   //           itemCount: announcements.length,
//                   //           itemBuilder: (context, index) {
//                   //             final message = announcements[index];

//                   //             return GestureDetector(
//                   //               onTap: () {
//                   //                 Navigator.push(
//                   //                   context,
//                   //                   MaterialPageRoute(
//                   //                     builder: (context) =>
//                   //                         AnnouncementDetailPage(
//                   //                       message: message,
//                   //                     ),
//                   //                   ),
//                   //                 );
//                   //               },
//                   //               child: Container(
//                   //                 padding: const EdgeInsets.all(10),
//                   //                 decoration: BoxDecoration(
//                   //                   borderRadius: BorderRadius.circular(12),
//                   //                   color: Colors.white,
//                   //                 ),
//                   //                 child: Center(
//                   //                   child: Text(
//                   //                     message,
//                   //                     style: const TextStyle(
//                   //                       fontSize: 16,
//                   //                       fontWeight: FontWeight.bold,
//                   //                       color: Colors.purple,
//                   //                     ),
//                   //                     textAlign: TextAlign.center,
//                   //                   ),
//                   //                 ),
//                   //               ),
//                   //             );
//                   //           },
//                   //           onPageChanged: (int index) {
//                   //             setState(() {
//                   //               _currentPage = index;
//                   //             });
//                   //           },
//                   //         ),
//                   //         // Tambahkan indikator
//                   //         Positioned(
//                   //           bottom: 10,
//                   //           left: 0,
//                   //           right: 0,
//                   //           child: Center(
//                   //             child: SmoothPageIndicator(
//                   //               controller: _pageController,
//                   //               count: announcements.length,
//                   //               effect: ExpandingDotsEffect(
//                   //                 activeDotColor: Colors.purple,
//                   //                 dotColor: Colors.white,
//                   //                 dotHeight: 8,
//                   //                 dotWidth: 8,
//                   //               ),
//                   //             ),
//                   //           ),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ],
//                   const SizedBox(height: 20),
//                   // Note Section
//                   Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 1, vertical: 12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (showNote) ...[
//                           const Text(
//                             'Note',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Color.fromARGB(255, 101, 19, 116),
//                             ),
//                           ),
//                           const SizedBox(height: 5),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 30, vertical: 18),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 2,
//                                   blurRadius: 5,
//                                   offset: const Offset(0, 3), // posisi bayangan
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'Jangan Lupa Absen Hari Ini👏',
//                                   style: TextStyle(fontSize: 11),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               const ClockInPage()),
//                                     ); // Aksi ketika tombol ditekan
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor:
//                                         Colors.orange, // Warna tombol
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           8), // Melengkungkan pinggiran tombol
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 10, vertical: 8),
//                                   ),
//                                   child: const Text(
//                                     'Submit',
//                                     style: TextStyle(
//                                         fontSize: 10, color: Colors.white),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       // Bottom Navigation
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.orange,
//         unselectedItemColor: Colors.white,
//         backgroundColor: const Color.fromARGB(255, 101, 19, 116),
//         selectedLabelStyle: const TextStyle(fontSize: 11),
//         unselectedLabelStyle: const TextStyle(fontSize: 9),
//         currentIndex: 0,
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               // Navigator.pushAndRemoveUntil(
//               //   context,
//               //   MaterialPageRoute(builder: (context) => const HomePage()),
//               //   (route) => false, // Menghapus semua halaman sebelumnya
//               // );
//               break;
//             case 1:
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => const TimeOffScreen()),
//                 (route) => false,
//               );
//               break;
//             case 2:
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const ReimbursementPage()),
//                 (route) => false,
//               );
//               break;
//             case 3:
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const NotificationPage()),
//                 (route) => false,
//               );
//               break;
//             case 4:
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ProfileScreen()),
//                 (route) => false,
//               );
//               break;
//           }
//         },
//         items: [
//           const BottomNavigationBarItem(
//             icon: ImageIcon(
//               AssetImage('assets/icon/home.png'), // Custom icon
//               size: 20,
//               color: Colors.orange,
//             ),
//             label: 'Home',
//           ),
//           const BottomNavigationBarItem(
//             icon: ImageIcon(
//               AssetImage('assets/icon/timeoff.png'), // Custom icon
//               size: 20,
//               color: Colors.white,
//             ),
//             label: 'Time Off',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.receipt, size: 25),
//             label: 'Reimbursement',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const ImageIcon(
//                   AssetImage('assets/icon/notifikasi.png'),
//                   size: 20,
//                   color: Colors.white,
//                 ),
//                 FutureBuilder<bool>(
//                   future: NotificationHelper.hasUnreadNotifications(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData && snapshot.data == true) {
//                       return const Positioned(
//                         right: 0,
//                         top: 0,
//                         child: Icon(
//                           Icons.circle,
//                           color: Colors.red,
//                           size: 10,
//                         ),
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ],
//             ),
//             label: 'Notification',
//           ),
//           const BottomNavigationBarItem(
//             icon: ImageIcon(
//               AssetImage('assets/icon/profil.png'), // Custom icon
//               size: 20,
//               color: Colors.white,
//             ),
//             label: 'Profil',
//           ),
//         ],
//       ),
//     );
//   }
// }

// // tampilan dalam announcement
// // class AnnouncementDetailPage extends StatelessWidget {
// //   final String message;

// //   const AnnouncementDetailPage({
// //     super.key,
// //     required this.message,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Detail Announcement'),
// //         backgroundColor: Colors.purple,
// //       ),
// //       body: SingleChildScrollView(
// //         physics:
// //             const BouncingScrollPhysics(), // Memberikan efek scroll yang halus        padding: const EdgeInsets.all(16.0),
// //         child: Text(
// //           message,
// //           style: const TextStyle(fontSize: 16, color: Colors.black87),
// //         ),
// //       ),
// //     );
// //   }
// // }
// class AnnouncementDetailPage extends StatelessWidget {
//   final String message;

//   const AnnouncementDetailPage({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detail Announcement'),
//         backgroundColor: Colors.purple,
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(16.0),
//         child: Html(
//           data: message,
//         ),
//       ),
//     );
//   }
// }
// html