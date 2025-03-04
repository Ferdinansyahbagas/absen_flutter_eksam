import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:absen/timeoff/TimeoffScreen.dart';
import 'package:absen/screen/loginscreen.dart';
import 'package:absen/homepage/notif.dart';
import 'package:absen/homepage/home.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';
import 'package:absen/utils/preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:absen/utils/notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 0; // Untuk mengatur indeks dari BottomNavigationBar
  final PageController _pageController = PageController();
  String? profileImageUrl;
  String? idCardImageUrl;
  String? cvImageUrl;
  String name = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String idCardAddress = '';
  String employmentStart = '';
  String employmentEnd = '';
  String education = '';
  String bankAccount = '';
  String bank = '';
  String Limit = '';
  File? profileImage;
  File? _idCardImage;
  File? _cvImage;
  File? _ProfilImage;
  String? selectedAvatarUrl; // Variabel untuk menyimpan URL avatar default
  bool _obscureText = true; // Kontrol visibilitas password di dialog edit
  final ImagePicker _picker = ImagePicker();
  List<String> pendidikanOptions = [];
  List<String> bankOptions = [];
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    getPendidikan();
    _getBank();
    loadProfileImage();
    getProfile();
  }

  Future<void> saveImageUrls({
    String? profileUrl,
    String? idCardUrl,
    String? cvUrl,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (profileUrl != null) {
      await prefs.setString('profileImageUrl', profileUrl);
    }
    if (idCardUrl != null) {
      await prefs.setString('idCardImageUrl', idCardUrl);
    }
    if (cvUrl != null) {
      await prefs.setString('cvImageUrl', cvUrl);
    }
  }

  // Fungsi untuk mengambil URL dari SharedPreferences
  Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('profileImageUrl');
      idCardImageUrl = prefs.getString('idCardImageUrl');
      cvImageUrl = prefs.getString('cvImageUrl');
    });
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
        List<dynamic> loadedNotifications =
            List.from(data['data']).map((notif) {
          return {
            // 'id': notif['id'],
            // 'title': notif['title']?.toString(),
            // 'description': notif['description']?.toString(),
            // 'fileUrl': notif['file'] != null
            //     ? "https://dev-portal.eksam.cloud/storage/file/${notif['file']}"
            //     : null,
            'isRead': notif['isRead'] ?? false,
          };
        }).toList();

        // Cek status dari SharedPreferences
        for (var notif in loadedNotifications) {
          notif['isRead'] = await _isNotificationRead(notif['id']) ||
              notif['isRead']; // Gabungkan status dari API dan lokal
        }

        setState(() {
          notifications = loadedNotifications;
          bool hasUnread = notifications.any((notif) => !notif['isRead']);
          NotificationHelper.setUnreadNotifications(hasUnread); // Simpan status
        });
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {});
    }
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

  Future<void> getPendidikan() async {
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/other/get-pendidikan');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pendidikanOptions =
              List<String>.from(data['data'].map((item) => item['pendidikan']));
        });
      } else {
        print('Error fetching education data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _getBank() async {
    final url = Uri.parse('https://portal.eksam.cloud/api/v1/other/get-bank-parameter');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bankOptions =
              List<String>.from(data['data'].map((item) => item['name']));
        });
      } else {
        print('Error fetching bank data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> setProfile() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/set-profile');

      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';
      request.fields['no_rekening'] = bankAccount;
      request.fields['no_hp'] = phoneNumber;
      request.fields['alamat_domisili'] = address;
      request.fields['alamat_ktp'] = idCardAddress;
      request.fields['email'] = email;
      request.fields['name'] = name;

      request.fields['pendidikan_id'] = education;
      request.fields['bank_id'] = bank;
      if (_cvImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'riwayat_hidup',
          _cvImage!.path,
          contentType: MediaType('image', 'jpg'),
        ));
      }

      if (_ProfilImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          _ProfilImage!.path,
          contentType: MediaType('image', 'jpg'),
        ));
      }

      if (_idCardImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'ktp',
          _idCardImage!.path,
          contentType: MediaType('image', 'jpg'),
        ));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        // final responseBody = await http.Response.fromStream(response);
        // final data = jsonDecode(responseBody.body);
      } else {}
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getProfile() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');

      SharedPreferences localStorage = await SharedPreferences.getInstance();
      final token = localStorage.getString('token');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profileImageUrl =
              "https://portal.eksam.cloud/storage/foto/${data['data']['foto']}";
          idCardImageUrl =
              "https://portal.eksam.cloud/storage/ktp/${data['data']['foto_ktp']}";
          cvImageUrl =
              "https://portal.eksam.cloud/storage/cv/${data['data']['riwayat_hidup']}";
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
        saveImageUrls(
            profileUrl: profileImageUrl,
            idCardUrl: idCardImageUrl,
            cvUrl: cvImageUrl);
      } else {
        print("Error retrieving profile");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImage(String imageType) async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 20);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Resize image if needed
      img.Image? decodedImage = img.decodeImage(imageFile.readAsBytesSync());
      if (decodedImage != null) {
        img.Image resizedImage = img.copyResize(decodedImage, width: 600);
        final resizedFile = File(pickedFile.path)
          ..writeAsBytesSync(img.encodeJpg(resizedImage));

        setState(() {
          switch (imageType) {
            // case 'Profile':
            //   profileImage = resizedFile;
            //   profileImageUrl = resizedFile.path;
            //   saveImageUrls(profileUrl: profileImageUrl);
            //   break;
            case 'ID CARD':
              _idCardImage = resizedFile;
              idCardImageUrl = resizedFile.path;
              saveImageUrls(idCardUrl: idCardImageUrl);
              break;
            case 'CV':
              _cvImage = resizedFile;
              cvImageUrl = resizedFile.path;
              saveImageUrls(cvUrl: cvImageUrl);
              break;
          }
        });

        await setProfile(); // Send updated image to API
      }
    }
  }

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImageId(String imageType) async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 20);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Resize image if needed
      img.Image? decodedImage = img.decodeImage(imageFile.readAsBytesSync());
      if (decodedImage != null) {
        img.Image resizedImage = img.copyResize(decodedImage, width: 600);
        final resizedFile = File(pickedFile.path)
          ..writeAsBytesSync(img.encodeJpg(resizedImage));

        setState(() {
          switch (imageType) {
            // case 'Profile':
            //   profileImage = resizedFile;
            //   profileImageUrl = resizedFile.path;
            //   saveImageUrls(profileUrl: profileImageUrl);
            //   break;
            case 'ID CARD':
              _idCardImage = resizedFile;
              idCardImageUrl = resizedFile.path;
              saveImageUrls(idCardUrl: idCardImageUrl);
            //   break;
            // case 'CV':
            //   _cvImage = resizedFile;
            //   cvImageUrl = resizedFile.path;
            //   saveImageUrls(cvUrl: cvImageUrl);
            //   break;
          }
        });

        await setProfile(); // Send updated image to API
      }
    }
  }

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Mengubah ukuran gambar
      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
      if (image != null) {
        // Ubah ukuran gambar menjadi lebih kecil jika terlalu besar
        img.Image resized = img.copyResize(image,
            width: 600); // Sesuaikan ukuran sesuai kebutuhan
        final resizedFile = File(pickedFile.path)
          ..writeAsBytesSync(img.encodeJpg(resized));

        setState(() {
          profileImage = resizedFile;
          _ProfilImage = resizedFile; // Simpan gambar ke variabel
        });
      }
      await setProfile(); // Panggil setProfile tanpa parameter
    }
  }

  Widget _buildImageCard(String title, String? imageUrl, String imageType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(imageType), // Memilih gambar
          child: Container(
            height: 150,
            width: 150,
            color: Colors.grey[300],
            child: imageUrl != null && Uri.parse(imageUrl).isAbsolute
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : imageUrl != null
                    ? Image.file(File(imageUrl), fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.add_a_photo,
                            size: 20, color: Colors.grey),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCardId(String title, String? imageUrl, String imageType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImageId(imageType), // Memilih gambar
          child: Container(
            height: 150,
            width: 150,
            color: Colors.grey[300],
            child: imageUrl != null && Uri.parse(imageUrl).isAbsolute
                ? Image.network(imageUrl)
                : imageUrl != null
                    ? Image.file(File(imageUrl), fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.add_a_photo,
                            size: 20, color: Colors.grey),
                      ),
          ),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Menjaga elemen tetap sejajar
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                  softWrap: true, // Agar teks membungkus
                  overflow: TextOverflow.visible, // Biarkan teks tetap terlihat
                ),
              ),
              if (isEditable) // Tampilkan tombol edit hanya jika isEditable true
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    if (onEdit != null) {
                      _showEditDialog(title, value, onEdit);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNohp({
    required String title,
    required String value,
    Function(String)?
        onEdit, // Fungsi hanya diperlukan untuk item yang bisa diedit
    bool isEditable = true, // Default: bisa diedit
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Menjaga elemen sejajar vertikal
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                  softWrap: true, // Agar teks membungkus
                  overflow: TextOverflow
                      .ellipsis, // Tambahkan elipsis jika teks terlalu panjang
                ),
              ),
              if (isEditable) // Tampilkan tombol edit hanya jika isEditable true
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    if (onEdit != null) {
                      _showEditNoHp(title, value, onEdit);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog edit lain lain
  void _showEditDialog(
      String title, String currentValue, Function(String) onSave,
      {bool isPasswordField = false}) {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    String? errorText; // Variabel untuk menampung pesan error

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: isPasswordField ? _obscureText : false,
                    decoration: InputDecoration(
                      labelText: 'Enter new $title',
                      errorText: errorText, // Tampilkan error jika ada
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
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: errorText == null
                              ? Colors.grey
                              : Colors.red, // Border merah jika error
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: errorText == null
                              ? Colors.purple
                              : Colors.red, // Border merah jika error
                        ),
                      ),
                    ),
                  ),
                  // if (errorText != null) // Tampilkan pesan error jika ada
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 5),
                  //     child: Text(
                  //       "Wajib diisi!!!",
                  //       style: TextStyle(
                  //         color: Colors.red,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Validasi input
                    if (controller.text.trim().isEmpty) {
                      setState(() {
                        errorText = "Wajib Di Isi !!!";
                      });
                    } else {
                      // Panggil onSave dengan nilai baru
                      onSave(controller.text);

                      // Setelah menyimpan perubahan, perbarui data di API
                      setProfile();

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditNoHp(String title, String currentValue, Function(String) onSave,
      {bool isPasswordField = false}) {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    String? errorText; // Variabel untuk menampung pesan error

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: isPasswordField ? _obscureText : false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter new $title',
                      errorText: errorText, // Tampilkan error jika ada
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
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: errorText == null
                              ? Colors.grey
                              : Colors.red, // Border merah jika error
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: errorText == null
                              ? Colors.purple
                              : Colors.red, // Border merah jika error
                        ),
                      ),
                    ),
                  ),
                  // if (errorText != null) // Tampilkan pesan error jika ada
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 5),
                  //     child: Text(
                  //       "Wajib diisi!!!",
                  //       style: TextStyle(
                  //         color: Colors.red,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Validasi input
                    if (controller.text.trim().isEmpty) {
                      setState(() {
                        errorText = "Wajib Di Isi !!!";
                      });
                    } else {
                      // Panggil onSave dengan nilai baru
                      onSave(controller.text);

                      // Setelah menyimpan perubahan, perbarui data di API
                      setProfile();

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    bool obscureOldPassword = true;
    bool obscureNewPassword = true;
    String? oldPasswordError;
    String? newPasswordError;

    Future<void> setPass() async {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/karyawan/change-pass-self');
      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      // Isi body request dengan password lama dan baru
      request.fields['old_password'] = oldPasswordController.text;
      request.fields['password'] = newPasswordController.text;

      try {
        var response = await request.send();
        var rp = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          // Password berhasil diubah
          Navigator.pop(context); // Tutup dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password successfully updated')),
          );
        } else {
          // Tangani error jika password lama salah
          final data = jsonDecode(rp.body);
          if (data['message'] == 'Old password is incorrect') {
            setState(() {
              oldPasswordError = 'Incorrect old password';
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update password')),
            );
          }
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: obscureOldPassword,
                    decoration: InputDecoration(
                      labelText: 'Old Password',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: oldPasswordError != null
                              ? Colors.red
                              : Colors.purple,
                        ),
                      ),
                      errorText: oldPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureOldPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureOldPassword = !obscureOldPassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {
                        oldPasswordError = null; // Reset error saat mengetik
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: newPasswordError != null
                              ? Colors.red
                              : Colors.purple,
                        ),
                      ),
                      errorText: newPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {
                        newPasswordError = null; // Reset error saat mengetik
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Validasi sebelum mengirim data ke API
                        setState(() {
                          oldPasswordError = oldPasswordController.text.isEmpty
                              ? 'Old password is required'
                              : null;

                          // Validasi password baru minimal 6 karakter
                          if (newPasswordController.text.isEmpty) {
                            newPasswordError = 'New password is required';
                          } else if (newPasswordController.text.length < 6) {
                            newPasswordError =
                                'New password must be at least \n 6 characters';
                          } else {
                            newPasswordError = null;
                          }
                        });

                        if (oldPasswordError == null &&
                            newPasswordError == null) {
                          setPass(); // Panggil fungsi untuk update password
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    // Hapus token dari SharedPreferences
    await Preferences.clearToken();

    // Navigasi kembali ke WelcomeScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  final TextStyle titleStyle =
      const TextStyle(fontSize: 14, color: Colors.black54);
  final TextStyle valueStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

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
                        Color.fromARGB(255, 101, 19, 116)
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
                                  : (profileImageUrl != null
                                      ? NetworkImage(profileImageUrl!)
                                      : const AssetImage(
                                          'assets/image/logo_circle.png')),
                              //         as ImageProvider,
                              // backgroundColor: Colors.grey[200],
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.orange, size: 30),
                                onPressed: _pickImageFromGallery,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Hello!',
                          style: TextStyle(fontSize: 20),
                        ),
                        // Text(
                        //   name,
                        //   style: const TextStyle(
                        //       fontSize: 24,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.white),
                        // ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        title: 'Name',
                        value: name,
                        onEdit: (newValue) => setState(() {
                          name = newValue; // Update value setelah edit
                        }),
                      ),
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
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Edit Password',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        10), // Menambah jarak tetap antara teks dan ikon
                                IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    onPressed: _showChangePasswordDialog),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildNohp(
                        title: 'Nomor HP',
                        value: phoneNumber,
                        onEdit: (newValue) => setState(() {
                          phoneNumber = newValue; // Update value setelah edit
                        }),
                      ),
                      _buildProfileItem(
                        title: 'Alamat',
                        value: address,
                        onEdit: (newValue) => setState(() {
                          address = newValue; // Update value setelah edit
                        }),
                      ),
                      const Divider(
                        height: 30,
                        thickness: 1,
                        color: Color.fromRGBO(101, 19, 116, 1),
                      ),
                      _buildProfileItem(
                        title: 'Alamat KTP',
                        value: idCardAddress,
                        onEdit: (newValue) => setState(() {
                          idCardAddress = newValue; // Update value setelah edit
                        }),
                      ),
                      const SizedBox(height: 14),
                      _buildImageCardId("Foto KTP", idCardImageUrl, 'ID CARD'),
                      const Divider(
                        height: 30,
                        thickness: 1,
                        color: Color.fromRGBO(101, 19, 116, 1),
                      ),
                      _buildImageCard("Foto CV", cvImageUrl, 'CV'),
                      const SizedBox(height: 14),
                      _buildProfileItem(
                        title: 'Kontrak Kerja Mulai',
                        value: employmentStart,
                        isEditable: false, // Tidak bisa diedit
                      ),
                      _buildProfileItem(
                        title: 'Kontrak Kerja Akhir',
                        value: employmentEnd,
                        isEditable: false, // Tidak bisa diedit
                      ),
                      const SizedBox(height: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pendidikan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: education.isNotEmpty ? education : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(101, 19, 116, 1),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(101, 19, 116, 1),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: pendidikanOptions.map((String id) {
                              return DropdownMenuItem<String>(
                                value: id,
                                child: Text(id),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                education = newValue!;
                              });
                              setProfile();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
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
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: bank.isNotEmpty ? bank : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(101, 19, 116, 1),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(101, 19, 116, 1),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: bankOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                bank = newValue!;
                              });
                              setProfile();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildNohp(
                        title: 'Bank Account Number',
                        value: bankAccount,
                        onEdit: (newValue) => setState(() {
                          bankAccount = newValue; // Update value setelah edit
                        }),
                      ),
                      const SizedBox(height: 14),
                      _buildNohp(
                        title: 'Batas Cuti',
                        value: Limit,
                        isEditable: false, // Tidak bisa diedit
                      ),
                      const SizedBox(height: 20),
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
        items: [
          const BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icon/home.png'), // Custom icon
              size: 18,
              color: Colors.white,
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
            icon: Icon(Icons.receipt, size: 27),
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
                (route) => false,
              );
              break;
            case 4:
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => const ProfileScreen()),
              //   (route) => false,
              // );
              break;
          }
        },
      ),
    );
  }
}
