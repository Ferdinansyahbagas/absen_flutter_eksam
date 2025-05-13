import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';
import 'package:absen/success_failed/gagalV1.dart';
import 'package:absen/success_failed/berhasilV1.dart';
import 'package:absen/success_failed/gagalovertime.dart';
import 'package:absen/success_failed/berhasilOvertimein.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  _ClockInPageState createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  String? Id; // Simpan ID WFH jika ada
  String? userStatus;
  String? _selectedWorkType = 'Reguler';
  String? _selectedWorkplaceType = 'WFO';
  File? _image; // To store the image file
  bool _isImageRequired = false; // Flag to indicate if image is required
  bool _isNoteRequired = false;
  bool _isHoliday = false; // Flag for holiday status
  List<String> workTypes = []; // Dynamically set work types
  List<String> workplaceTypes = [];
  Position? lastKnownPosition; // Simpan lokasi terakhir
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      getData(),
      getStatus(),
      getLocation(),
      _setWorkTypeLembur(),
      _setWorkTypesBasedOnDay(),
    ]);
  }

  void _showFakeGpsWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Peringatan!"),
          content: Text(
              "Aplikasi mendeteksi penggunaan Fake GPS. Mohon matikan dan coba lagi."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  bool _isFakeLocation(Position position) {
    // Cek apakah lokasi di-mock (hanya support di beberapa device Android)
    if (position.isMocked) {
      print("Deteksi Fake GPS dari isMocked!");
      return true;
    }

    // Cek perubahan lokasi yang tiba-tiba (lompat jauh dalam waktu singkat)
    if (lastKnownPosition != null) {
      double distance = Geolocator.distanceBetween(
        lastKnownPosition!.latitude,
        lastKnownPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      double timeDiff = position.timestamp
          .difference(lastKnownPosition!.timestamp)
          .inSeconds
          .toDouble();
      double speed =
          distance / (timeDiff > 0 ? timeDiff : 1); // Kecepatan dalam m/s

      print("Jarak berpindah: $distance meter, Kecepatan: $speed m/s");

      if (speed > 50) {
        // Kalau kecepatan lebih dari 50 m/s (180 km/jam), kemungkinan fake
        print("Deteksi Fake GPS dari kecepatan tinggi!");
        return true;
      }
    }

    return false;
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

  // Check if today is a weekend or holiday from API
  Future<void> getStatus() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/get-type-parameter');
    var request = http.MultipartRequest('GET', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (rp.statusCode == 200) {
        setState(() {
          workTypes =
              List<String>.from(data['data'].map((item) => item['name']));
        });
      } else {
        print('Error fetching history data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getLocation() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/get-location-parameter');
    var request = http.MultipartRequest('GET', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (rp.statusCode == 200) {
        setState(() {
          workplaceTypes =
              List<String>.from(data['data'].map((item) => item['name']));
        });
      } else {
        print('Error fetching history data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getData() async {
    try {
      // Ambil lokasi user sekarang
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Cek apakah menggunakan Fake GPS
      bool isFake = _isFakeLocation(position);

      if (isFake) {
        _showFakeGpsWarning();
        return; // Stop proses kalau fake GPS terdeteksi
      }

      // Simpan posisi terakhir
      lastKnownPosition = position;

      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      // Ambil data profil user dari API
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
        setState(() {
          userStatus = data['data']['user_level_id'].toString();

          // Ambil lokasi gedung dari response
          double officeLatitude = 0.0;
          double officeLongitude = 0.0;

          if (data['data']['gedung'] != null) {
            officeLatitude = double.tryParse(
                    data['data']['gedung']['latitude'].toString()) ??
                0.0;
            officeLongitude = double.tryParse(
                    data['data']['gedung']['longitude'].toString()) ??
                0.0;
          }

          // Hitung jarak user dengan gedung
          double distance = Geolocator.distanceBetween(
              userLatitude, userLongitude, officeLatitude, officeLongitude);

          print("Jarak dari gedung: $distance meter");

          if (distance > 500) {
            // Kalau lebih dari 500 meter, hanya munculkan pilihan WFA
            workplaceTypes = ['WFA'];
            _selectedWorkplaceType = 'WFA';
          } else {
            // Kalau dalam 500 meter, bisa pilih WFO atau WFA
            workplaceTypes = ['WFO', ''];
            _selectedWorkplaceType = 'WFO';
          }
        });
      } else {
        print("Error mengambil profil pengguna: ${rp.statusCode}");
      }
    } catch (e) {
      print("Error mengambil data lokasi: $e");
    }
  }

  Future<void> _setWorkTypeLembur() async {
    try {
      if (userStatus == '3') {
        setState(() {
          workTypes = ['Reguler'];
          _selectedWorkType = 'Reguler'; // User level 3 hanya bisa Reguler
        });
        return; // Stop di sini kalau user level 3
      }
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-clock-in');
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
            workTypes = ['Lembur'];
            _selectedWorkType = 'Lembur';
          } else {
            // Jika belum clock-in, munculkan opsi Reguler dan Lembur
            workTypes = ['Reguler', 'Lembur'];
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

  Future<void> _setWorkTypesBasedOnDay() async {
    if (userStatus == '3') {
      setState(() {
        workTypes = ['Reguler'];
        _selectedWorkType = 'Reguler'; // User level 3 hanya bisa Reguler
      });
      return;
    }
    // Fetch holiday data from API
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/other/cek-libur'); // Replace with your API URL

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var request = http.MultipartRequest('GET', url);
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    var response = await request.send();
    var rp = await http.Response.fromStream(response);
    var data = jsonDecode(rp.body.toString());

    print(data);
    if (response.statusCode == 200) {
      setState(() {
        _isHoliday = data['data']['libur'];
        // _isHoliday = data['data']['attendance_status_id'];
      });

      // Check if today is in the holiday list
      if (_isHoliday) {
        setState(() {
          workTypes = ['Lembur'];
          _selectedWorkType = 'Lembur';
        });
      } else {
        setState(() {
          _isHoliday = false;
          workTypes = ['Reguler', 'Lembur'];
          _selectedWorkType = 'Reguler';
        });
      }
    } else {
      // Handle API error
      print('Failed to fetch holidays: ${response.statusCode}');
      setState(() {
        workTypes = ['Reguler', 'Lembur']; // Default options
      });
    }

    // Get current day
    final int currentDay = DateTime.now().weekday;
    // Check if today is a weekend
    if (currentDay == DateTime.saturday || currentDay == DateTime.sunday) {
      setState(() {
        _isHoliday = true;
        workTypes = ['Lembur'];
        _selectedWorkType = 'Lembur';
      });
      return;
    }
  }

  Future<void> _submitDataovertimein() async {
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

    // Show loading dialog
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
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String token = localStorage.getString('token') ?? '';

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double latitude = position.latitude;
      double longitude = position.longitude;

      // Convert coordinates to address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();
      String city = place.locality ?? "Lokasi tidak tersedia";

      // Siapkan request ke API OvertimeIn
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/attendance/overtime-in');
      var request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['geolocation'] = city;
      request.fields['location'] =
          (_selectedWorkplaceType == "WFA") ? '2' : '1';
      request.fields['notes'] =
          _noteController.text; // Optional notes, pastikan _notesController ada

      // Upload foto
      request.files.add(await http.MultipartFile.fromPath(
        'foto',
        _image!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Kirim request
      var response = await request.send();
      Navigator.pop(context); // Tutup loading dialog
      if (response.statusCode == 200) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SuccessOvertime()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const FailurePageovertime()));
      }
    } catch (e) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const FailurePageovertime()));
    }
  }

  // // Function to submit data to API

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

    // Show loading dialog
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
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String token = localStorage.getString('token') ?? '';

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double latitude = position.latitude;
      double longitude = position.longitude;

      // Convert coordinates to address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      String city = place.locality ?? "Unknown City";

      // Tentukan tipe kerja dan lokasi
      String type = (_selectedWorkType == "Lembur") ? '2' : '1';
      String location = (_selectedWorkplaceType == "WFA") ? '2' : '1';

      // Siapkan request ke API clock-in
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/attendance/clock-in');
      var request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['type'] = type;
      request.fields['status'] = '1';
      request.fields['location'] = location;
      request.fields['geolocation'] = city;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      // Tambahkan foto
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          _image!.path,
          contentType: MediaType('image', 'jpg'),
        ));
      }

      // Kirim request ke API
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      print(data);

      Navigator.pop(context); // Tutup loading

      if (response.statusCode == 200) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SuccessPage()));
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
      appBar: AppBar(
        title: const Text('Clock In'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Work Type Dropdown
              const Text(
                'Jenis Pekerjaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(101, 19, 116, 1),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWorkType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: const Color.fromRGBO(101, 19, 116, 1),
                      width: 2,
                    ),
                  ),
                ),
                items: workTypes.map((String workType) {
                  return DropdownMenuItem<String>(
                    value: workType,
                    child: Text(workType),
                  );
                }).toList(),
                onChanged: !_isHoliday
                    ? (String? newValue) {
                        setState(() {
                          _selectedWorkType = newValue;
                        });
                      }
                    : null, // Disable dropdown if it's a holiday
              ),
              const SizedBox(height: 20),
              // Workplace Type Dropdown
              const Text(
                'Jenis Tempat Kerja',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(101, 19, 116, 1),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: workplaceTypes.contains(_selectedWorkplaceType)
                    ? _selectedWorkplaceType
                    : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(101, 19, 116, 1),
                      width: 2,
                    ),
                  ),
                ),
                items:
                    workplaceTypes.toSet().toList().map((String workplaceType) {
                  return DropdownMenuItem<String>(
                    value: workplaceType,
                    child: Text(workplaceType),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWorkplaceType = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Upload Photo Button with Conditional Styling
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
                            color: const Color.fromRGBO(101, 19, 116, 1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              if (_selectedWorkType == "Lembur" &&
                  (userStatus == "1" || userStatus == "2")) ...[
                const SizedBox(height: 10),
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
              ],
              const SizedBox(height: 160),
              // Submit Button
              if (_selectedWorkType == "Lembur" &&
                  (userStatus == "1" || userStatus == "2")) ...[
                Center(
                  child: ElevatedButton(
                    onPressed: _submitDataovertimein,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      iconColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 120,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Ajukan Lembur',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                )
              ] else if (_selectedWorkplaceType == "WFA" &&
                  _selectedWorkType == "Reguler" &&
                  (userStatus == "1" || userStatus == "2")) ...[
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
                      'Ajukan WFA',
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
