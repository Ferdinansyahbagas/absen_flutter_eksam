import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:absen/profil/ChagePassPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? profileImage;
  File? idCardImage;
  File? cvImage;
  String name = 'Maegareta wokahholic';
  String email = 'maegaretawokahholic@gmail.com';
  String password = '12345678';
  String phoneNumber = '0812-3456-7890';
  String address = 'Jl. Ampera Selatan No.1, Blora, Central Jakarta';
  String idCardAddress = 'Jl. Semangka Timur No.5, Sleman, Yogyakarta';
  String employmentStart = '1 October 2024';
  String employmentEnd = '12 December 2024';
  String education = 'smk';
  String bankAccount = '123456789';
  String bank = 'mandiri';
  String leaveLimit = '12 Days';
  bool _obscureText = true; // Kontrol visibilitas password di dialog edit
  bool _isPasswordHidden =
      true; // Kontrol visibilitas password di tampilan profil
  final ImagePicker _picker = ImagePicker();
  String? selectedAvatarUrl; // Variabel untuk menyimpan URL avatar default
  List<String> defaultAvatars = [
    'https://via.placeholder.com/150/FF0000/FFFFFF?text=Avatar+1',
    'https://via.placeholder.com/150/00FF00/FFFFFF?text=Avatar+2',
    'https://via.placeholder.com/150/0000FF/FFFFFF?text=Avatar+3'
  ];

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
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
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
            SizedBox(height: 20),
            _buildProfileItem(
              title: 'Email',
              value: email,
              onEdit: (newValue) => setState(() => email = newValue),
            ),
            _buildDivider(),
            ListTile(
              title: Text(
                'Password',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              subtitle: Text(
                _isPasswordHidden ? '••••••••' : password,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.orange),
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
            ),
            _buildDivider(),
            _buildProfileItem(
              title: 'Phone Number',
              value: phoneNumber,
              onEdit: (newValue) => setState(() => phoneNumber = newValue),
            ),
            _buildDivider(),
            _buildProfileItem(
              title: 'Address',
              value: address,
              onEdit: (newValue) => setState(() => address = newValue),
            ),
            _buildDivider(),
            _buildProfileItem(
              title: 'ID Card Address',
              value: idCardAddress,
              onEdit: (newValue) => setState(() => idCardAddress = newValue),
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
              onEdit: (newValue) => setState(() => employmentStart = newValue),
            ),
            _buildDivider(),
            _buildProfileItem(
              title: 'Employment Contract End',
              value: employmentEnd,
              onEdit: (newValue) => setState(() => employmentEnd = newValue),
            ),
            _buildDivider(),
            _buildProfileItem(
              title: 'Education',
              value: education,
              onEdit: (newValue) => setState(() => education = newValue),
            ),
            _buildDivider(),
            _buildProfileItem(
              title: 'Bank Account Number',
              value: bankAccount,
              onEdit: (newValue) => setState(() => bankAccount = newValue),
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
              onEdit: (newValue) => setState(() => leaveLimit = newValue),
            ),
          ],
        ),
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
