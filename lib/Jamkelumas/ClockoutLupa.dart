import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/susses&failde/gagalV1.dart';
import 'package:absen/susses&failde/berhasilV1.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart'; //unntuk format tanggal
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClockOutLupaScreen extends StatefulWidget {
  const ClockOutLupaScreen({super.key});

  @override
  _ClockOutLupaScreenState createState() => _ClockOutLupaScreenState();
}

class _ClockOutLupaScreenState extends State<ClockOutLupaScreen> {
  File? _image;
  String note = '';
  String formattedDate = '';
  String? _selectedWorkType;
  String? _selectedWorkplaceType;
  bool _isNoteRequired = false;
  bool _isImageRequired = false;
  bool _isDateEmpty = false;
  bool _isTimeEmpty = false;
  String? userStatus; // Tambahan untuk menyimpan user level
  List<String> WorkTypes = [];
  List<String> WorkplaceTypes = [];
  TimeOfDay? _selectedTime; // Variabel untuk menyimpan waktu clock-out
  DateTime? selectedDate;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSelectedValues();
    getProfil();
    getDatalupa();
    _setWorkTypeLembur();
  }

  Future<void> _loadSelectedValues() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    bool isClockInDone = localStorage.getBool('clockInDone') ?? false;
    if (isClockInDone) {
      setState(() {
        _selectedWorkType = localStorage.getString('workType');
        _selectedWorkplaceType = localStorage.getString('workplaceType');
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isImageRequired = false;
      });
    }
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
          selectedDate = picked;
          formattedDate = DateFormat('yyyy-MM-dd').format(picked);
          _isDateEmpty = false;
        }
      });
    }
  }

  // Future<void> _setWorkTypeLembur() async {

  //   try {
  //     final url = Uri.parse(
  //         'https://portal.eksam.cloud/api/v1/attendance/is-lembur-in');
  //     SharedPreferences localStorage = await SharedPreferences.getInstance();

  //     var request = http.MultipartRequest('GET', url);
  //     request.headers['Authorization'] =
  //         'Bearer ${localStorage.getString('token')}';

  //     var response = await request.send();
  //     var rp = await http.Response.fromStream(response);
  //     var data = jsonDecode(rp.body.toString());

  //     if (response.statusCode == 200) {
  //       bool hasClockedIn = data['message'] != 'belum clock-in';
  //       // Cek status clock-in
  //       setState(() {
  //         if (hasClockedIn) {
  //           // Jika sudah clock-in, hanya munculkan Lembur
  //           _selectedWorkType = 'Lembur';
  //         }
  //         // } else {
  //         //   // Jika belum clock-in, munculkan opsi Reguler dan Lembur
  //         //   workTypes = ['Reguler', 'Lembur'];
  //         //   _selectedWorkType = 'Reguler';
  //         // }
  //       });
  //     } else {
  //       print("Error mengecek status clock-in: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error mengecek status clock-in: $e");
  //   }
  // }

  Future<void> _setWorkTypeLembur() async {
    try {
      if (userStatus == '3') {
        setState(() {
          WorkTypes = ['Reguler'];
          _selectedWorkType = 'Reguler'; // User level 3 hanya bisa Reguler
        });
        return; // Stop di sini kalau user level 3
      }

      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/attendance/is-lembur-in');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (response.statusCode == 200) {
        bool hasClockedIn = data['message'] != 'belum clock-in';

        setState(() {
          if (hasClockedIn) {
            _selectedWorkType = 'Lembur';
          } else {
            _selectedWorkType = 'Reguler';
          }
        });
      } else {
        print("Error mengecek status clock-in: ${response.statusCode}");
      }
    } catch (e) {
      print("Error mengecek status clock-in: $e");
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _isTimeEmpty = false; // Hilangkan error setelah memilih waktu
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
        userStatus = data['data']['user_level_id'].toString();
      });

      print("Profil pengguna: ${data['data']}");
      _setWorkTypeLembur(); // Panggil setelah dapat userStatus
    } catch (e) {
      print("Error mengambil profil pengguna: $e");
    }
  }

  Future<void> getDatalupa() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/attendance/get-detail');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (response.statusCode == 200) {
        setState(() {
          print(data[data]['attendance_type_id']);
          print(data[data]['attendance_location_id']);

          _selectedWorkType = data['data']['attendance_type_id'].toString();
          _selectedWorkplaceType =
              data['data']['attendance_location_id'].toString();
        });
      } else {
        print("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> _submitData() async {
    setState(() {
      _isDateEmpty = selectedDate == null;
      _isTimeEmpty = _selectedTime == null;
      _isImageRequired = _image == null;
      _isNoteRequired = _noteController.text.isEmpty;
    });

    if (_isDateEmpty || _isTimeEmpty || _isImageRequired || _isNoteRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua field sebelum submit.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String formattedTime =
        "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 101, 19, 116),
          ),
        );
      },
    );

    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/attendance/clock-out-lupa');
      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      request.fields['notes'] = _noteController.text;
      request.fields['jam_clock_out'] = formattedTime; // Kirim waktu clock-out
      request.fields['date'] = formattedDate;

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          _image!.path,
          contentType: MediaType('image', 'jpg'),
        ));
      }

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SuccessPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FailurePage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => FailurePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Clock Out'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Work Type Dropdown
              const Text('Work Type',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(101, 19, 116, 1))),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWorkType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                ),
                items: [_selectedWorkType ?? 'No Work Type Selected']
                    .map((String workType) {
                  return DropdownMenuItem<String>(
                      value: workType, child: Text(workType));
                }).toList(),
                onChanged: null, // Disabled
              ),
              const SizedBox(height: 20),
              // Workplace Type Dropdown
              const Text('Workplace Type',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(101, 19, 116, 1))),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWorkplaceType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                ),
                items: [_selectedWorkplaceType ?? 'No Workplace Type Selected']
                    .map((String workplaceType) {
                  return DropdownMenuItem<String>(
                      value: workplaceType, child: Text(workplaceType));
                }).toList(),
                onChanged: null, // Disabled
              ),
              const SizedBox(height: 20),
              // Date picker field
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDateEmpty
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
                    errorText: _isDateEmpty
                        ? 'Tanggal Wajib Di isi'
                        : null, // Error message
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null ? 'Select Date' : formattedDate,
                      ),
                      const Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Input untuk Clock-Out Time
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Clock-Out Time',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.always, // Label selalu di atas
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isTimeEmpty
                              ? Colors.red
                              : const Color.fromARGB(255, 101, 19, 116)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 101, 19, 116), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText:
                        _isTimeEmpty ? 'Clock-Out Time Wajib Diisi' : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? 'Select Time'
                            : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.access_time,
                          color: Colors.orange), // Ikon jam
                    ],
                  ),
                ),
              ),

              // const Text(
              //   'Clock-Out Time',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              // ),
              // const SizedBox(height: 10),
              // InkWell(
              //   onTap: _pickTime,
              //   child: Container(
              //     padding: const EdgeInsets.all(15),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.purple, width: 2),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Text(
              //       _selectedTime == null
              //           ? 'Select Time'
              //           : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
              //       style: const TextStyle(fontSize: 16),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),

              // Upload Photo Button
              GestureDetector(
                onTap: _pickImage, // Langsung panggil kamera
                child: Container(
                  height: 130,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isImageRequired
                          ? Colors.red
                          : (_image == null
                              ? const Color.fromRGBO(101, 19, 116, 1)
                              : Colors.orange), // Red if image is required
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
                                : Colors
                                    .orange), // Red icon if image is required
                      ),
                      const SizedBox(height: 3),
                      if (_image == null && !_isImageRequired)
                        const Text(
                          'Upload Photo Anda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(101, 19, 116, 1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Preview Photo Button
              if (_image != null)
                Align(
                  alignment: Alignment.centerLeft, // Atur posisi teks di kiri
                  child: InkWell(
                    onTap: () {
                      // Show dialog to preview the photo
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (kIsWeb)
                                  // Jika platform adalah Web
                                  Image.network(
                                    _image!.path,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  // Jika platform bukan Web (mobile)
                                  Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
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
                        color: Colors.orange, // Warna teks seperti hyperlink
                        decoration: TextDecoration
                            .underline, // Garis bawah untuk efek hyperlink
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // TextField for Note
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  labelStyle: TextStyle(
                    color: _isNoteRequired ? Colors.red : Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isNoteRequired
                          ? Colors.red
                          : const Color.fromRGBO(101, 19, 116, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isNoteRequired
                          ? Colors.red
                          : const Color.fromRGBO(101, 19, 116, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _isNoteRequired = false;
                    });
                  }
                },
              ),

              const SizedBox(height: 120),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData, // Call the function to submit data
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    iconColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 120,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 15, color: Colors.white),
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
