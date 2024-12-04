import 'package:absen/homepage/notif.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:absen/profil/ChagePassPage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? profileImage;
  File? idCardImage;
  File? cvImage;
  PageController _pageController = PageController();
  int _currentIndex = 0; // Untuk mengatur indeks dari BottomNavigationBar
  String profileImageUrl = 'https://via.placeholder.com/150';
  String idCardImageUrl = 'https://via.placeholder.com/100';
  String cvImageUrl = '';
  String name = '';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String address = '';
  String idCardAddress = '';
  String employmentStart = '';
  String employmentEnd = '';
  String education = '';
  String bankAccount = '';
  String bank = '';
  String leaveLimit = '';
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
            break;
          case 'idCard':
            idCardImage = File(pickedFile.path);
            break;
          case 'cv':
            cvImage = File(pickedFile.path);
            break;
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        title: 'Email',
                        value: email,
                        onEdit: (newValue) => setState(() => email = newValue),
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
                                    '*********',
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
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'Phone Number',
                        value: phoneNumber,
                        onEdit: (newValue) =>
                            setState(() => phoneNumber = newValue),
                      ),
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'Address',
                        value: address,
                        onEdit: (newValue) =>
                            setState(() => address = newValue),
                      ),
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'ID Card Address',
                        value: idCardAddress,
                        onEdit: (newValue) =>
                            setState(() => idCardAddress = newValue),
                      ),
                      _buildDivider(),
                      _buildImageUploadSection(
                        label: 'ID Card Picture',
                        imageFile: idCardImage,
                        onTap: () => _pickImage('idCard'),
                      ),
                      SizedBox(height: 20),
                      _buildImageUploadSection(
                        label: 'CV',
                        imageFile: cvImage,
                        onTap: () => _pickImage('cv'),
                      ),
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'Employment Contract Start',
                        value: employmentStart,
                        onEdit: (newValue) =>
                            setState(() => employmentStart = newValue),
                      ),
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'Employment Contract End',
                        value: employmentEnd,
                        onEdit: (newValue) =>
                            setState(() => employmentEnd = newValue),
                      ),
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'Education',
                        value: education,
                        onEdit: (newValue) =>
                            setState(() => education = newValue),
                      ),
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'Bank Account Number',
                        value: bankAccount,
                        onEdit: (newValue) =>
                            setState(() => bankAccount = newValue),
                      ),
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'Bank',
                        value: bank,
                        onEdit: (newValue) => setState(() => bank = newValue),
                      ),
                      _buildDivider(),
                      _buildProfileItem(
                        title: 'Leave Limit',
                        value: leaveLimit,
                        onEdit: (newValue) =>
                            setState(() => leaveLimit = newValue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Halaman lainnya
          TimeOffScreen(),
          ReimbursementPage(),
          NotificationPage(),
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

  Widget buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(value),
              ],
            ),
          ),
          Icon(Icons.edit, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
      {required String title,
      required String value,
      required Function(String) onEdit,
      bool isPasswordField = false,
      bool isPasswordHidden = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (isPasswordField) ...[
            IconButton(
              icon: Icon(
                isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                color: Colors.orange,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordHidden = !_isPasswordHidden;
                });
              },
            ),
          ],
          IconButton(
            icon: Icon(Icons.edit, color: Colors.orange),
            onPressed: () => _showEditDialog(title, value, onEdit,
                isPasswordField: isPasswordField),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      thickness: 1,
      height: 30,
    );
  }

  Widget _buildImageUploadSection(
      {required String label,
      required File? imageFile,
      required Function onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => onTap(),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5, // Lebar dipersempit
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.purple,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  'Upload Your Photo',
                  style: TextStyle(color: Colors.purple, fontSize: 16),
                ),
                if (imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
