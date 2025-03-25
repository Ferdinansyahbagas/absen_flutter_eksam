import 'package:absen/susses&failde/berhasilV1.dart';
import 'package:absen/susses&failde/gagalV1.dart';
import 'package:absen/homepage/home.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:absen/service/api_service.dart'; // Import ApiService

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  _ClockInPageState createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  String? _selectedWorkType = 'Reguler';
  String? _selectedWorkplaceType = 'WFO';
  String? userStatus;
  String? bataswfh;
  String? Id; // Simpan ID WFH jika ada
  bool isWFARequested = false;
  File? _image; // To store the image file
  List<String> workTypes = []; // Dynamically set work types
  bool _isImageRequired = false; // Flag to indicate if image is required
  bool _isHoliday = false; // Flag for holiday status
  bool _isLoading = true; // Tambahkan state untuk loading
  final ImagePicker _picker = ImagePicker();
  List<String> workplaceTypes = [];

  // @override
  // void initState() {
  //   super.initState();
  //   _setWorkTypesBasedOnDay();
  //   _setWorkTypeLembur();
  //   getStatus();
  //   getLocation();
  //   getData();
  //   _startLoading();
  // }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _setWorkTypesBasedOnDay(),
      _setWorkTypeLembur(),
      getStatus(),
      getLocation(),
      getData(),
    ]);
    setState(() => _isLoading = false);
  }
  // Check if today is a weekend or holiday from API

  // Future<void> getStatus() async {
  //   final url = Uri.parse(
  //       'https://portal.eksam.cloud/api/v1/attendance/get-type-parameter');
  //   var request = http.MultipartRequest('GET', url);
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   request.headers['Authorization'] =
  //       'Bearer ${localStorage.getString('token')}';

  //   try {
  //     var response = await request.send();
  //     var rp = await http.Response.fromStream(response);
  //     var data = jsonDecode(rp.body.toString());

  //     if (rp.statusCode == 200) {
  //       setState(() {
  //         workTypes =
  //             List<String>.from(data['data'].map((item) => item['name']));
  //       });
  //     } else {
  //       print('Error fetching history data: ${rp.statusCode}');
  //       print(rp.body);
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  // Future<void> getData() async {
  //   try {
  //     // Ambil lokasi user
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);

  //     // *Cek apakah lokasi berasal dari fake GPS*
  //     bool isMock = position.isMocked;

  //     if (isMock) {
  //       // Jika fake GPS terdeteksi, tampilkan pesan error dan return
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Clock In gagal! Fake GPS terdeteksi.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }

  //     double userLatitude = position.latitude;
  //     double userLongitude = position.longitude;

  //     final url =
  //         Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
  //     SharedPreferences localStorage = await SharedPreferences.getInstance();
  //     var request = http.MultipartRequest('GET', url);
  //     request.headers['Authorization'] =
  //         'Bearer ${localStorage.getString('token')}';

  //     var response = await request.send();
  //     var rp = await http.Response.fromStream(response);
  //     var data = jsonDecode(rp.body.toString());

  //     if (rp.statusCode == 200) {
  //       setState(() {
  //         userStatus = data['data']['user_level_id'].toString();
  //         bataswfh = (data['data']['batas_wfh'] ?? "0").toString();

  //         double officeLatitude =
  //             double.tryParse(data['data']['latitude'].toString()) ?? 0.0;
  //         double officeLongitude =
  //             double.tryParse(data['data']['longitude'].toString()) ?? 0.0;

  //         // Hitung jarak antara user dan kantor
  //         double distance = Geolocator.distanceBetween(
  //             userLatitude, userLongitude, officeLatitude, officeLongitude);

  //         print("Jarak dari kantor: $distance meter");

  //         if (distance > 500) {
  //           // Jika lebih dari 500 meter, hanya munculkan WFH
  //           workplaceTypes = ['WFA'];
  //           _selectedWorkplaceType = 'WFA';
  //         } else {
  //           workplaceTypes = ['WFO', 'WFA'];
  //           _selectedWorkplaceType = 'WFO';
  //         }
  //       });
  //     } else {
  //       print("Error mengambil profil pengguna: ${rp.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error mengambil data lokasi: $e");
  //   }
  // }

  // Future<void> getData() async {
  //   try {
  //     // Ambil lokasi user
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     double userLatitude = position.latitude;
  //     double userLongitude = position.longitude;

  //     final url =
  //         Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
  //     SharedPreferences localStorage = await SharedPreferences.getInstance();
  //     var request = http.MultipartRequest('GET', url);
  //     request.headers['Authorization'] =
  //         'Bearer ${localStorage.getString('token')}';

  //     var response = await request.send();
  //     var rp = await http.Response.fromStream(response);
  //     var data = jsonDecode(rp.body.toString());

  //     if (rp.statusCode == 200) {
  //       setState(() {
  //         userStatus = data['data']['user_level_id'].toString();
  //         bataswfh = (data['data']['batas_wfh'] ?? "0").toString();

  //         double officeLatitude =
  //             double.tryParse(data['data']['latitude'].toString()) ?? 0.0;
  //         double officeLongitude =
  //             double.tryParse(data['data']['longitude'].toString()) ?? 0.0;

  //         // Hitung jarak antara user dan kantor
  //         double distance = Geolocator.distanceBetween(
  //             userLatitude, userLongitude, officeLatitude, officeLongitude);

  //         print("Jarak dari kantor: $distance meter");
  //         print("Lokasi User: $userLatitude, $userLongitude");
  //         print("Lokasi Kantor: $officeLatitude, $officeLongitude");
  //         print("Jarak antara User dan Kantor: $distance meter");

  //         print("Jarak dari kantor: $distance meter");
  //         print("User level: $userStatus");

  //         if (distance > 500) {
  //           // Jika lebih dari 500 meter, hanya munculkan WFH
  //           workplaceTypes = ['WFA'];
  //           _selectedWorkplaceType = 'WFA';
  //         } else {
  //           // Jika kurang dari 500 meter, munculkan semua opsi
  //           workplaceTypes
  //               // = ['WFO', 'WFH']
  //               ;
  //           _selectedWorkplaceType
  //               //  = 'WFO'
  //               ;
  //         }
  //       });
  //     } else {
  //       print("Error mengambil profil pengguna: ${rp.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error mengambil data lokasi: $e");
  //   }
  // }

  // Future<void> getLocation() async {
  //   final url = Uri.parse(
  //       'https://portal.eksam.cloud/api/v1/attendance/get-location-parameter');
  //   var request = http.MultipartRequest('GET', url);
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   request.headers['Authorization'] =
  //       'Bearer ${localStorage.getString('token')}';

  //   try {
  //     var response = await request.send();
  //     var rp = await http.Response.fromStream(response);
  //     var data = jsonDecode(rp.body.toString());

  //     if (rp.statusCode == 200) {
  //       setState(() {
  //         workplaceTypes =
  //             List<String>.from(data['data'].map((item) => item['name']));
  //       });
  //     } else {
  //       print('Error fetching history data: ${rp.statusCode}');
  //       print(rp.body);
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  // Future<void> _setWorkTypeLembur() async {
  //   try {
  //     if (userStatus == '3') {
  //       setState(() {
  //         workTypes = ['Reguler'];
  //         _selectedWorkType = 'Reguler'; // User level 3 hanya bisa Reguler
  //       });
  //       return; // Stop di sini kalau user level 3
  //     }
  //     final url =
  //         Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-clock-in');
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
  //           workTypes = ['Lembur'];
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

  // Future<void> _setWorkTypesBasedOnDay() async {
  //   if (userStatus == '3') {
  //     setState(() {
  //       workTypes = ['Reguler'];
  //       _selectedWorkType = 'Reguler'; // User level 3 hanya bisa Reguler
  //     });
  //     return; //
  //   }
  //   try {
  //     // Get current day
  //     final int currentDay = DateTime.now().weekday;
  //     // Check if today is a weekend
  //     if (currentDay == DateTime.saturday || currentDay == DateTime.sunday) {
  //       setState(() {
  //         _isHoliday = true;
  //         workTypes = ['Lembur'];
  //         _selectedWorkType = 'Lembur';
  //       });
  //       return;
  //     }

  //     // Fetch holiday data from API
  //     final url = Uri.parse(
  //         'https://portal.eksam.cloud/api/v1/other/cek-libur'); // Replace with your API URL

  //     SharedPreferences localStorage = await SharedPreferences.getInstance();

  //     var request = http.MultipartRequest('GET', url);
  //     request.headers['Authorization'] =
  //         'Bearer ${localStorage.getString('token')}';

  //     var response = await request.send();
  //     var rp = await http.Response.fromStream(response);
  //     var data = jsonDecode(rp.body.toString());

  //     print(data);
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _isHoliday = data['data']['libur'];
  //         // _isHoliday = data['data']['attendance_status_id'];
  //       });

  //       // Check if today is in the holiday list
  //       if (_isHoliday) {
  //         setState(() {
  //           workTypes = ['Lembur'];
  //           _selectedWorkType = 'Lembur';
  //         });
  //       } else {
  //         setState(() {
  //           _isHoliday = false;
  //           workTypes = ['Reguler', 'Lembur'];
  //           _selectedWorkType = 'Reguler';
  //         });
  //       }
  //     } else {
  //       // Handle API error
  //       print('Failed to fetch holidays: ${response.statusCode}');
  //       setState(() {
  //         workTypes = ['Reguler', 'Lembur']; // Default options
  //       });
  //     }
  //   } catch (e) {
  //     print('Error checking holidays: $e');
  //     setState(() {
  //       workTypes = ['Reguler', 'Lembur']; // Default options
  //     });
  //   }
  // }

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

  // // Function to submit data to API

  // Future<void> _submitData() async {
  //   if (_image == null) {
  //     setState(() {
  //       _isImageRequired = true;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please upload a photo before submitting.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   // Show loading dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return const Center(
  //         child: CircularProgressIndicator(
  //           color: Color.fromARGB(255, 101, 19, 116),
  //         ),
  //       );
  //     },
  //   );

  //   try {
  //     SharedPreferences localStorage = await SharedPreferences.getInstance();
  //     String token = localStorage.getString('token') ?? '';

  //     // Get current location
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);

  //     double latitude = position.latitude;
  //     double longitude = position.longitude;

  //     // *Cek apakah lokasi berasal dari fake GPS*
  //     bool isMock = position.isMocked;

  //     if (isMock) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Clock In gagal! Fake GPS terdeteksi.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }

  //     // Convert coordinates to address
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude);
  //     Placemark place = placemarks[0];

  //     String city = place.locality ?? "Unknown City";

  //     // Tentukan tipe kerja dan lokasi
  //     String type = (_selectedWorkType == "Lembur") ? '2' : '1';
  //     String location = (_selectedWorkplaceType == "WFH") ? '2' : '1';

  //     // Siapkan request ke API clock-in
  //     final url =
  //         Uri.parse('https://portal.eksam.cloud/api/v1/attendance/clock-in');
  //     var request = http.MultipartRequest('POST', url);

  //     request.headers['Authorization'] = 'Bearer $token';
  //     request.fields['type'] = type;
  //     request.fields['status'] = '1';
  //     request.fields['location'] = location;
  //     request.fields['geolocation'] = city;
  //     request.fields['latitude'] = latitude.toString();
  //     request.fields['longitude'] = longitude.toString();

  //     // Tambahkan foto
  //     if (_image != null) {
  //       request.files.add(await http.MultipartFile.fromPath(
  //         'foto',
  //         _image!.path,
  //         contentType: MediaType('image', 'jpg'),
  //       ));
  //     }

  //     // Kirim request ke API
  //     var response = await request.send();
  //     var rp = await http.Response.fromStream(response);
  //     var data = jsonDecode(rp.body.toString());

  //     print(data);

  //     Navigator.pop(context); // Tutup loading

  //   if (response.statusCode == 200) {
  //       Navigator.pushReplacement(context,
  //           MaterialPageRoute(builder: (context) => const SuccessPage()));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to submit: ${data['message']}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       Navigator.pushReplacement(context,
  //           MaterialPageRoute(builder: (context) => const FailurePage()));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('An error occurred: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     Navigator.pushReplacement(context,
  //         MaterialPageRoute(builder: (context) => const FailurePage()));
  //   }
  // }

  Future<void> getcekwfa() async {
    var data =
        await ApiService.sendRequest(endpoint: 'request-history/is-wfa-today');
    if (data != null && data['message'] == 'User sudah mengajukan WFA') {
      setState(() {
        isWFARequested = true;
        Id = data['data']['id'].toString();
      });
    } else {
      setState(() {
        isWFARequested = false;
        Id = null;
      });
    }
  }

  Future<void> getStatus() async {
    var response =
        await ApiService.sendRequest(endpoint: 'attendance/get-type-parameter');
    if (response != null) {
      setState(() {
        workTypes =
            List<String>.from(response['data'].map((item) => item['name']));
      });
    }
  }

  Future<void> getLocation() async {
    var response = await ApiService.sendRequest(
        endpoint: 'attendance/get-location-parameter');
    if (response != null) {
      setState(() {
        workplaceTypes =
            List<String>.from(response['data'].map((item) => item['name']));
      });
    }
  }

  Future<void> _setWorkTypeLembur() async {
    if (userStatus == '3') {
      setState(() {
        workTypes = ['Reguler'];
        _selectedWorkType = 'Reguler';
      });
      return;
    }

    var response =
        await ApiService.sendRequest(endpoint: 'attendance/is-clock-in');
    if (response != null) {
      bool hasClockedIn = response['message'] != 'belum clock-in';
      setState(() {
        workTypes = hasClockedIn ? ['Lembur'] : ['Reguler', 'Lembur'];
        _selectedWorkType = workTypes.first;
      });
    }
  }

  Future<void> _setWorkTypesBasedOnDay() async {
    if (userStatus == '3') {
      setState(() {
        workTypes = ['Reguler'];
        _selectedWorkType = 'Reguler';
      });
      return;
    }

    final int currentDay = DateTime.now().weekday;
    if (currentDay == DateTime.saturday || currentDay == DateTime.sunday) {
      setState(() {
        _isHoliday = true;
        workTypes = ['Lembur'];
        _selectedWorkType = 'Lembur';
      });
      return;
    }

    var response = await ApiService.sendRequest(endpoint: 'other/cek-libur');
    if (response != null) {
      setState(() {
        _isHoliday = response['data']['libur'];
        workTypes = _isHoliday ? ['Lembur'] : ['Reguler', 'Lembur'];
        _selectedWorkType = workTypes.first;
      });
    }
  }

  Future<void> getData() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position.isMocked) {
      _showSnackbar('Clock In gagal! Fake GPS terdeteksi.', Colors.red);
      return;
    }

    var response =
        await ApiService.sendRequest(endpoint: 'karyawan/get-profile');
    if (response != null) {
      setState(() {
        userStatus = response['data']['user_level_id'].toString();
        bataswfh = (response['data']['batas_wfh'] ?? "0").toString();
        Id = response['data']['id'].toString(); // ID WFH

        double officeLatitude =
            double.tryParse(response['data']['latitude'].toString()) ?? 0.0;
        double officeLongitude =
            double.tryParse(response['data']['longitude'].toString()) ?? 0.0;

        double distance = Geolocator.distanceBetween(position.latitude,
            position.longitude, officeLatitude, officeLongitude);

        workplaceTypes = (distance > 500) ? ['WFA'] : ['WFO', 'WFA'];
        _selectedWorkplaceType = workplaceTypes.first;
      });
    }
  }

  Future<void> _submitData() async {
    if (_image == null) {
      _setImageRequiredError();
      return;
    }

    _showLoadingDialog();

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (position.isMocked) {
        _dismissLoadingDialog();
        _showSnackbar('Clock In gagal! Fake GPS terdeteksi.', Colors.red);
        return;
      }

      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}attendance/clock-in'))
        ..headers['Authorization'] = 'Bearer ${await _getToken()}'
        ..fields['type'] = (_selectedWorkType == "Lembur") ? '2' : '1'
        ..fields['status'] = '1'
        ..fields['location'] = (_selectedWorkplaceType == "WFA") ? '2' : '1'
        ..fields['geolocation'] = "Unknown City"
        ..fields['latitude'] = position.latitude.toString()
        ..fields['longitude'] = position.longitude.toString()
        ..files.add(await http.MultipartFile.fromPath('foto', _image!.path,
            contentType: MediaType('image', 'jpg')));

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var data = jsonDecode(responseData.body);

      _dismissLoadingDialog();
      if (response.statusCode == 200) {
        _navigateTo(const SuccessPage());
      } else {
        _showSnackbar('Gagal: ${data['message']}', Colors.red);
        _navigateTo(const FailurePage());
      }
    } catch (e) {
      _dismissLoadingDialog();
      _showSnackbar('Terjadi kesalahan: $e', Colors.red);
      _navigateTo(const FailurePage());
    }
  }

  Future<String> _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getString('token') ?? '';
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(
              color: Color.fromARGB(255, 101, 19, 116))),
    );
  }

  void _dismissLoadingDialog() {
    if (mounted) Navigator.pop(context);
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  void _setImageRequiredError() {
    setState(() => _isImageRequired = true);
    _showSnackbar('Harap unggah foto sebelum submit.', Colors.red);
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
                value: _selectedWorkplaceType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: const Color.fromRGBO(
                          101, 19, 116, 1), // Customize border color
                      width: 2, // Customize border width
                    ),
                  ),
                ),
                items: workplaceTypes.map((String workplaceType) {
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
              // if (_selectedWorkplaceType == "WFH" &&
              //     _selectedWorkType == "Reguler" &&
              //     (userStatus == "1" || userStatus == "2")) ...[
              //   Text(
              //     "Sisa WFH Anda: ${bataswfh ?? '0'} hari",
              //     style: const TextStyle(
              //       fontSize: 14,
              //       fontWeight: FontWeight.w500,
              //       color: Colors.red,
              //     ),
              //   ),
              //   const SizedBox(height: 10),
              // ],
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
              const SizedBox(height: 160),
              // Submit Button
              if (_selectedWorkplaceType == "WFA" &&
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
