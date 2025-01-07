// import 'package:flutter/material.dart';
// import 'TimeoffScreen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:absen/susses&failde/berhasilV2I.dart';
// import 'package:absen/susses&failde/gagalV2I.dart';

// class TimeOff extends StatefulWidget {
//   @override
//   _TimeOffState createState() => _TimeOffState();
// }

// class _TimeOffState extends State<TimeOff> {
//   String formatStarttedDate = '';
//   String formatEndtedDate = '';

//   String? _selectedType = 'Cuti';
//   String Reason = '';
//   String? iduser;
//   String? limit;
//   String? type = '1';
//   bool _isReasonEmpty = false;
//   bool _isStartDateEmpty = false;
//   bool _isEndDateEmpty = false;
//   DateTime? _selectedStartDate;
//   DateTime? _selectedEndDate;
//   DateTime? selectedDate;
//   List<String> _typeOptions = [];
//   final _reasonController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     getProfile();
//     getData();
//   }

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           _selectedStartDate = picked;
//           _isStartDateEmpty = false;
//           // formattedDate = DateFormat('yyyy-MM-dd').format(picked);
//         } else {
//           _selectedEndDate = picked;
//           _isEndDateEmpty = false;
//           // formattedDate = DateFormat('yyyy-MM-dd').format(picked);
//         }
//       });
//     }
//   }

