// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'clockin_page.dart'; // pastikan ini mengarah ke file ClockInPage kamu

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   bool showNote = true;

//   int hariBulanIni = 0;
//   int menitBulanIni = 0;
//   int telatBulanIni = 0;
//   int cutiBulanIni = 0;

//   int hariBulanLalu = 0;
//   int menitBulanLalu = 0;
//   int telatBulanLalu = 0;
//   int cutiBulanLalu = 0;

//   @override
//   void initState() {
//     super.initState();
//     getuserinfo();
//   }

//   Future<void> getuserinfo() async {
//     try {
//       final url = Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-user-info');
//       var request = http.MultipartRequest('GET', url);
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       request.headers['Authorization'] = 'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (rp.statusCode == 200) {
//         final bulanIni = data['data_bulan_ini'];
//         final bulanLalu = data['data'];

//         setState(() {
//           hariBulanIni = bulanIni['hari'];
//           menitBulanIni = bulanIni['menit'];
//           telatBulanIni = bulanIni['menit_telat'];
//           cutiBulanIni = 0;

//           hariBulanLalu = bulanLalu['hari'];
//           menitBulanLalu = bulanLalu['menit'];
//           telatBulanLalu = bulanLalu['menit_telat'];
//           cutiBulanLalu = 0;
//         });
//       } else {
//         print('Error fetching user info: ${rp.statusCode}');
//         print(rp.body);
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
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
//                   // REKAP DATA
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       children: [
//                         buildRekapBox("Rekapitulasi Kehadiran Bulan Berjalan", hariBulanIni, menitBulanIni, telatBulanIni, cutiBulanIni),
//                         const SizedBox(height: 16),
//                         buildRekapBox("Rekapitulasi Kehadiran Bulan Lalu", hariBulanLalu, menitBulanLalu, telatBulanLalu, cutiBulanLalu),
//                       ],
//                     ),
//                   ),
//                   // NOTE SECTION
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 12),
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
//                             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 2,
//                                   blurRadius: 5,
//                                   offset: const Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'Jangan Lupa Absen Hari Ini!',
//                                   style: TextStyle(fontSize: 11),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(builder: (context) => const ClockInPage()),
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.orange,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                                   ),
//                                   child: const Text(
//                                     'Submit',
//                                     style: TextStyle(fontSize: 10, color: Colors.white),
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
//     );
//   }

//   Widget buildRekapBox(String title, int hari, int menit, int telat, int cuti) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               buildStatItem("$hari", "Masuk", Colors.blue, "Hari"),
//               buildStatItem("$menit", "Durasi Kerja", Colors.green, "Menit"),
//               buildStatItem("$telat", "Durasi Terlambat", Colors.red, "Menit"),
//               buildStatItem("$cuti", "Cuti", Colors.orange, "Hari"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildStatItem(String value, String label, Color color, String unit) {
//     return Column(
//       children: [
//         Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
//         const SizedBox(height: 4),
//         Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
//         Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
//       ],
//     );
//   }
// }