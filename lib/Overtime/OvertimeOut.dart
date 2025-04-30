// import 'package:flutter/material.dart';
// import 'package:absen/homepage/home.dart';
// import 'package:absen/susses&failde/gagalV1.dart';
// import 'package:absen/susses&failde/berhasilV1II.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ClockOutScreen extends StatefulWidget {
//   const ClockOutScreen({super.key});

//   @override
//   _ClockOutScreenState createState() => _ClockOutScreenState();
// }

// class _ClockOutScreenState extends State<ClockOutScreen> {
//   String note = '';
//   String? _selectedWorkType;
//   String? _selectedWorkplaceType;
//   String? userStatus; // Tambahan untuk menyimpan user level
//   File? _image;
//   bool _isNoteRequired = false;
//   bool _isImageRequired = false;
//   bool isWithinRange = true; // Default true agar tidak menghalangi WFH
//   bool panding = false; // Status clock-in biasa
//   bool approve = false;
//   bool reject = false;
//   List<String> WorkTypes = [];
//   List<String> WorkplaceTypes = [];
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _noteController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadSelectedValues();
//     getData();
//     getProfil();
//   }

//   Future<void> _loadSelectedValues() async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     bool isClockInDone = localStorage.getBool('clockInDone') ?? false;
//     if (isClockInDone) {
//       setState(() {
//         _selectedWorkType = localStorage.getString('workType');
//         _selectedWorkplaceType = localStorage.getString('workplaceType');
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _isImageRequired = false;
//       });
//     }
//   }

//   Future<void> getProfil() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       double userLatitude = position.latitude;
//       double userLongitude = position.longitude;

//       final url =
//           Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (rp.statusCode == 200) {
//         double officeLatitude =
//             double.tryParse(data['data']['latitude'].toString()) ?? 0.0;
//         double officeLongitude =
//             double.tryParse(data['data']['longitude'].toString()) ?? 0.0;

//         // Hitung jarak antara user dan kantor
//         double distance = Geolocator.distanceBetween(
//             userLatitude, userLongitude, officeLatitude, officeLongitude);

//         print("Jarak dari kantor: $distance meter");
//       } else {
//         print("Error mengambil profil pengguna: ${rp.statusCode}");
//       }
//     } catch (e) {
//       print("Error mengambil data lokasi: $e");
//     }
//   }

//   Future<void> getData() async {
//     final url = Uri.parse(
//         'https://portal.eksam.cloud/api/v1/attendance/get-self-detail-today');
//     var request = http.MultipartRequest('GET', url);
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';

//     try {
//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);

//       if (rp.statusCode == 200) {
//         var data = jsonDecode(rp.body.toString());
//         print(data);
//         setState(() {
//           _selectedWorkType = data['data']['type']['name'];
//           _selectedWorkplaceType = data['data']['location']['name'];
//         });

