// import 'package:flutter/material.dart';
// import 'TimeoffScreen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:absen/susses&failde/berhasilV2I.dart';
// import 'package:absen/susses&failde/gagalV2I.dart';
// import 'package:absen/susses&failde/alreadyRequestedPage.dart'; // Halaman "Sudah Request"

// class TimeOff extends StatefulWidget {
//   @override
//   _TimeOffState createState() => _TimeOffState();
// }

// class _TimeOffState extends State<TimeOff> {
//   String formattedDate = '';
//   String? _selectedType = 'Cuti';
//   String Reason = '';
//   String? iduser;
//   String? limit;
//   String? type = '1';
//   DateTime? _selectedStartDate;
//   DateTime? _selectedEndDate;
//   List<String> _typeOptions = [];
//   bool hasRequested = false; // Tambahkan variabel ini

//   final _reasonController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     getProfile();
//     getData();
//     checkRequestStatus(); // Periksa status request saat inisialisasi
//   }

//   Future<void> checkRequestStatus() async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     setState(() {
//       hasRequested = localStorage.getBool('hasRequested') ?? false;
//     });
//   }

//   Future<void> _submitData() async {
//     if (hasRequested) {
//       // Jika sudah request, arahkan ke halaman "Sudah Request"
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => AlreadyRequestedPage()),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       barrierDismissible: false, // Prevent dismissing the dialog
//       builder: (BuildContext context) {
//         // return Center(
//           child: CircularProgressIndicator(
//             color: const Color.fromARGB(255, 101, 19, 116),
//           ),
//         );
//       },
//     );
//     try {
//       await getProfile();
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/request-history/make-request');

//       var request = http.MultipartRequest('POST', url);
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       String formattedStartDate = _selectedStartDate != null
//           ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
//           : '';
//       String formattedEndDate = _selectedEndDate != null
//           ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
//           : '';

//       if (_selectedType == "Izin") {
//         setState(() {
//           type = '3';
//         });
//       } else if (_selectedType == "Sakit") {
//         setState(() {
//           type = '2';
//         });
//       } else {
//         setState(() {
//           type = '1';
//         });
//       }

//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';
//       request.fields['user_id'] = iduser.toString();
//       request.fields['notes'] = Reason.toString();
//       request.fields['startdate'] = formattedStartDate;
//       request.fields['enddate'] = formattedEndDate;
//       request.fields['type'] = type.toString();

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       print(rp.body.toString());
//       var data = jsonDecode(rp.body.toString());
//       print(data);

//       if (response.statusCode == 200) {
//         // Simpan status "sudah request"
//         localStorage.setBool('hasRequested', true);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SuccessPage2I()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => FailurePage2I()),
//         );
//       }
//     } catch (e) {
//       print(e);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => FailurePage2I()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => TimeOffScreen()),
//             );
//           },
//         ),
//         title: Text(
//           'Time Off',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 30,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         // Body...
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }
// }                                                    


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    