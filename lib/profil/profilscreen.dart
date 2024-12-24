import 'package:absen/homepage/notif.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/screen/loginscreen.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:absen/profil/ChagePassPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absen/utils/preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? profileImage;
  PageController _pageController = PageController();
  int _currentIndex = 0; // Untuk mengatur indeks dari BottomNavigationBar
  String profileImageUrl = 'https://via.placeholder.com/150';
  String idCardImageUrl = 'https://via.placeholder.com/100';
  String cvImageUrl = '';
  String name = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String idCardAddress = '';
  File? _idCardImage;
  File? _cvImage;
  String employmentStart = '';
  String employmentEnd = '';
  String education = '';
  String bankAccount = '';
  String bank = '';
  String Limit = '';
  String? selectedAvatarUrl; // Variabel untuk menyimpan URL avatar default
  bool _obscureText = true; // Kontrol visibilitas password di dialog edit
  final ImagePicker _picker = ImagePicker();
  List<String> defaultAvatars = [
    'https://via.placeholder.com/150/FF0000/FFFFFF?text=Avatar+1',
    'https://via.placeholder.com/150/00FF00/FFFFFF?text=Avatar+2',
    'https://via.placeholder.com/150/0000FF/FFFFFF?text=Avatar+3'
  ];

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  void _logout(BuildContext context) async {
    // Hapus token dari SharedPreferences
    await Preferences.clearToken();

    // Navigasi kembali ke WelcomeScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> setProfile() async {
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/karyawan/set-profile');

      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());
      print(data);

      setState(() {
        request.fields['no_hp'] = phoneNumber;
        request.fields['alamat_domisili'] = address;
        request.fields['alamat_ktp'] = idCardAddress;
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
      ;
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getProfile() async {
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/karyawan/get-profile');

      var request = http.MultipartRequest('GET', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());
      print(data);

      if (response.statusCode == 200) {
        setState(() {
          name = data['data']['name'].toString();
          email = data['data']['email'].toString();
          phoneNumber = data['data']['no_hp'].toString();
          address = data['data']['alamat_domisili'].toString();
          idCardAddress = data['data']['alamat_ktp'].toString();
          employmentStart = data['data']['kontrak_mulai'].toString();
          employmentEnd = data['data']['kontrak_selesai'].toString();
          education = data['data']['pendidikan']['pendidikan'].toString();
          bank = data['data']['bank']['name'].toString();
          bankAccount = data['data']['no_rekening'].toString();
          Limit = data['data']['batas_cuti'].toString();
        });
        localStorage.setString('id', data['data']['id']);
      } else {
        print("Error retrieving profile");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

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
                  onPressed: setProfile,
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
  Future<void> _pickImage(ImageSource source, String imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        switch (imageType) {
          case 'profile':
            profileImage = File(pickedFile.path);
        }
        if (imageType == 'ID Card') {
          _idCardImage = File(pickedFile.path);
        } else if (imageType == 'CV') {
          _cvImage = File(pickedFile.path);
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
      });
    }
  }

  // Fungsi untuk mengganti avatar dengan pilihan default
  void _selectDefaultAvatar(String imageUrl) {
    setState(() {
      profileImage = null; // Reset file image
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
          ],
        );
      },
    );
  }

  final TextStyle titleStyle = TextStyle(fontSize: 14, color: Colors.black54);
  final TextStyle valueStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex =
                index; // Sinkronisasi indeks ketika halaman berganti
          });
        },
        children: [
          // Halaman Profile
          SingleChildScrollView(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        title: 'Email',
                        value: email,
                        isEditable: false, // Tidak bisa diedit
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Edit Password',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        10), // Menambah jarak tetap antara teks dan ikon
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios,
                                      color: Colors.orange),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Chagepasspage(), // Pindah ke halaman EditPasswordPage
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildProfileItem(
                        title: 'Phone Number',
                        value: phoneNumber,
                        onEdit: (newValue) =>
                            setState(() => phoneNumber = newValue),
                      ),
                      _buildProfileItem(
                        title: 'Address',
                        value: address,
                        onEdit: (newValue) =>
                            setState(() => address = newValue),
                      ),
                      const Divider(
                        height: 30,
                        thickness: 1,
                        color: const Color.fromRGBO(101, 19, 116, 1),
                      ),
                      _buildProfileItem(
                        title: 'ID Card Address',
                        value: idCardAddress,
                        onEdit: (newValue) =>
                            setState(() => idCardAddress = newValue),
                      ),
                      SizedBox(height: 14),
                      _buildImageCard(
                          "ID Card Picture", _idCardImage, 'ID Card'),
                      const Divider(
                        height: 30,
                        thickness: 1,
                        color: const Color.fromRGBO(101, 19, 116, 1),
                      ),
                      _buildImageCard("CV", _cvImage, 'CV'),
                      SizedBox(height: 14),
                      _buildProfileItem(
                        title: 'Employment Contract Start',
                        value: employmentStart,
                        isEditable: false, // Tidak bisa diedit
                      ),
                      _buildProfileItem(
                        title: 'Employment Contract End',
                        value: employmentEnd,
                        isEditable: false, // Tidak bisa diedit
                      ),
                      SizedBox(height: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Education',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Spasi antara title dan dropdown
                          DropdownButtonFormField<String>(
                            value: education,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: const Color.fromRGBO(101, 19, 116, 1),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: const Color.fromRGBO(101, 19, 116, 1),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: [education].map((String education) {
                              return DropdownMenuItem<String>(
                                value: education,
                                child: Text(education),
                              );
                            }).toList(),
                            onChanged: null, // Disabled
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bank',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Spasi antara title dan dropdown
                          DropdownButtonFormField<String>(
                            value: bank,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: const Color.fromRGBO(101, 19, 116, 1),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: const Color.fromRGBO(101, 19, 116, 1),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: [bank].map((String education) {
                              return DropdownMenuItem<String>(
                                value: bank,
                                child: Text(bank),
                              );
                            }).toList(),
                            onChanged: null, // Disabled
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bank Account Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Jarak antara judul dan TextField
                          TextField(
                            controller: TextEditingController(
                                text: bankAccount), // Isi TextField
                            readOnly: true, // Disabled agar tidak bisa di-edit
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color:
                                        const Color.fromRGBO(101, 19, 116, 1)),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      _buildProfileItem(
                        title: 'Leave Limit',
                        value: Limit,
                        isEditable: false, // Tidak bisa diedit
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimeOffScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReimbursementPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
              break;
            case 4:
              // Navigator.pop(
              //   context,
              //   MaterialPageRoute(builder: (context) => ProfileScreen()),
              // );
              break;
          }
        },
      ),
    );
  }

  Widget _buildProfileItem({
    required String title,
    required String value,
    Function(String)?
        onEdit, // Fungsi hanya diperlukan untuk item yang bisa diedit
    bool isEditable = true, // Default: bisa diedit
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (isEditable) // Tampilkan tombol edit hanya jika isEditable true
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: () {
                if (onEdit != null) {
                  _showEditDialog(title, value, onEdit);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String title, File? imageFile, String imageType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery, imageType),
          child: Container(
            height: 150,
            width: 150,
            color: Colors.grey[300],
            child: imageFile != null
                ? Image.file(imageFile, fit: BoxFit.cover)
                : Center(
                    child:
                        Icon(Icons.add_a_photo, size: 20, color: Colors.grey),
                  ),
          ),
        ),
      ],
    );
  }
}