//   Future<void> getData() async {
//     final url = Uri.parse(
//         'https://dev-portal.eksam.cloud/api/v1/request-history/get-type');
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     try {
//       var response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer ${localStorage.getString('token')}',
//         },
//       );
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         setState(() {
//           _typeOptions =
//               List<String>.from(data['data'].map((item) => item['name']));
//         });
//       } else {
//         print('Gagal mengambil data: ${response.statusCode}');
//         print(response.body);
//       }
//     } catch (e) {
//       print('Terjadi kesalahan: $e');
//     }
//   }

//   Future<void> getProfile() async {
//     try {
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/karyawan/get-profile');

//       var request = http.MultipartRequest('GET', url);
//       SharedPreferences localStorage = await SharedPreferences.getInstance();
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());
//       print(data);

//       if (response.statusCode == 200) {
//         setState(() {
//           limit = data['data']['batas_cuti'].toString();
//           iduser = data['data']['id'].toString();
//         });
//         localStorage.setString('id', data['data']['id']);
//       } else {
//         print("Error retrieving profile");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   Future<void> _submitData() async {
//     setState(() {
//       _isReasonEmpty = Reason.isEmpty;
//       _isStartDateEmpty = formatStarttedDate.isEmpty;
//       _isEndDateEmpty = formatEndtedDate.isEmpty;
//     });

//     if (!_formKey.currentState!.validate() ||
//         _selectedStartDate == null ||
//         _selectedEndDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('All fields are required.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (!_formKey.currentState!.validate()) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Center(
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

//       String formattedStartDate =
//           DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
//       String formattedEndDate =
//           DateFormat('yyyy-MM-dd').format(_selectedEndDate!);

//       if (_selectedType == "Izin") {
//         type = '3';
//       } else if (_selectedType == "Sakit") {
//         type = '2';
//       } else {
//         type = '1';
//       }

//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';
//       request.fields['user_id'] = iduser.toString();
//       request.fields['notes'] = Reason!;
//       request.fields['startdate'] = formattedStartDate;
//       request.fields['enddate'] = formattedEndDate;
//       request.fields['type'] = type!;

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (response.statusCode == 200) {
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
//         // Membungkus body agar bisa digulir
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Remaining Leave
//               SizedBox(height: 20),
//               Container(
//                 width: double.infinity,
//                 height: 140,
//                 padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 243, 147, 4),
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Teks di sebelah kiri
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment:
//                           MainAxisAlignment.center, // Tengah vertikal
//                       children: [
//                         Text(
//                           'Your Remaining\nLeave Is',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Angka di sebelah kanan
//                     Align(
//                       alignment: Alignment.bottomRight,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.baseline,
//                         textBaseline: TextBaseline
//                             .alphabetic, // Menambahkan baseline agar teks sejajar
//                         children: [
//                           Text(
//                             limit.toString(),
//                             style: TextStyle(
//                               fontSize: 50,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 4.0),
//                             child: Text(
//                               '/',
//                               style: TextStyle(
//                                 fontSize: 44,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '12',
//                             style: TextStyle(
//                               fontSize: 20,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 24),
//               Text(
//                 'Type Time off',
//                 style: TextStyle(color: Colors.black54),
//               ),
//               SizedBox(height: 8),
//               DropdownButtonFormField<String>(
//                 value: _selectedType,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(
//                       color: const Color.fromRGBO(
//                           101, 19, 116, 1), // Customize border color
//                       width: 2, // Customize border width
//                     ),
//                   ),
//                 ),
//                 items: _typeOptions.map((String _typeOptions) {
//                   return DropdownMenuItem<String>(
//                     value: _typeOptions,
//                     child: Text(_typeOptions),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedType = newValue;
//                   });
//                 },
//               ),
//               SizedBox(height: 16),
//               // TextFormField(
//               //   controller: _reasonController,
//               //   decoration: InputDecoration(
//               //     labelText: 'Reason',
//               //     labelStyle:
//               //         TextStyle(color: const Color.fromARGB(255, 101, 19, 116)),
//               //     floatingLabelBehavior: FloatingLabelBehavior.always,
//               //     enabledBorder: OutlineInputBorder(
//               //       borderSide: BorderSide(
//               //           color: const Color.fromARGB(255, 101, 19, 116)),
//               //       borderRadius: BorderRadius.circular(8),
//               //     ),
//               //     focusedBorder: OutlineInputBorder(
//               //       borderSide: BorderSide(
//               //           color: const Color.fromARGB(255, 101, 19, 116),
//               //           width: 2),
//               //       borderRadius: BorderRadius.circular(8),
//               //     ),
//               //     errorBorder: OutlineInputBorder(
//               //       borderSide: BorderSide(color: Colors.red),
//               //       borderRadius: BorderRadius.circular(12),
//               //     ),
//               //     focusedErrorBorder: OutlineInputBorder(
//               //       borderSide: BorderSide(color: Colors.red),
//               //       borderRadius: BorderRadius.circular(12),
//               //     ),
//               //   ),
//               //   onChanged: (value) {
//               //     setState(() {
//               //       Reason = value;
//               //     });
//               //   },
//               //   validator: (value) {
//               //     if (value == null || value.isEmpty) {
//               //       return 'Please enter your reason';
//               //     }
//               //     return null;
//               //   },
//               // ),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Reason',
//                   labelStyle:
//                       TextStyle(color: const Color.fromARGB(255, 101, 19, 116)),
//                   floatingLabelBehavior:
//                       FloatingLabelBehavior.always, // Always show label on top
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: _isReasonEmpty
//                             ? Colors.red
//                             : const Color.fromARGB(255, 101, 19, 116)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: const Color.fromARGB(255, 101, 19, 116),
//                         width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Colors.red), // Border saat error
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedErrorBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Colors.red), // Border saat error dan fokus
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   errorText: _isReasonEmpty ? 'Please enter a Reason' : null,
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     Reason = value;
//                     _isReasonEmpty = false;
//                   });
//                 },
//               ),
//               SizedBox(height: 16),
//               InkWell(
//                 onTap: () => _selectDate(context, true),
//                 child: InputDecorator(
//                   decoration: InputDecoration(
//                     labelText: 'Start Date',
//                     labelStyle: TextStyle(
//                         color: const Color.fromARGB(255, 101, 19, 116)),
//                     floatingLabelBehavior: FloatingLabelBehavior
//                         .always, // Always show label on top
//                     border: OutlineInputBorder(),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: _isStartDateEmpty
//                               ? Colors.red
//                               : const Color.fromARGB(255, 101, 19, 116)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: const Color.fromARGB(255, 101, 19, 116),
//                           width: 2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderSide:
//                           BorderSide(color: Colors.red), // Border saat error
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.red), // Border saat error dan fokus
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     errorText: _isStartDateEmpty
//                         ? 'Date is required'
//                         : null, // Error message
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _selectedStartDate == null
//                             ? 'Select Start Date'
//                             : formatStarttedDate = DateFormat('yyyy-MM-dd')
//                                 .format(_selectedStartDate!),
//                       ),
//                       Icon(Icons.calendar_today, color: Colors.orange),
//                     ],
//                   ),
//                 ),
//               ),
//               // Text(
//               //   'Start Date',
//               //   style: TextStyle(color: Colors.black54),
//               // ),
//               // InkWell(
//               //   onTap: () => _selectDate(context, true),
//               //   child: InputDecorator(
//               //     decoration: InputDecoration(
//               //       border: OutlineInputBorder(
//               //         borderRadius: BorderRadius.circular(8),
//               //         borderSide: BorderSide(
//               //           color: _selectedStartDate == null
//               //               ? Colors.red
//               //               : Colors.purple,
//               //         ),
//               //       ),
//               //       errorText: _selectedStartDate == null
//               //           ? 'Tanggal Mulai wajib diisi.'
//               //           : null,
//               //     ),
//               //     child: Row(
//               //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //       children: [
//               //         Text(
//               //           _selectedStartDate == null
//               //               ? 'Pilih Tanggal Mulai'
//               //               : DateFormat('yyyy-MM-dd')
//               //                   .format(_selectedStartDate!),
//               //         ),
//               //         Icon(Icons.calendar_today, color: Colors.orange),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//               SizedBox(height: 16),
//               InkWell(
//                 onTap: () => _selectDate(context, true),
//                 child: InputDecorator(
//                   decoration: InputDecoration(
//                     labelText: 'End Date',
//                     labelStyle: TextStyle(
//                         color: const Color.fromARGB(255, 101, 19, 116)),
//                     floatingLabelBehavior: FloatingLabelBehavior
//                         .always, // Always show label on top
//                     border: OutlineInputBorder(),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: _isEndDateEmpty
//                               ? Colors.red
//                               : const Color.fromARGB(255, 101, 19, 116)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: const Color.fromARGB(255, 101, 19, 116),
//                           width: 2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderSide:
//                           BorderSide(color: Colors.red), // Border saat error
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.red), // Border saat error dan fokus
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     errorText: _isEndDateEmpty
//                         ? 'Date is required'
//                         : null, // Error message
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _selectedEndDate == null
//                             ? 'Select Start Date'
//                             : formatEndtedDate = DateFormat('yyyy-MM-dd')
//                                 .format(_selectedEndDate!),
//                       ),
//                       Icon(Icons.calendar_today, color: Colors.orange),
//                     ],
//                   ),
//                 ),
//               ),
//               // Text(
//               //   'End Date',
//               //   style: TextStyle(color: Colors.black54),
//               // ),
//               // InkWell(
//               //   onTap: () => _selectDate(context, false),
//               //   child: InputDecorator(
//               //     decoration: InputDecoration(
//               //       border: OutlineInputBorder(
//               //         borderRadius: BorderRadius.circular(8),
//               //         borderSide: BorderSide(
//               //           color: _selectedEndDate == null
//               //               ? Colors.red
//               //               : Colors.purple,
//               //         ),
//               //       ),
//               //       errorText: _selectedEndDate == null
//               //           ? 'Tanggal Akhir wajib diisi.'
//               //           : null,
//               //     ),
//               //     child: Row(
//               //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //       children: [
//               //         Text(
//               //           _selectedEndDate == null
//               //               ? 'Pilih Tanggal Akhir'
//               //               : DateFormat('yyyy-MM-dd')
//               //                   .format(_selectedEndDate!),
//               //         ),
//               //         Icon(Icons.calendar_today, color: Colors.orange),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//               SizedBox(height: 50),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     _submitData();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: Text(
//                     'Submit',
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }
// }
