import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for formatting date
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:absen/susses&failde/berhasilV3.dart';
import 'package:absen/susses&failde/gagalV3.dart';

class ReimbursementForm extends StatefulWidget {
  @override
  _ReimbursementFormState createState() => _ReimbursementFormState();
}

class _ReimbursementFormState extends State<ReimbursementForm> {
  File? _image;
  String description = '';
  String totalReimbursement = '';
  String formattedDate = '';
  DateTime? selectedDate;
  bool _isImageRequired = false;
  bool _isDescriptionEmpty = false;
  bool _isTotalEmpty = false;
  bool _isDateEmpty = false;
  final _formKey = GlobalKey<FormState>();
  // final _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _submitData() async {
    setState(() {
      _isDescriptionEmpty = description.isEmpty;
      _isTotalEmpty = totalReimbursement.isEmpty;
      _isDateEmpty = formattedDate.isEmpty;
    });

    if (_isDescriptionEmpty || _isTotalEmpty || _isDateEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      // Show error if no image is uploaded
      setState(() {
        _isImageRequired = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop submission if no image
    }

    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/other/add-self-reimbursement');
      var request = http.MultipartRequest('POST', url);

      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');

      if (token == null) {
        throw Exception('Authorization token not found');
      }

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['harga'] = totalReimbursement;
      request.fields['date'] = formattedDate;
      request.fields['name'] = description;

      request.files.add(await http.MultipartFile.fromPath(
        'invoice',
        _image!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SuccessPage3()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FailurePage3()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => FailurePage3()));
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedDate = picked;
          formattedDate = DateFormat('yyyy-MM-dd').format(picked);
          _isDateEmpty = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ReimbursementPage()),
            ); // Action for back button
          },
        ),
        title: Text(
          'Reimbursement',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Field for description
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color:  const Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            _isDescriptionEmpty ? Colors.red :  const Color.fromARGB(255, 101, 19, 116)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  const Color.fromARGB(255, 101, 19, 116), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.red), // Border saat error
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.red), // Border saat error dan fokus
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText:
                      _isDescriptionEmpty ? 'Please enter a description' : null,
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                    _isDescriptionEmpty = false;
                  });
                },
              ),
              SizedBox(height: 16),

              // Field for total reimbursement
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total Reimbursement',
                  labelStyle: TextStyle(color:  const Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isTotalEmpty ? Colors.red :  const Color.fromARGB(255, 101, 19, 116)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  const Color.fromARGB(255, 101, 19, 116), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.red), // Border saat error
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.red), // Border saat error dan fokus
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _isTotalEmpty
                      ? 'Please enter the total reimbursement'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    totalReimbursement = value;
                    _isTotalEmpty = false;
                  });
                },
              ),
              SizedBox(height: 16),

              // Date picker field
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    labelStyle: TextStyle(color:  const Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDateEmpty ? Colors.red :  const Color.fromARGB(255, 101, 19, 116)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color:  const Color.fromARGB(255, 101, 19, 116), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.red), // Border saat error
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.red), // Border saat error dan fokus
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _isDateEmpty
                        ? 'Date is required'
                        : null, // Error message
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null ? 'Select Date' : formattedDate,
                      ),
                      Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Upload Photo Button
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
                          'Upload Your Photo',
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
                      'Preview Photo',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.orange, // Warna teks seperti hyperlink
                        decoration: TextDecoration
                            .underline, // Garis bawah untuk efek hyperlink
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 130),
              // Submit button
              ElevatedButton(
                onPressed: _submitData, // Call the function to submit data
                child: Text('Request Reimbursement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 45), // Full width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
