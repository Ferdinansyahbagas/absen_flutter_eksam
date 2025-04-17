import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/profil/profilscreen.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:absen/utils/notification_helper.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = true;
  bool hasUnreadNotifications = false;
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    getNotif();
  }

  Future<void> getNotif() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/other/get-self-notification');
    var request = http.MultipartRequest('GET', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (rp.statusCode == 200 && data['data'] != null) {
        List<Map<String, dynamic>> loadedNotifications =
            List.from(data['data']).map((notif) {
          return {
            'id': notif['id'],
            'title': notif['title']?.toString(),
            'description': notif['description']?.toString(),
            'fileUrl': notif['file'] != null
                ? "https://portal.eksam.cloud/storage/file/${notif['file']}"
                : null,
            'createdAt': notif['created_at'] ?? '',
            'isRead': notif['is_read'] == 1,
          };
        }).toList();

        setState(() {
          notifications = loadedNotifications;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTimeAgo(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  // Future<bool> _isNotificationRead(int id) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool('notif_read_$id') ?? false;
  // }

  Future<void> _markNotificationAsRead(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_read_$id', true);
  }

  Future<void> putRead(int id) async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/other/read-notification/$id');
    var request = http.MultipartRequest('PUT', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Tandai sebagai dibaca
        await _markNotificationAsRead(id);

        // Update status unread
        bool hasUnread = notifications.any((notif) => !notif['isRead']);
        await NotificationHelper.setUnreadNotifications(hasUnread);

        setState(() {
          notifications = notifications.map((notif) {
            if (notif['id'] == id) {
              notif['isRead'] = true;
            }
            return notif;
          }).toList();
        });
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title:
            const Text('Notification', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ); // Handle back button press
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.pink, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? const Center(child: Text('Tidak ada notifikasi hari ini'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var notif = notifications[index];
                      return NotificationItem(
                        title: notif['title'] ?? '',
                        description: notif['description'] ?? '',
                        fileUrl: notif['fileUrl'],
                        isRead: notif['isRead'],
                        createdAt: notif['createdAt'] ?? '',
                        onTap: () async {
                          await putRead(notif['id']);
                        },
                      );
                    },
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'),
              size: 18,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/timeoff.png'),
              size: 20,
              color: Colors.white,
            ),
            label: 'Time Off',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt, size: 27),
            label: 'Reimbursement',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const ImageIcon(
                  AssetImage('assets/icon/notifikasi.png'),
                  size: 22,
                  color: Colors.orange,
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false, // Menghapus semua halaman sebelumnya
              );
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
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String? fileUrl;
  final bool isRead;
  final String createdAt;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.title,
    required this.description,
    this.fileUrl,
    required this.isRead,
    required this.createdAt,
    required this.onTap,
  });

  String formatTimeAgo(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: isRead ? Colors.grey[200] : Colors.white,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Click To View',
              style: TextStyle(color: Colors.blue),
            ),
            Text(
              formatTimeAgo(createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : const Icon(Icons.circle, color: Colors.red, size: 10),
        onTap: () {
          onTap();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PayslipDetailPage(
                title: title,
                description: description,
                fileUrl: fileUrl,
                createdAt: createdAt,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PayslipDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String? fileUrl;
  final String createdAt;

  const PayslipDetailPage({
    super.key,
    required this.title,
    required this.description,
    this.fileUrl,
    required this.createdAt,
  });

  String formatFullDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    return DateFormat('EEEE, dd MMMM yyyy - HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Detail"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.red, size: 12),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatFullDate(createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (fileUrl != null)
              InkWell(
                onTap: () {
                  _downloadFile(context, fileUrl!);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "View/Download File",
                        style: TextStyle(color: Colors.orange),
                      ),
                      Icon(Icons.download, color: Colors.orange),
                    ],
                  ),
                ),
              )
            else
              const Text(
                "No file available.",
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

   Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    bool permissionGranted = await _requestStoragePermission();

    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
      return;
    }

    try {
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = url.split('/').last;
      final savePath = '${directory.path}/$fileName';

      Dio dio = Dio();
      await dio.download(url, savePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          print(
              'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File downloaded to $savePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error downloading file")),
      );
    }
  }
}