import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/susses&failde/gagalV1.dart';
import 'package:absen/susses&failde/berhasilV1II.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ClockOutScreen extends StatefulWidget {
  const ClockOutScreen({super.key});

  @override
  _ClockOutScreenState createState() => _ClockOutScreenState();
}

class _ClockOutScreenState extends State<ClockOutScreen> {
  String note = '';
  String? _selectedWorkType;
  String? _selectedWorkplaceType;
  String? userStatus; // Tambahan untuk menyimpan user level
  File? _image;
  bool _isNoteRequired = false;
  bool _isImageRequired = false;
  bool isWithinRange = true; // Default true agar tidak menghalangi WFH
    bool panding = false; 
  bool approve = false;
  bool reject = false;
  List<String> WorkTypes = [];
  List<String> WorkplaceTypes = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSelectedValues();
    getData();
    getProfil();
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

  Future<void> getProfil() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (rp.statusCode == 200) {
        double officeLatitude =
            double.tryParse(data['data']['latitude'].toString()) ?? 0.0;
        double officeLongitude =
            double.tryParse(data['data']['longitude'].toString()) ?? 0.0;

        // Hitung jarak antara user dan kantor
        double distance = Geolocator.distanceBetween(
            userLatitude, userLongitude, officeLatitude, officeLongitude);

        print("Jarak dari kantor: $distance meter");
      } else {
        print("Error mengambil profil pengguna: ${rp.statusCode}");
      }
    } catch (e) {
      print("Error mengambil data lokasi: $e");
    }
  }

  Future<void> getData() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/get-self-detail-today');
    var request = http.MultipartRequest('GET', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        var data = jsonDecode(rp.body.toString());
        print(data);
        setState(() {
          _selectedWorkType = data['data']['type']['name'];
          _selectedWorkplaceType = data['data']['location']['name'];
        });

        // Jika user memilih WFO, lakukan validasi jarak
      } else {
        print('Error fetching history data: ${rp.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

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
        // Cek status clock-in
        setState(() {
          if (hasClockedIn) {
            // Jika sudah clock-in, hanya munculkan Lembur
            _selectedWorkType = 'Lembur';
          } else {
            // Jika belum clock-in, munculkan opsi Reguler dan Lembur
            WorkTypes = ['Reguler', 'Lembur'];
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

  Future<void> getDataOvertime() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/cek-approval-lembur');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final token = localStorage.getString('token');

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          panding = data['message'] != 'Pengajuan lembur masih pending';
          reject = data['message'] != 'Pengajuan lembur ditolak';
          approve = data['message'] != 'Pengajuan lembur sudah di-approve';
        });
      } else {
        print('Error fetching overtime data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _submitDataovertimeout() async {
    if (_noteController.text.isEmpty) {
      setState(() {
        _isNoteRequired = true;
      });
      return;
    }

    if (_image == null) {
      setState(() {
        _isImageRequired = true;
      });
      return;
    }

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
          'https://portal.eksam.cloud/api/v1//attendance/overtime-out-new');
      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      // Tambahkan Authorization Bearer Token
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';
      request.fields['notes'] = _noteController.text;
      request.files.add(await http.MultipartFile.fromPath(
        'foto',
        _image!.path,
        contentType: MediaType('image', 'jpg'),
      ));

      var response = await request.send();
      Navigator.pop(context); // Tutup dialog loading

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPageII()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FailurePage()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FailurePage()),
      );
    }
  }

  Future<void> _submitDataovertimeapprove() async {
    if (_noteController.text.isEmpty) {
      setState(() {
        _isNoteRequired = true;
      });
      return;
    }

    if (_image == null) {
      setState(() {
        _isImageRequired = true;
      });
      return;
    }

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
          'https://portal.eksam.cloud/api/v1/attendance/overtime-out-approved');
      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['notes'] = _noteController.text;
      request.files.add(await http.MultipartFile.fromPath(
        'foto',
        _image!.path,
        contentType:
            MediaType('image', 'jpeg'), // Pastikan sesuai format yang dikirim
      ));

      var response = await request.send();
      Navigator.pop(context); // Tutup loading

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPageII()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FailurePage()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FailurePage()),
      );
    }
  }


  Future<void> _submitData() async {
    if (_noteController.text.isEmpty) {
      setState(() {
        _isNoteRequired = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the note before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/attendance/clock-out');
      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      request.fields['notes'] = _noteController.text;

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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SuccessPageII()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FailurePage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const FailurePage()));
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
           if (_selectedWorkType == "Lembur" &&
                (userStatus == "1" || userStatus == "2")) ...[
              if (panding || reject)
                Center(
                  child: ElevatedButton(
                    onPressed: _submitDataovertimeout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      iconColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 120,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Submit Overtime Out',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                )
              else if (approve)
                Center(
                  child: ElevatedButton(
                    onPressed: _submitDataovertimeapprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      iconColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 120,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Submit Overtime Approved',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                )
            ] else if (userStatus == "1" ||
                userStatus == "2" ||
                userStatus == "3") ...[
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
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
              )
            ],
          ],
        ),
      ),
    ),
  );
}
}