//         // Jika user memilih WFO, lakukan validasi jarak
//       } else {
//         print('Error fetching history data: ${rp.statusCode}');
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   Future<void> getDataOvertime() async {
//     final url = Uri.parse(
//         'https://portal.eksam.cloud/api/v1/attendance/cek-approval-lembur');
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     final token = localStorage.getString('token');

//     try {
//       var response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         setState(() {
//           panding = data['message'] != 'Pengajuan lembur masih pending';
//           reject = data['message'] != 'Pengajuan lembur ditolak';
//           approve = data['message'] != 'Pengajuan lembur sudah di-approve';
//         });
//       } else {
//         print('Error fetching overtime data: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   Future<void> _submitDataovertimeout() async {
//     if (_noteController.text.isEmpty) {
//       setState(() {
//         _isNoteRequired = true;
//       });
//       return;
//     }

//     if (_image == null) {
//       setState(() {
//         _isImageRequired = true;
//       });
//       return;
//     }

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const Center(
//           child: CircularProgressIndicator(
//             color: Color.fromARGB(255, 101, 19, 116),
//           ),
//         );
//       },
//     );

//     try {
//       final url = Uri.parse(
//           'https://portal.eksam.cloud/api/v1//attendance/overtime-out-new');
//       var request = http.MultipartRequest('POST', url);
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       // Tambahkan Authorization Bearer Token
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';
//       request.fields['notes'] = _noteController.text;
//       request.files.add(await http.MultipartFile.fromPath(
//         'foto',
//         _image!.path,
//         contentType: MediaType('image', 'jpg'),
//       ));

//       var response = await request.send();
//       Navigator.pop(context); // Tutup dialog loading

//       if (response.statusCode == 200) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SuccessPageII()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const FailurePage()),
//         );
//       }
//     } catch (e) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const FailurePage()),
//       );
//     }
//   }

//   Future<void> _submitDataovertimeapprove() async {
//     if (_noteController.text.isEmpty) {
//       setState(() {
//         _isNoteRequired = true;
//       });
//       return;
//     }

//     if (_image == null) {
//       setState(() {
//         _isImageRequired = true;
//       });
//       return;
//     }

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const Center(
//           child: CircularProgressIndicator(
//             color: Color.fromARGB(255, 101, 19, 116),
//           ),
//         );
//       },
//     );

//     try {
//       final url = Uri.parse(
//           'https://portal.eksam.cloud/api/v1/attendance/overtime-out-approved');
//       var request = http.MultipartRequest('POST', url);
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       String? token = localStorage.getString('token');

//       request.headers['Authorization'] = 'Bearer $token';
//       request.fields['notes'] = _noteController.text;
//       request.files.add(await http.MultipartFile.fromPath(
//         'foto',
//         _image!.path,
//         contentType:
//             MediaType('image', 'jpeg'), // Pastikan sesuai format yang dikirim
//       ));

//       var response = await request.send();
//       Navigator.pop(context); // Tutup loading

//       if (response.statusCode == 200) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SuccessPageII()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const FailurePage()),
//         );
//       }
//     } catch (e) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const FailurePage()),
//       );
//     }
//   }

//   Future<void> _submitData() async {
//     if (_noteController.text.isEmpty) {
//       setState(() {
//         _isNoteRequired = true;
//       });
//       return;
//     }

//     if (_image == null) {
//       setState(() {
//         _isImageRequired = true;
//       });
//       return;
//     }

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const Center(
//           child: CircularProgressIndicator(
//             color: Color.fromARGB(255, 101, 19, 116),
//           ),
//         );
//       },
//     );

//     try {
//       final url =
//           Uri.parse('https://portal.eksam.cloud/api/v1/attendance/clock-out');
//       var request = http.MultipartRequest('POST', url);
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       request.fields['notes'] = _noteController.text;

//       if (_image != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'foto',
//           _image!.path,
//           contentType: MediaType('image', 'jpg'),
//         ));
//       }

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => const SuccessPageII()));
//       } else {
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => const FailurePage()));
//       }
//     } catch (e) {
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => const FailurePage()));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 120),
//                 if (_selectedWorkType == "Lembur" &&
//                 (userStatus == "1" || userStatus == "2")) ...[
//               if (panding || reject)
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _submitDataovertimeout,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       iconColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 120,
//                         vertical: 15,
//                       ),
//                     ),
//                     child: const Text(
//                       'Submit Overtime Out',
//                       style: TextStyle(fontSize: 15, color: Colors.white),
//                     ),
//                   ),
//                 )
//               else if (approve)
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _submitDataovertimeapprove,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       iconColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 120,
//                         vertical: 15,
//                       ),
//                     ),
//                     child: const Text(
//                       'Submit Overtime Approved',
//                       style: TextStyle(fontSize: 15, color: Colors.white),
//                     ),
//                   ),
//                 )
//             ] else if (userStatus == "1" ||
//                 userStatus == "2" ||
//                 userStatus == "3") ...[
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _submitData,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     iconColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 120,
//                       vertical: 15,
//                     ),
//                   ),
//                   child: const Text(
//                     'Submit',
//                     style: TextStyle(fontSize: 15, color: Colors.white),
//                   ),
//                 ),
//               )
//             ],
//           ],
//         ),
//       ),
//     ),
//   );
// }
// }
