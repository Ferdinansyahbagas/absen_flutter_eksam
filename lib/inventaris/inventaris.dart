import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // for formatting date
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:absen/inventaris/datainventaris.dart';
import 'package:absen/susses&failde/berhasiltambah.dart';
import 'package:absen/susses&failde/gagalinven.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String keterangan = '';
  List<dynamic> _inventoryList = [];
  String? userId;
  String tanggalPembelian = '';
  String tanggalPeminjaman = '';
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isImageRequired = false;
  bool isLoading = false;
  DateTime? _tanggalPembelian;
  DateTime? _tanggalPeminjaman;
  String formattedDate = '';
  bool _istanggalPeminjamanEmpty = false;
  bool _istanggalPembelianEmpty = false;
  bool _isNameEmpty = false;
  bool _isKeteranganEmpty = false;

  @override
  void initState() {
    super.initState();
    fetchInventory();
    getProfil();
  }

  // *Menampilkan dialog pilihan sumber gambar*
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // *Mengambil gambar dari sumber yang dipilih*
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isImageRequired = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isPembelian) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isPembelian) {
          _tanggalPembelian = picked;
          tanggalPembelian = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _tanggalPeminjaman = picked;
          tanggalPeminjaman = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> getProfil() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        userId = data['data']['user_id'].toString();
      });

      // Simpan user_id ke SharedPreferences
      localStorage.setInt('user_id', data['data']['id']);

      print("Profil pengguna: ${data['data']}");
    } catch (e) {
      print("Error mengambil profil pengguna: $e");
    }
  }

  Future<void> fetchInventory() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/get-self-inventory');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] != null && data['data'] is List) {
          setState(() {
            _inventoryList = data['data'];
            print("Data inventory: $_inventoryList");
          });
        } else {
          print('Format respons tidak sesuai: ${data['message']}');
        }
      } else {
        print('Gagal ambil data, status: ${response.statusCode}');
        print('Isi respons: ${response.body}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat fetchInventory: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addInventory() async {
    setState(() {
      _isNameEmpty = name.isEmpty;
      _isKeteranganEmpty = keterangan.isEmpty;
      _istanggalPeminjamanEmpty = tanggalPeminjaman.isEmpty;
      _istanggalPembelianEmpty = tanggalPembelian.isEmpty;
    });

    if (_isNameEmpty ||
        _isKeteranganEmpty ||
        _istanggalPeminjamanEmpty ||
        _istanggalPembelianEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      setState(() {
        _isImageRequired = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/add-self-inventory');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');

      if (token == null) {
        Navigator.of(context).pop(); // tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak ditemukan.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = name
        ..fields['keterangan'] = keterangan
        ..fields['tanggal_pembelian'] = tanggalPembelian
        ..fields['tanggal_peminjaman'] = tanggalPeminjaman;

      request.files.add(await http.MultipartFile.fromPath(
        'foto_barang',
        _image!.path,
        contentType: MediaType('image', 'jpg'),
      ));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final result = jsonDecode(resBody);

      Navigator.of(context).pop(); // tutup loading

      if (response.statusCode == 200 && result['status'] == 'success') {
        await fetchInventory();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Successinventory()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to submit: ${result['message'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FailurePageinven()),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // pastikan dialog tertutup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FailurePageinven()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventaris Kantor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nama Barang',
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isNameEmpty
                            ? Colors.red
                            : const Color.fromARGB(255, 101, 19, 116)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 101, 19, 116), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border saat error
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border saat error dan fokus
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _isNameEmpty ? 'Tolong Isi Nama Barang' : null,
                ),
                onChanged: (value) {
                  setState(() {
                    name = value;
                    _isNameEmpty = false;
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isKeteranganEmpty
                            ? Colors.red
                            : const Color.fromARGB(255, 101, 19, 116)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 101, 19, 116), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border saat error
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border saat error dan fokus
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText:
                      _isKeteranganEmpty ? 'Tolong Isi Nama Barang' : null,
                ),
                onChanged: (value) {
                  setState(() {
                    keterangan = value;
                    _isKeteranganEmpty = false;
                  });
                },
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Pembelian',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _istanggalPembelianEmpty
                              ? Colors.red
                              : const Color.fromARGB(255, 101, 19, 116)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 101, 19, 116), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.red), // Border saat error
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.red), // Border saat error dan fokus
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _istanggalPembelianEmpty
                        ? 'Tolong Isi Tanggal Pembelian'
                        : null, // Error message
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tanggalPembelian == null
                            ? 'Select Start Date'
                            : DateFormat('yyyy-MM-dd')
                                .format(_tanggalPembelian!),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Peminjaman',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _istanggalPeminjamanEmpty
                              ? Colors.red
                              : const Color.fromARGB(255, 101, 19, 116)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 101, 19, 116), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.red), // Border saat error
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.red), // Border saat error dan fokus
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _istanggalPeminjamanEmpty
                        ? 'Tolong Isi Tanggal Peminjaman'
                        : null, // Error message
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tanggalPeminjaman == null
                            ? 'Select Start Date'
                            : DateFormat('yyyy-MM-dd')
                                .format(_tanggalPeminjaman!),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Upload Photo Button
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 130,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isImageRequired
                          ? Colors.red
                          : (_image == null
                              ? const Color.fromRGBO(101, 19, 116, 1)
                              : Colors.orange),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 35,
                        color: _isImageRequired
                            ? Colors.red
                            : (_image == null
                                ? const Color.fromRGBO(101, 19, 116, 1)
                                : Colors.orange),
                      ),
                      const SizedBox(height: 3),
                      if (_image == null && !_isImageRequired)
                        const Text(
                          'Upload Photo Anda',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(101, 19, 116, 1)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (_image != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (kIsWeb)
                                  Image.network(_image!.path, fit: BoxFit.cover)
                                else
                                  Image.file(_image!, fit: BoxFit.cover),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Lihat Photo',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.orange,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await addInventory();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Tambah',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => dataInventory(),
                      ),
                    );
                  },
                  child: Text(
                    'Data Inventaris',
                    style: TextStyle(
                      color: Colors.blue, // Warna teks biru
                      decoration: TextDecoration.underline, // Garis bawah
                      decorationColor: Colors.blue, // Warna garis bawah biru
                      decorationThickness: 2, // Ketebalan garis bawah
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
