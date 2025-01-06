// import 'package:flutter/material.dart';
// import 'package:absen/susses&failde/berhasilV1.dart';
// import 'package:absen/susses&failde/gagalV1.dart';
// import 'package:absen/homepage/home.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';

// class ClockInPage extends StatefulWidget {
//   const ClockInPage({super.key});

//   @override
//   _ClockInPageState createState() => _ClockInPageState();
// }

// class _ClockInPageState extends State<ClockInPage> {
//   String? _selectedWorkType = 'Reguler';
//   String? _selectedWorkplaceType = 'WFO';
//   File? _image; // To store the image file
//   List<String> workTypes = []; // Dynamically set work types
//   bool _isImageRequired = false; // Flag to indicate if image is required
//   bool _isHoliday = false; // Flag for holiday status
//   final ImagePicker _picker = ImagePicker();
//   final List<String> workplaceTypes = ['WFO', 'WFH'];

//   @override
//   void initState() {
//     super.initState();
//     _setWorkTypesBasedOnDay();
//   }

//   // Check if today is a weekend or holiday from API

//   Future<void> getData() async {
//     final url = Uri.parse(
//         'https://dev-portal.eksam.cloud/api/v1/attendance/get-status');
//     var request = http.MultipartRequest('GET', url);
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     request.headers['Authorization'] =
//         'Bearer ${localStorage.getString('token')}';

//     try {
//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       if (rp.statusCode == 200) {
//         setState(() {});
//       } else {
//         print('Error fetching history data: ${rp.statusCode}');
//         print(rp.body);
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   Future<void> _setWorkTypesBasedOnDay() async {
//     try {
//       // Get current day
//       final int currentDay = DateTime.now().weekday;
//       // Check if today is a weekend
//       if (currentDay == DateTime.saturday || currentDay == DateTime.sunday) {
//         setState(() {
//           _isHoliday = true;
//           workTypes = ['Lembur'];
//           _selectedWorkType = 'Lembur';
//         });
//         return;
//       }

//       // Fetch holiday data from API
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/other/cek-libur'); // Replace with your API URL

//       SharedPreferences localStorage = await SharedPreferences.getInstance();

//       var request = http.MultipartRequest('GET', url);
//       request.headers['Authorization'] =
//           'Bearer ${localStorage.getString('token')}';

//       var response = await request.send();
//       var rp = await http.Response.fromStream(response);
//       var data = jsonDecode(rp.body.toString());

//       print(data);
//       if (response.statusCode == 200) {
//         setState(() {
//           _isHoliday = data['data']['libur'];
//         });

//         // Check if today is in the holiday list
//         if (_isHoliday) {
//           setState(() {
//             workTypes = ['Lembur'];
//             _selectedWorkType = 'Lembur';
//           });
//         } else {
//           setState(() {
//             _isHoliday = false;
//             workTypes = ['Reguler', 'Lembur'];
//             _selectedWorkType = 'Reguler';
//           });
//         }
//       } else {
//         // Handle API error
//         print('Failed to fetch holidays: ${response.statusCode}');
//         setState(() {
//           workTypes = ['Reguler', 'Lembur']; // Default options
//         });
//       }
//     } catch (e) {
//       print('Error checking holidays: $e');
//       setState(() {
//         workTypes = ['Reguler', 'Lembur']; // Default options
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

//   // Function to submit data to API
//   Future<void> _submitData() async {
//     if (_image == null) {
//       // Show error if no image is uploaded
//       setState(() {
//         _isImageRequired = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please upload a photo before submitting.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return; // Stop submission if no image
//     }
//     // Show loading dialog
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
//       // Example API endpoint
//       final url = Uri.parse(
//           'https://dev-portal.eksam.cloud/api/v1/attendance/clock-in');

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
//             ); // Handle back button press
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Work Type Dropdown
//             const Text(
//               'Work Type',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: const Color.fromRGBO(101, 19, 116, 1),
//               ),
//             ),
//             const SizedBox(height: 10),
//             DropdownButtonFormField<String>(
//               value: _selectedWorkType,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(
//                     color: const Color.fromRGBO(101, 19, 116, 1),
//                     width: 2,
//                   ),
//                 ),
//               ),
//               items: workTypes.map((String workType) {
//                 return DropdownMenuItem<String>(
//                   value: workType,
//                   child: Text(workType),
//                 );
//               }).toList(),
//               onChanged: !_isHoliday
//                   ? (String? newValue) {
//                       setState(() {
//                         _selectedWorkType = newValue;
//                       });
//                     }
//                   : null, // Disable dropdown if it's a holiday
//             ),
//             const SizedBox(height: 20),

//             // Workplace Type Dropdown
//             const Text(
//               'Workplace Type',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: const Color.fromRGBO(101, 19, 116, 1),
//               ),
//             ),
//             const SizedBox(height: 10),
//             DropdownButtonFormField<String>(
//               value: _selectedWorkplaceType,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(
//                     color: const Color.fromRGBO(
//                         101, 19, 116, 1), // Customize border color
//                     width: 2, // Customize border width
//                   ),
//                 ),
//               ),
//               items: workplaceTypes.map((String workplaceType) {
//                 return DropdownMenuItem<String>(
//                   value: workplaceType,
//                   child: Text(workplaceType),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedWorkplaceType = newValue;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             // Upload Photo Button with Conditional Styling
//             GestureDetector(
//               onTap: _pickImage, // Langsung panggil kamera
//               child: Container(
//                 height: 130,
//                 width: 150,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: _isImageRequired
//                         ? Colors.red
//                         : (_image == null
//                             ? const Color.fromRGBO(101, 19, 116, 1)
//                             : Colors.orange), // Red if image is required
//                     width: 2,
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.camera_alt,
//                       size: 35,
//                       color: _isImageRequired
//                           ? Colors.red
//                           : (_image == null
//                               ? const Color.fromRGBO(101, 19, 116, 1)
//                               : Colors.orange), // Red icon if image is required
//                     ),
//                     const SizedBox(height: 3),
//                     if (_image == null && !_isImageRequired)
//                       const Text(
//                         'Upload Your Photo',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: const Color.fromRGBO(101, 19, 116, 1),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),

// // Preview Photo Button
//             if (_image != null)
//               Align(
//                 alignment: Alignment.centerLeft, // Atur posisi teks di kiri
//                 child: InkWell(
//                   onTap: () {
//                     // Show dialog to preview the photo
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Dialog(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (kIsWeb)
//                                 // Jika platform adalah Web
//                                 Image.network(
//                                   _image!.path,
//                                   fit: BoxFit.cover,
//                                 )
//                               else
//                                 // Jika platform bukan Web (mobile)
//                                 Image.file(
//                                   _image!,
//                                   fit: BoxFit.cover,
//                                 ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                   child: const Text(
//                     'Preview Photo',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.orange, // Warna teks seperti hyperlink
//                       decoration: TextDecoration
//                           .underline, // Garis bawah untuk efek hyperlink
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 160),

//             // Submit Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: _submitData, // Call the function to submit data
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   iconColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 120,
//                     vertical: 15,
//                   ),
//                 ),
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
