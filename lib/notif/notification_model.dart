// import 'dart:convert';
// import 'dart:io';
// import 'package:absen/homepage/home.dart';
// import 'package:absen/susses&failde/berhasilV1.dart';
// import 'package:absen/susses&failde/gagalV1.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http_parser/http_parser.dart';

// class ClockInPage extends StatefulWidget {
//   const ClockInPage({super.key});

//   @override
//   _ClockInPageState createState() => _ClockInPageState();
// }

// class _ClockInPageState extends State<ClockInPage> {
//   String? _selectedWorkType = 'Reguler';
//   String? _selectedWorkplaceType = 'WFO';
//   File? _image;
//   List<String> workTypes = [];
//   bool _isImageRequired = false;
//   final ImagePicker _picker = ImagePicker();
//   double officeLatitude = 0.0;
//   double officeLongitude = 0.0;
//   final double allowedRadius = 100.0; // 100 meter

//   @override
//   void initState() {
//     super.initState();
//     fetchOfficeLocation();
//   }

//   Future<void> fetchOfficeLocation() async {
//     try {
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/attendance/get-location');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (response.statusCode == 200) {
//         setState(() {
//           officeLatitude = data['data']['latitude'];
//           officeLongitude = data['data']['longitude'];
//         });
//       } else {
//         print('Error fetching office location: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching office location: $e');
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

//   Future<void> _submitData() async {
//     if (_image == null) {
//       setState(() {
//         _isImageRequired = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please upload a photo before submitting.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     double userLatitude = position.latitude;
//     double userLongitude = position.longitude;

//     double distance = Geolocator.distanceBetween(
//         userLatitude, userLongitude, officeLatitude, officeLongitude);

//     if (distance > allowedRadius) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Anda berada di luar radius kantor. Clock-in gagal.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );

//     try {
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/attendance/clock-in');
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       var request = http.MultipartRequest('POST', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';
//       request.fields['type'] = _selectedWorkType == "Lembur" ? '2' : '1';
//       request.fields['location'] = _selectedWorkplaceType == "WFH" ? '2' : '1';
//       request.fields['geolocation'] = '$userLatitude, $userLongitude';

//       if (_image != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'foto',
//           _image!.path,
//           contentType: MediaType('image', 'jpg'),
//         ));
//       }

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       Navigator.pop(context);
//       if (data['status'] == 'success') {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SuccessPage()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => FailurePage()),
//         );
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => FailurePage()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Clock In'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const HomePage()),
//             );
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: ElevatedButton(
//                 onPressed: _submitData,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//                 child: const Text(
//                   'Submit',
//                   style: TextStyle(fontSize: 15, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
