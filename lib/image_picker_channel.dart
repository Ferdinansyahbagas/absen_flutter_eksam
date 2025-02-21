// mport 'package:flutter/material.dart';  
// import 'package:absen/homepage/home.dart';  
// import 'dart:io';  
// import 'package:intl/intl.dart'; // Untuk format tanggal  
// import 'package:image_picker/image_picker.dart';  

// class ClockOutLupaScreen extends StatefulWidget {  
//   const ClockOutLupaScreen({super.key});  

//   @override  
//   _ClockOutLupaScreenState createState() => _ClockOutLupaScreenState();  
// }  

// class _ClockOutLupaScreenState extends State<ClockOutLupaScreen> {  
//   File? _image;  
//   String formattedDate = '';  
//   bool _isDateEmpty = false;  
//   bool _isTimeEmpty = false;  
//   DateTime? selectedDate;  
//   TimeOfDay? _selectedTime;  
//   String formattedTime = '';  
//   final ImagePicker _picker = ImagePicker();  

//   @override  
//   void initState() {  
//     super.initState();  
//   }  

//   Future<void> _pickImage() async {  
//     final XFile? pickedFile =  
//         await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);  
//     if (pickedFile != null) {  
//       setState(() {  
//         _image = File(pickedFile.path);  
//       });  
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
//         formattedDate = DateFormat('yyyy-MM-dd').format(picked);  
//         _isDateEmpty = false;  
//       });  
//     }  
//   }  

//   void _pickTime() async {  
//     TimeOfDay? pickedTime = await showTimePicker(  
//       context: context,  
//       initialTime: TimeOfDay.now(),  
//     );  

//     if (pickedTime != null) {  
//       setState(() {  
//         _selectedTime = pickedTime;  
//         DateTime now = DateTime.now();  
//         DateTime fullDateTime = DateTime(  
//           now.year, now.month, now.day,  
//           pickedTime.hour, pickedTime.minute, 0,  
//         );  
//         formattedTime = DateFormat('HH:mm:ss').format(fullDateTime);  
//         _isTimeEmpty = false;  
//       });  
//     }  
//   }  

//   @override  
//   Widget build(BuildContext context) {  
//     return Scaffold(  
//       resizeToAvoidBottomInset: true,  
//       appBar: AppBar(  
//         title: const Text('Clock Out'),  
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
//       body: SingleChildScrollView(  
//         child: Padding(  
//           padding: const EdgeInsets.all(16.0),  
//           child: Column(  
//             crossAxisAlignment: CrossAxisAlignment.start,  
//             children: [  
//               const SizedBox(height: 20),  
//               InkWell(  
//                 onTap: () => _selectDate(context),  
//                 child: InputDecorator(  
//                   decoration: InputDecoration(  
//                     labelText: 'Tanggal',  
//                     labelStyle: const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),  
//                     border: const OutlineInputBorder(),  
//                     enabledBorder: OutlineInputBorder(  
//                       borderSide: BorderSide(  
//                           color: _isDateEmpty  
//                               ? Colors.red  
//                               : const Color.fromARGB(255, 101, 19, 116)),  
//                     ),  
//                     errorText: _isDateEmpty ? 'Tanggal Wajib Di isi' : null,  
//                   ),  
//                   child: Row(  
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,  
//                     children: [  
//                       Text(  
//                         selectedDate == null ? 'Select Date' : formattedDate,  
//                       ),  
//                       const Icon(Icons.calendar_today, color: Colors.orange),  
//                     ],  
//                   ),  
//                 ),  
//               ),  
//               const SizedBox(height: 20),  
//               InkWell(  
//                 onTap: _pickTime,  
//                 child: InputDecorator(  
//                   decoration: InputDecoration(  
//                     labelText: 'Clock-Out Time',  
//                     labelStyle: const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),  
//                     border: const OutlineInputBorder(),  
//                     enabledBorder: OutlineInputBorder(  
//                       borderSide: BorderSide(  
//                           color: _isTimeEmpty  
//                               ? Colors.red  
//                               : const Color.fromARGB(255, 101, 19, 116)),  
//                     ),  
//                     errorText: _isTimeEmpty ? 'Clock-Out Time Wajib Diisi' : null,  
//                   ),  
//                   child: Row(  
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,  
//                     children: [  
//                       Text(  
//                         formattedTime.isEmpty  
//                             ? 'Select Time'  
//                             : formattedTime,  
//                       ),  
//                       const Icon(Icons.access_time, color: Colors.orange),  
//                     ],  
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