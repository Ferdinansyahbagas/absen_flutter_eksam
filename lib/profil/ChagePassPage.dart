import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:absen/homepage/notif.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:absen/profil/profilscreen.dart';

class Chagepasspage extends StatefulWidget {
  @override
  _ChagepasspageState createState() => _ChagepasspageState();
}

class _ChagepasspageState extends State<Chagepasspage> {
  File? profileImage;
  String name = 'Maegareta wokahholic';
  String email = 'maegaretawokahholic@gmail.com';
  String password = '12345678';
  String? selectedAvatarUrl; // Variabel untuk menyimpan URL avatar default
  bool _obscureText = true; // Kontrol visibilitas password di dialog edit
  bool _isPasswordHidden =
      true; // Kontrol visibilitas password di tampilan profil
  List<String> defaultAvatars = [
    'https://via.placeholder.com/150/FF0000/FFFFFF?text=Avatar+1',
    'https://via.placeholder.com/150/00FF00/FFFFFF?text=Avatar+2',
    'https://via.placeholder.com/150/0000FF/FFFFFF?text=Avatar+3'
  ];

  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk menampilkan dialog edit
  void _showEditDialog(
      String title, String currentValue, Function(String) onSave,
      {bool isPasswordField = false}) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: TextField(
                controller: controller,
                obscureText: isPasswordField ? _obscureText : false,
                decoration: InputDecoration(
                  labelText: 'Enter new $title',
                  suffixIcon: isPasswordField
                      ? IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                      : null,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSave(controller.text);
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImage(String imageType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        switch (imageType) {
          case 'profile':
            profileImage = File(pickedFile.path);
        }
      });
    }
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
        selectedAvatarUrl = null; // Hapus avatar URL jika ada foto baru
      });
    }
  }

  // Fungsi untuk mengganti avatar dengan pilihan default
  void _selectDefaultAvatar(String imageUrl) {
    setState(() {
      profileImage = null; // Reset file image
      selectedAvatarUrl = imageUrl;
    });
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Select from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Select Default Avatar'),
              onTap: () {
                Navigator.pop(context);
                _showDefaultAvatarsDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDefaultAvatarsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Default Avatar'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              children: defaultAvatars.map((imageUrl) {
                return GestureDetector(
                  onTap: () {
                    _selectDefaultAvatar(imageUrl);
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 30,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : (selectedAvatarUrl != null
                                  ? NetworkImage(selectedAvatarUrl!)
                                  : NetworkImage(defaultAvatars[0])),
                          backgroundColor: Colors.grey[200],
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt,
                                color: Colors.orange, size: 30),
                            onPressed: _showAvatarOptions,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Hello!',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Icon(Icons.edit, color: Colors.orange),
                    ],
                  ),
                  Text(
                    'maegaretawokaholic@gmail.com',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Icon(Icons.visibility_off, color: Colors.orange),
                    ],
                  ),
                  Text(
                    '*********',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ChangePasswordDialog();
                        },
                      );
                    },
                    child: Text(
                      'Change Your Password',
                      style: TextStyle(
                        color: Colors.orange,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'), // Custom icon
              size: 18,
              color: Colors.white,
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
            icon: Icon(Icons.receipt, size: 27),
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
}

class ChangePasswordDialog extends StatefulWidget {
  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Old Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isOldPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isOldPasswordVisible = !_isOldPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isOldPasswordVisible,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isNewPasswordVisible,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logika untuk submit password baru
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
