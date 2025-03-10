import 'package:flutter/material.dart';
import 'TimeoffScreen.dart';
import 'package:absen/susses&failde/berhasilV2II.dart';
import 'package:absen/susses&failde/gagalV2II.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeOffSick extends StatefulWidget {
  const TimeOffSick({super.key});

  @override
  _TimeOffSickState createState() => _TimeOffSickState();
}

class _TimeOffSickState extends State<TimeOffSick> {
  String formatStarttedDate = '';
  String formatEndtedDate = '';
  String Reason = '';
  final String _selectedType = 'Sick';
  String? limit;
  String? iduser;
  String? type = '2';
  File? _image; // To store the image file
  bool _isReasonEmpty = false;
  bool _isStartDateEmpty = false;
  bool _isEndDateEmpty = false;
  bool _isImageRequired = false;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? selectedDate;
  final ImagePicker _picker = ImagePicker();
  // final _reasonController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          formatStarttedDate = DateFormat('yyyy-MM-dd').format(picked);
          _selectedStartDate = picked;
          _isStartDateEmpty = false;
        } else {
          formatEndtedDate = DateFormat('yyyy-MM-dd').format(picked);
          _selectedEndDate = picked;
          _isEndDateEmpty = false;
        }
      });
    }
  }

  Future<void> getProfile() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');

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
          limit = data['data']['batas_cuti'].toString();
          iduser = data['data']['id'].toString();
        });
        localStorage.setString('id', data['data']['id']);
      } else {
        print("Error retrieving profile");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<void> _pickImage() async {
  //   final XFile? pickedFile =
  //       await _picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //       _isImageRequired = false;
  //     });
  //   }
  // }
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

  // Function to submit data to API
  Future<void> _submitData() async {
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

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 101, 19, 116),
          ),
        );
      },
    );

    try {
      await getProfile();
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/request-history/make-request');

      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      String formattedStartDate = _selectedStartDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
          : '';
      String formattedEndDate = _selectedEndDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
          : '';

      // Sesuaikan tipe cuti
      if (_selectedType == "Sick") {
        setState(() {
          type = '2';
        });
      }

      // Add image file if selected
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'surat_sakit', // Field name in the API
          _image!.path,
        ));
      }

      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';
      request.fields['user_id'] = iduser.toString();
      request.fields['notes'] = Reason.toString();
      request.fields['startdate'] = formattedStartDate;
      request.fields['enddate'] = formattedEndDate;
      request.fields['type'] = type.toString();

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      print(rp.body.toString());
      var data = jsonDecode(rp.body.toString());
      print(data);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPage2II()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FailurePage2II()),
        );
      }
    } catch (e) {
      print(e);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FailurePage2II()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TimeOffScreen()),
            ); // Aksi kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'Time Off',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Membungkus body agar bisa digulir
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remaining Leave
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 140,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 25.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 147, 4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Teks di sebelah kiri
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Tengah vertikal
                      children: [
                        Text(
                          'Your Remaining\nLeave Is',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Angka di sebelah kanan
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline
                            .alphabetic, // Menambahkan baseline agar teks sejajar
                        children: [
                          Text(
                            limit.toString(),
                            style: const TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Text(
                              '/',
                              style: TextStyle(
                                fontSize: 44,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(
                            '12',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isReasonEmpty
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
                      _isReasonEmpty ? 'Tolong Berikan Alasan Anda' : null,
                ),
                onChanged: (value) {
                  setState(() {
                    Reason = value;
                    _isReasonEmpty = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Pertama',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isStartDateEmpty
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
                    errorText: _isStartDateEmpty
                        ? 'Tolong Isi Tanggal Pertama'
                        : null, // Error message
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedStartDate == null
                            ? 'Select Start Date'
                            : DateFormat('yyyy-MM-dd')
                                .format(_selectedStartDate!),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Akhir',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isEndDateEmpty
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
                    errorText: _isEndDateEmpty
                        ? 'Tolong Isi Tanggal Akhir'
                        : null, // Error message
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedEndDate == null
                            ? 'Select Start Date'
                            : DateFormat('yyyy-MM-dd')
                                .format(_selectedEndDate!),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
//               GestureDetector(
//                 onTap: _pickImage, // Langsung panggil kamera
//                 child: Container(
//                   height: 130,
//                   width: 150,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: _isImageRequired
//                           ? Colors.red
//                           : (_image == null
//                               ? const Color.fromRGBO(101, 19, 116, 1)
//                               : Colors.orange), // Red if image is required
//                       width: 2,
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.camera_alt,
//                         size: 35,
//                         color: _isImageRequired
//                             ? Colors.red
//                             : (_image == null
//                                 ? const Color.fromRGBO(101, 19, 116, 1)
//                                 : Colors
//                                     .orange), // Red icon if image is required
//                       ),
//                       const SizedBox(height: 3),
//                       if (_image == null && !_isImageRequired)
//                         const Text(
//                           'Upload Photo Anda ',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color.fromRGBO(101, 19, 116, 1),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),

// // Preview Photo Button
//               if (_image != null)
//                 Align(
//                   alignment: Alignment.centerLeft, // Atur posisi teks di kiri
//                   child: InkWell(
//                     onTap: () {
//                       // Show dialog to preview the photo
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return Dialog(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 if (kIsWeb)
//                                   // Jika platform adalah Web
//                                   Image.network(
//                                     _image!.path,
//                                     fit: BoxFit.cover,
//                                   )
//                                 else
//                                   // Jika platform bukan Web (mobile)
//                                   Image.file(
//                                     _image!,
//                                     fit: BoxFit.cover,
//                                   ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: const Text(
//                       'Lihat Photo',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.orange, // Warna teks seperti hyperlink
//                         decoration: TextDecoration
//                             .underline, // Garis bawah untuk efek hyperlink
//                       ),
//                     ),
//                   ),
//                 ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Pastikan semua input sudah diisi
                    if (_selectedStartDate == null) {
                      setState(() {
                        _isStartDateEmpty = true;
                      });
                    }
                    if (_selectedEndDate == null) {
                      setState(() {
                        _isEndDateEmpty = true;
                      });
                    }
                    if (Reason.isEmpty) {
                      setState(() {
                        _isReasonEmpty = true;
                      });
                    }

                    // Jika ada input yang belum diisi, jangan lanjutkan
                    if (_isStartDateEmpty ||
                        _isEndDateEmpty ||
                        _isReasonEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete all required fields.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Jika semua input valid, kirim data
                    await _submitData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
