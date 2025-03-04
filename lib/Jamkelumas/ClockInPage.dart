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
  bool isWFHRequested = false;
  String? wfhId; // Simpan ID WFH jika ada
  File? _image; // To store the image file
  List<String> workTypes = []; // Dynamically set work types
  bool _isImageRequired = false; // Flag to indicate if image is required
  bool _isHoliday = false; // Flag for holiday status
  bool _isLoading = true; // Tambahkan state untuk loading
  final ImagePicker _picker = ImagePicker();
  List<String> workplaceTypes = [];

  @override
  void initState() {
    super.initState();
    // _setWorkTypesBasedOnDay();
    _setWorkTypeLembur();
    getStatus();
    getLocation();
    getData();
    getcancelwfh();
    getcekwfh();
    loadWFHStatus(); // Ambil status WFH saat halaman dimuat
  }

  // Simpan status WFH ke SharedPreferences
  Future<void> saveWFHStatus(bool status, String? id) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    await localStorage.setBool('isWFHRequested', status);
    await localStorage.setString('wfhId', id ?? '');
  }

  // Ambil status WFH dari SharedPreferences
  Future<void> loadWFHStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      isWFHRequested = localStorage.getBool('isWFHRequested') ?? false;
      wfhId = localStorage.getString('wfhId');
    });
  }

  Future<void> _startLoading() async {
    await Future.delayed(const Duration(seconds: 2)); // Delay selama 2 detik
    setState(() {
      _isLoading = false; // Setelah delay, hilangkan loading
    });
  }

  // Check if today is a weekend or holiday from API

  Future<void> getStatus() async {
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/attendance/get-type');
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

  // Future<void> getcekwfh() async {
  //   final url =
  //       Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-wfh');
  //   var request = http.MultipartRequest('GET', url);
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   request.headers['Authorization'] =
  //       'Bearer ${localStorage.getString('token')}';

  //   try {
  //     var response = await request.send();
  //     var rp = await http.Response.fromStream(response);
  //     var data = jsonDecode(rp.body.toString());

  //     if (rp.statusCode == 200) {
  //       setState(() {});
  //     } else {
  //       print('Error fetching history data: ${rp.statusCode}');
  //       print(rp.body);
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  Future getcekwfh() async {
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-wfh');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var headers = {
      'Authorization': 'Bearer ${localStorage.getString('token')}'
    };

    try {
      var response = await http.get(url, headers: headers);
      var data = jsonDecode(response.body.toString());
      print("Response API is-wfh: $data");
      if (response.statusCode == 200) {
        setState(() {
          isWFHRequested = true;
          wfhId =
              data['data']['id'].toString(); // Simpan ID WFH untuk pembatalan
        });
        await saveWFHStatus(true, wfhId); // untuk menyimpan pwngajuan wfh
      } else {
        setState(() {
          isWFHRequested = false;
          wfhId = null;
        });
        await saveWFHStatus(false, null); // untuk menyimpan pwngajuan wfh
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getcancelwfh() async {
    if (wfhId == null) return; // Pastikan ada ID WFH

    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/cancel-wfh/$wfhId');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var headers = {
      'Authorization': 'Bearer ${localStorage.getString('token')}'
    };

    try {
      var response = await http.delete(url, headers: headers);
      var data = jsonDecode(response.body.toString());
      print("Response API cancel-wfh: $data");
      if (response.statusCode == 200) {
        setState(() {
          isWFHRequested = false;
          wfhId = null;
        });
        await saveWFHStatus(false, null); // untuk menyimpan pwngajuan wfh

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('WFH berhasil dibatalkan'),
              backgroundColor: Colors.green),
        );
      } else {
        print('Gagal membatalkan WFH: ${data['message']}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getData() async {
    try {
      // Ambil lokasi user
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
        setState(() {
          userStatus = data['data']['user_level_id'].toString();
          bataswfh = (data['data']['batas_wfh'] ?? "0").toString();
          wfhId =
              data['data']['id'].toString(); // Simpan ID WFH untuk pembatalan

          double officeLatitude =
              double.tryParse(data['data']['latitude'].toString()) ?? 0.0;
          double officeLongitude =
              double.tryParse(data['data']['longitude'].toString()) ?? 0.0;

          // _compareDistance(officeLongitude, officeLatitude);

          // Hitung jarak antara user dan kantor
          double distance = Geolocator.distanceBetween(
              userLatitude, userLongitude, officeLatitude, officeLongitude);

          print("Jarak dari kantor: $distance meter");
          print("Lokasi User: $userLatitude, $userLongitude");
          print("Lokasi Kantor: $officeLatitude, $officeLongitude");
          print("Jarak antara User dan Kantor: $distance meter");

          print("Jarak dari kantor: $distance meter");
          print("User level: $userStatus");

          if (distance > 500) {
            // Jika lebih dari 500 meter, hanya munculkan WFH
            workplaceTypes = ['WFH'];
            _selectedWorkplaceType = 'WFH';
          } else {
            // Jika kurang dari 500 meter, munculkan semua opsi
            workplaceTypes
                // = ['WFO', 'WFH']
                ;
            _selectedWorkplaceType
                //  = 'WFO'
                ;
          }
        });
      } else {
        print("Error mengambil profil pengguna: ${rp.statusCode}");
      }
    } catch (e) {
      print("Error mengambil data lokasi: $e");
    }
  }

  Future<void> getLocation() async {
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/attendance/get-location');
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
          }
          // } else {
          //   // Jika belum clock-in, munculkan opsi Reguler dan Lembur
          //   workTypes = ['Reguler', 'Lembur'];
          //   _selectedWorkType = 'Reguler';
          // }
        });
      } else {
        print("Error mengecek status clock-in: ${response.statusCode}");
      }
    } catch (e) {
      print("Error mengecek status clock-in: $e");
    }
  }

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

  // Function to submit data to API
  // Future<void> _submitData() async {
  //   if (_image == null) {
  //     // Show error if no image is uploaded
  //     setState(() {
  //       _isImageRequired = true;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please upload a photo before submitting.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return; // Stop submission if no image
  //   }
  //   // Show loading dialog
  //   // showDialog(
  //   //   context: context,
  //   //   barrierDismissible: false, // Prevent dismissing the dialog
  //   //   builder: (BuildContext context) {
  //   //     return Center(
  //   //       child: CircularProgressIndicator(
  //   //         color: const Color.fromARGB(255, 101, 19, 116),
  //   //       ),
  //   //     );
  //   //   },
  //   // );

  //   if (_selectedWorkType == "Reguler" &&
  //       _selectedWorkplaceType == "WFH" &&
  //       (userStatus == "1" || userStatus == "2")) {
  //     // Jika user memilih Reguler WFH, buat pengajuan dulu
  //     SharedPreferences localStorage = await SharedPreferences.getInstance();
  //     localStorage.setBool(
  //         'isWFHRequested', true); // Tandai bahwa user sudah mengajukan WFH
  //     // SharedPreferences localStorage = await SharedPreferences.getInstance();
  //     // await saveWFHStatus(true, wfhId); // untuk menyimpan pwngajuan wfh

  //     setState(() {
  //       isWFHRequested = true;
  //     });

  //     // Munculkan pesan sukses

  //     await Future.delayed(Duration(seconds: 3)); // Simulasi loading sebentar
  //     Navigator.pop(context); // Tutup loading

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Pengajuan WFH berhasil dikirim!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } else {
  //     // Show loading dialog (loading tetap sampai respons API selesai)
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false, // Prevent dismissing the dialog
  //       builder: (BuildContext context) {
  //         return Center(
  //           child: CircularProgressIndicator(
  //             color: const Color.fromARGB(255, 101, 19, 116),
  //           ),
  //         );
  //       },
  //     );

  //     try {
  //       // Get current location
  //       Position position = await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.high);

  //       double latitude = position.latitude;
  //       double longitude = position.longitude;

  //       // Convert coordinates to address
  //       List<Placemark> placemarks =
  //           await placemarkFromCoordinates(latitude, longitude);
  //       Placemark place = placemarks[0]; // Get the first placemark

  //       String city = place.locality ??
  //           "Unknown City"; // If city not available, default to Unknown City

  //       // Example API endpoint
  //       final url =
  //           Uri.parse('https://portal.eksam.cloud/api/v1/attendance/clock-in');

  //       // Prepare multipart request to send image and data
  //       var request = http.MultipartRequest('POST', url);

  //       // Save selected work type and workplace type to SharedPreferences
  //       SharedPreferences localStorage = await SharedPreferences.getInstance();
  //       await localStorage.setString('workType', _selectedWorkType!);
  //       await localStorage.setString('workplaceType', _selectedWorkplaceType!);

  //       request.headers['Authorization'] =
  //           'Bearer ${localStorage.getString('token')}';
  //       String type = '1';
  //       String location = '1';
  //       if (_selectedWorkType == "Lembur") {
  //         type = '2';
  //       } else {
  //         type = '1';
  //       }
  //       if (_selectedWorkplaceType == "WFH") {
  //         location = '2';
  //       } else {
  //         location = '1';
  //       }
  //       request.fields['type'] = type;
  //       request.fields['status'] = '1';
  //       request.fields['location'] = location;
  //       request.fields['geolocation'] = city.toString(); // Send city name
  //       // request.fields['latitude'] = city.toString();
  //       // request.fields['longitude'] = city.toString();

  //       // Add image file
  //       if (_image != null) {
  //         request.files.add(await http.MultipartFile.fromPath(
  //           'foto', // Field name for image in the API
  //           _image!.path,
  //           contentType: MediaType('image', 'jpg'), // Set content type
  //         ));
  //       }

  //       // Send the request and get the response
  //       var response = await request.send();
  //       var rp = await http.Response.fromStream(response);
  //       var data = jsonDecode(rp.body.toString());
  //       print(data);
  //       var status = data['status'];
  //       if (status == 'success') {
  //         // Successfully submitted
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => SuccessPage()),
  //         );
  //       } else {
  //         // Submission failed
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => FailurePage()),
  //         );
  //       }
  //     } catch (e) {
  //       // Handle error and navigate to failure page
  //       print("Error: $e");
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => FailurePage()),
  //       );
  //     }
  //   }
  // }

  // Future<void> _submitData() async {
  //   if (_image == null) {
  //     // Show error if no image is uploaded
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

  //     // Convert coordinates to address
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude);
  //     Placemark place = placemarks[0];

  //     String city = place.locality ?? "Unknown City";

  //     // Tentukan tipe kerja dan lokasi
  //     String type = (_selectedWorkType == "Lembur") ? '2' : '1';
  //     String location = (_selectedWorkplaceType == "WFH") ? '2' : '1';
  //     bool isWFHRequest = (_selectedWorkType == "Reguler" &&
  //         _selectedWorkplaceType == "WFH" &&
  //         (userStatus == "1" || userStatus == "2"));

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

  //     // Jika WFH, tambahkan parameter is_wfh
  //     if (isWFHRequest) {
  //       request.fields['is_wfh'] = '1';
  //     }

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
  //     var status = data['status'];

  //     if (status == 'success') {
  //       // Jika pengajuan WFH berhasil, tandai di local storage
  //       if (isWFHRequest) {
  //         localStorage.setBool('isWFHRequested', true);
  //       }

  //       Navigator.pop(context); // Tutup loading
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Pengajuan berhasil dikirim!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => SuccessPage()),
  //       );
  //     } else {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Gagal mengajukan!'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => FailurePage()),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     Navigator.pop(context);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Terjadi kesalahan, coba lagi!'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => FailurePage()),
  //     );
  //   }
  // }

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
      String location = (_selectedWorkplaceType == "WFH") ? '2' : '1';
      bool isWFHRequest = (_selectedWorkType == "Reguler" &&
          _selectedWorkplaceType == "WFH" &&
          (userStatus == "1" || userStatus == "2"));

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

      // Jika WFH, tambahkan parameter is_wfh
      if (isWFHRequest) {
        request.fields['is_wfh'] = '1';
      }

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
        // Jika pengajuan WFH berhasil, tandai di local storage dan arahkan ke HomePage
        if (isWFHRequest) {
          localStorage.setBool('isWFHRequested', true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengajuan WFH berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        } else {
          // Jika Clock In biasa, arahkan ke SuccessPage
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clock In berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuccessPage()),
          );
        }
      } else {
        // Jika gagal,
        print("Pengajuan gagal, response API: ${data.toString()}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FailurePage()),
        );
      }
    } catch (e) {
      print("Error: $e");
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FailurePage()),
      );
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

              // Tampilkan batas WFH jika user memilih WFH
              // if (_selectedWorkplaceType == "WFH") ...[
              //   Text(
              //     "Sisa WFH Anda: $bataswfh hari",
              //     style: const TextStyle(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w500,
              //         color: Colors.red),
              //   ),
              //   const SizedBox(height: 10),
              // ],
              if (_selectedWorkplaceType == "WFH" &&
                  _selectedWorkType == "Reguler" &&
                  (userStatus == "1" || userStatus == "2")) ...[
                Text(
                  "Sisa WFH Anda: ${bataswfh ?? '0'} hari",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
              ],
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
              // Center(
              //   child:
              //   ElevatedButton(
              //     onPressed: _submitData, // Call the function to submit data
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.orange,
              //       iconColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 120,
              //         vertical: 15,
              //       ),
              //     ),
              //     child: const Text(
              //       'Submit',
              //       style: TextStyle(fontSize: 15, color: Colors.white),
              //     ),
              //   ),
              // ),
              // Column(
              //   children: [
              //     ElevatedButton(
              //       onPressed: isWFHRequested
              //           ? null
              //           : _submitData, // Disabled jika WFH pending
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor:
              //             isWFHRequested ? Colors.grey : Colors.orange,
              //       ),
              //       child: const Text('Clock In',
              //           style: TextStyle(color: Colors.white)),
              //     ),
              //     if (isWFHRequested)
              //       ElevatedButton(
              //         onPressed: getcancelwfh, // Batalkan WFH
              //         style:
              //             ElevatedButton.styleFrom(backgroundColor: Colors.red),
              //         child: const Text('Batalkan WFH',
              //             style: TextStyle(color: Colors.white)),
              //       ),
              //   ],
              // )

              // if (isWFHRequested &&
              //     (userStatus == "1" || userStatus == "2")) ...[
              //   ElevatedButton(
              //     onPressed: null, // Tombol Pending selalu disabled
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.grey,
              //       iconColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 120,
              //         vertical: 15,
              //       ),
              //     ),
              //     child: const Text(
              //       'Pading',
              //       style: TextStyle(fontSize: 15, color: Colors.white),
              //     ),
              //   ),
              //   SizedBox(height: 10),
              //   ElevatedButton(
              //     onPressed: getcancelwfh,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.red,
              //       iconColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 120,
              //         vertical: 15,
              //       ),
              //     ),
              //     child: const Text(
              //       'Batalkan WFH',
              //       style: TextStyle(fontSize: 15, color: Colors.white),
              //     ),
              //   ),
              // ] else ...[

              if (_selectedWorkplaceType == "WFH" &&
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
                      'Ajukan WFH',
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
                // ] else if (userStatus == "3") ...[
                //   Center(
                //     child: ElevatedButton(
                //       onPressed: _submitData,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.orange,
                //         iconColor: Colors.white,
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 120,
                //           vertical: 15,
                //         ),
                //       ),
                //       child: const Text(
                //         'Submit',
                //         style: TextStyle(fontSize: 15, color: Colors.white),
                //       ),
                //     ),
                //   )
              ],

              //   ]
              // ])
            ],
          ),
        ),
      ),
    );
  }
}
