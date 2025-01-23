// import 'package:flutter/material.dart';
// import 'package:absen/Reimbursement/Reimbursementscreen.dart';
// import 'package:absen/homepage/home.dart';
// import 'package:absen/timeoff/TimeoffScreen.dart';
// import 'package:absen/profil/profilscreen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:dio/dio.dart';
// import 'dart:convert';
// import 'dart:io';

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({super.key});

//   @override
//   _NotificationPageState createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   List<dynamic> notifications = [];
//   bool isLoading = true;
//   bool hasUnreadNotifications = false;

//   @override
//   void initState() {
//     super.initState();
//     getNotif();
//   }

//   Future<void> getNotif() async {
//     final url = Uri.parse(
//         'https://dev-portal.eksam.cloud/api/v1/other/get-self-notification');
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
//             'id': notif['id'],
//             'title': notif['title']?.toString(),
//             'description': notif['description']?.toString(),
//             'fileUrl': notif['file'] != null
//                 ? "https://dev-portal.eksam.cloud/storage/file/${notif['file']}"
//                 : null,
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
//           hasUnreadNotifications =
//               notifications.any((notif) => !notif['isRead']);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
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
//         'https://dev-portal.eksam.cloud/api/v1/other/read-notification/$id');
//     var request = http.MultipartRequest('PUT', url);
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';

//     try {
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         // Tandai notifikasi sebagai "sudah dibaca" di SharedPreferences
//         await _markNotificationAsRead(id);

//         setState(() {
//           notifications = notifications.map((notif) {
//             if (notif['id'] == id) {
//               notif['isRead'] = true;
//             }
//             return notif;
//           }).toList();
//           hasUnreadNotifications =
//               notifications.any((notif) => !notif['isRead']);
//         });
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.orange,
//         title: Text('Notification', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.orange, Colors.pink, Colors.purple],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: isLoading
//             ? Center(child: CircularProgressIndicator())
//             : notifications.isEmpty
//                 ? Center(child: Text('Tidak ada notifikasi hari ini'))
//                 : ListView.builder(
//                     padding: EdgeInsets.all(16.0),
//                     itemCount: notifications.length,
//                     itemBuilder: (context, index) {
//                       var notif = notifications[index];
//                       return NotificationItem(
//                         title: notif['title'] ?? '',
//                         description: notif['description'] ?? '',
//                         fileUrl: notif['fileUrl'],
//                         isRead: notif['isRead'],
//                         onTap: () async {
//                           await putRead(notif['id']);
//                         },
//                       );
//                     },
//                   ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         items: [
//           BottomNavigationBarItem(
//             icon: ImageIcon(
//               AssetImage('assets/icon/home.png'),
//               size: 18,
//               color: Colors.white,
//             ),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: ImageIcon(
//               AssetImage('assets/icon/timeoff.png'),
//               size: 20,
//               color: Colors.white,
//             ),
//             label: 'Time Off',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.receipt, size: 27),
//             label: 'Reimbursement',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 ImageIcon(
//                   AssetImage('assets/icon/notifikasi.png'),
//                   size: 22,
//                   color: Colors.orange,
//                 ),
//                 if (hasUnreadNotifications)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Icon(
//                       Icons.circle,
//                       color: Colors.red,
//                       size: 10,
//                     ),
//                   ),
//               ],
//             ),
//             label: 'Notification',
//           ),
//           BottomNavigationBarItem(
//             icon: ImageIcon(
//               AssetImage('assets/icon/profil.png'),
//               size: 20,
//               color: Colors.white,
//             ),
//             label: 'Profil',
//           ),
//         ],
//         selectedItemColor: Colors.orange,
//         unselectedItemColor: Colors.white,
//         backgroundColor: const Color.fromARGB(255, 101, 19, 116),
//         selectedLabelStyle: const TextStyle(fontSize: 11),
//         unselectedLabelStyle: const TextStyle(fontSize: 9),
//         currentIndex: 3,
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => const HomePage()),
//               );
//               break;
//             case 1:
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => TimeOffScreen()),
//               );
//               break;
//             case 2:
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ReimbursementPage()),
//               );
//               break;
//             case 3:
//               break;
//             case 4:
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ProfileScreen()),
//               );
//               break;
//           }
//         },
//       ),
//     );
//   }
// }

// class NotificationItem extends StatelessWidget {
//   final String title;
//   final String description;
//   final String? fileUrl;
//   final bool isRead;
//   final VoidCallback onTap;

//   const NotificationItem({
//     required this.title,
//     required this.description,
//     this.fileUrl,
//     required this.isRead,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8.0),
//       color: isRead ? Colors.grey[200] : Colors.white,
//       child: ListTile(
//         title: Text(
//           title,
//           style: TextStyle(
//               fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
//         ),
//         subtitle: Text(
//           'Click To View',
//           style: TextStyle(color: Colors.blue),
//         ),
//         trailing:
//             isRead ? null : Icon(Icons.circle, color: Colors.red, size: 10),
//         onTap: () {
//           onTap();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PayslipDetailPage(
//                 title: title,
//                 description: description,
//                 fileUrl: fileUrl,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class PayslipDetailPage extends StatelessWidget {
//   final String title;
//   final String description;
//   final String? fileUrl;

//   const PayslipDetailPage({
//     required this.title,
//     required this.description,
//     this.fileUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notification"),
//         backgroundColor: Colors.orange,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.circle, color: Colors.red, size: 12),
//                 SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Text(
//               description,
//               style: TextStyle(color: Colors.black54, fontSize: 14),
//             ),
//             SizedBox(height: 16),
//             if (fileUrl != null)
//               InkWell(
//                 onTap: () {
//                   _downloadFile(context, fileUrl!);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "View/Download File",
//                         style: TextStyle(color: Colors.orange),
//                       ),
//                       Icon(Icons.download, color: Colors.orange),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               Text(
//                 "No file available.",
//                 style:
//                     TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
//               ),
//             SizedBox(
//                 height: 32), // Spacer tambahan untuk melihat skrol lebih baik
//           ],
//         ),
//       ),
//     );
//   }

//   Future<bool> _requestStoragePermission() async {
//     if (await Permission.storage.request().isGranted) {
//       return true;
//     } else if (await Permission.manageExternalStorage.request().isGranted) {
//       return true;
//     }
//     return false;
//   }

//   Future<void> _downloadFile(BuildContext context, String url) async {
//     bool permissionGranted = await _requestStoragePermission();

//     if (!permissionGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Storage permission denied")),
//       );
//       return;
//     }

//     try {
//       final directory = Directory('/storage/emulated/0/Download');
//       if (!await directory.exists()) {
//         await directory.create(recursive: true);
//       }

//       final fileName = url.split('/').last;
//       final savePath = '${directory.path}/$fileName';

//       Dio dio = Dio();
//       await dio.download(url, savePath, onReceiveProgress: (received, total) {
//         if (total != -1) {
//           print(
//               'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
//         }
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("File downloaded to $savePath")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error downloading file")),
//       );
//     }
//   }
// }
