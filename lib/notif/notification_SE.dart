// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:absen/susses&failde/berhasilV1.dart';
// import 'package:absen/susses&failde/gagalV1.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class ClockinwfaPage extends StatefulWidget {
//   const ClockinwfaPage({super.key});

//   @override
//   _ClockinwfaPageState createState() => _ClockinwfaPageState();
// }

// class _ClockinwfaPageState extends State<ClockinwfaPage> {
//   DateTime? selectedDate;
//   TextEditingController noteController = TextEditingController();
//   List<String> workTypes = []; // Dynamically set work types
//   String? selectedWorkType;
//   String iduser = "";
//   String? type = '1';

//   @override
//   void initState() {
//     super.initState();
//     getStatus();
//     getData();
//     getProfile();
//   }

//   Future<void> getData() async {
//     final url =
//         Uri.parse('https://portal.eksam.cloud/api/v1/request-history/get-type');
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
//         List<String> fetchedTypes = data['data']
//             .where((item) =>
//                 item['id'] == 9 &&
//                 item['name'] == 'WFA') // Filter hanya ID 9 dan WFA
//             .map<String>((item) => item['name'].toString())
//             .toList();

//         setState(() {
//           workTypes = fetchedTypes;
//           selectedWorkType = workTypes.isNotEmpty ? workTypes.first : null;
//         });
//       } else {
//         print('Gagal mengambil data: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Terjadi kesalahan: $e');
//     }
//   }

//   Future<void> getProfile() async {
//     try {
//       final url =
//           Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');

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

//   Future<void> getStatus() async {
//     final url = Uri.parse(
//         'https://portal.eksam.cloud/api/v1/attendance/get-type-parameter');
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     var request = http.MultipartRequest('GET', url);
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';

//     try {
//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (rp.statusCode == 200) {
//         List<String> filteredWorkTypes = data['data']
//             .where((item) =>
//                 item['type'] == 'Reguler') // Filter hanya tipe Reguler
//             .map<String>((item) => item['name'].toString())
//             .toList();

//         setState(() {
//           workTypes = filteredWorkTypes;
//           selectedWorkType = workTypes.isNotEmpty ? workTypes.first : null;
//         });
//       } else {
//         print('Error fetching work types: ${rp.statusCode}');
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _submitData() async {
//     if (selectedDate == null ||
//         selectedWorkType == null ||
//         noteController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Harap isi semua data sebelum submit!")),
//       );
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
//       await getProfile();

//       final url = Uri.parse(
//           'https://portal.eksam.cloud/api/v1/request-history/make-request');

//       var request = http.MultipartRequest('POST', url);
//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';
//       request.fields['user_id'] = iduser;
//       request.fields['notes'] = noteController.text;
//       request.fields['date'] = formattedDate; // Hanya mengirim startdate
//       request.fields['type'] = selectedWorkType.toString(); // Work Type
//       request.fields['type'] = type!;

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       Navigator.pop(context); // Tutup loading dialog

//       if (response.statusCode == 200) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SuccessPage()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const FailurePage()),
//         );
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       print(e);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const FailurePage()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: const Text('Clock In WFA'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Work Type Dropdown
//               const Text(
//                 'Work Type',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Color.fromRGBO(101, 19, 116, 1)),
//               ),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 value: selectedWorkType,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                           color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
//                   focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                           color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
//                 ),
//                 items: workTypes.map((String workType) {
//                   return DropdownMenuItem<String>(
//                       value: workType, child: Text(workType));
//                 }).toList(),
//                 onChanged: null, // Dropdown disabled
//               ),
//               const SizedBox(height: 20),

//               // Workplace Type Dropdown
//               const Text(
//                 'Workplace Type',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Color.fromRGBO(101, 19, 116, 1)),
//               ),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 value:
//                     selectedWorkType, // Sekarang menggunakan selectedWorkType dari API
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                           color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
//                   focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                           color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
//                 ),
//                 items: workTypes.map((String type) {
//                   return DropdownMenuItem<String>(
//                       value: type, child: Text(type));
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedWorkType = newValue;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),
// // Tanggal (Date Picker)
//               const Text(
//                 'Tanggal',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Color.fromRGBO(101, 19, 116, 1)),
//               ),
//               const SizedBox(height: 10),
//               InkWell(
//                 onTap: () async {
//                   DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2101),
//                   );

//                   if (picked != null) {
//                     setState(() {
//                       selectedDate = picked;
//                     });
//                   }
//                 },
//                 child: InputDecorator(
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 14),
//                   ),
//                   child: Text(
//                     selectedDate == null
//                         ? "Pilih Tanggal"
//                         : DateFormat('dd MMMM yyyy').format(selectedDate!),
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

// // Note (Catatan)
//               const Text(
//                 'Note',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Color.fromRGBO(101, 19, 116, 1)),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: noteController,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                           color: Color.fromRGBO(101, 19, 116, 1))),
//                   focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                           color: Color.fromRGBO(101, 19, 116, 1))),
//                   hintText: "Masukkan catatan",
//                 ),
//               ),
//               // // Date Picker
//               // const Text(
//               //   'Tanggal',
//               //   style: TextStyle(
//               //       fontSize: 16,
//               //       fontWeight: FontWeight.w500,
//               //       color: Color.fromRGBO(101, 19, 116, 1)),
//               // ),
//               // const SizedBox(height: 10),
//               // InkWell(
//               //   onTap: () => _selectDate(context),
//               //   child: InputDecorator(
//               //     decoration: InputDecoration(
//               //       border: OutlineInputBorder(
//               //           borderRadius: BorderRadius.circular(10),
//               //           borderSide: const BorderSide(
//               //               color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
//               //       focusedBorder: OutlineInputBorder(
//               //           borderRadius: BorderRadius.circular(10),
//               //           borderSide: const BorderSide(
//               //               color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
//               //       contentPadding: const EdgeInsets.symmetric(
//               //           horizontal: 12, vertical: 14),
//               //     ),
//               //     child: Text(
//               //       selectedDate == null
//               //           ? "Choose Date"
//               //           : DateFormat('dd MMMM yyyy').format(selectedDate!),
//               //       style: const TextStyle(fontSize: 16),
//               //     ),
//               //   ),
//               // ),
//               // const SizedBox(height: 20),

//               // // Note Field
//               // const Text(
//               //   'Note',
//               //   style: TextStyle(
//               //       fontSize: 16,
//               //       fontWeight: FontWeight.w500,
//               //       color: Color.fromRGBO(101, 19, 116, 1)),
//               // ),
//               // const SizedBox(height: 10),
//               // TextField(
//               //   controller: noteController,
//               //   decoration: InputDecoration(
//               //     border: OutlineInputBorder(
//               //         borderRadius: BorderRadius.circular(10),
//               //         borderSide: const BorderSide(
//               //             color: Color.fromRGBO(101, 19, 116, 1))),
//               //     focusedBorder: OutlineInputBorder(
//               //         borderRadius: BorderRadius.circular(10),
//               //         borderSide: const BorderSide(
//               //             color: Color.fromRGBO(101, 19, 116, 1))),
//               //     hintText: "Enter your note",
//               //   ),
//               // ),
//               const SizedBox(height: 120),

//               // Submit Button
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _submitData, // Call the function to submit data
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
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// //udah wfa
