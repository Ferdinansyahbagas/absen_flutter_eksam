import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for formatting date
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String totalReimbursement = '';
  DateTime? selectedDate;
  String formattedDate = '';
  final _dateController = TextEditingController();
  File? _image; // To store the image file
  final ImagePicker _picker = ImagePicker();
  bool _isImageRequired = false;

  // Function to pick image from gallery or camera
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isImageRequired = false;
      });
    }
  }

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
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/attendance/clock-out');
      var request = http.MultipartRequest('PUT', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

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

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate!);
        _dateController.text = formattedDate;
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
              // Field for name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.purple),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
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
                ),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Field for description
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.purple),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
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
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Field for total reimbursement
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total Reimbursement',
                  labelStyle: TextStyle(color: Colors.purple),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
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
                ),
                onChanged: (value) {
                  setState(() {
                    totalReimbursement = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total reimbursement';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Date picker field
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: TextStyle(color: Colors.purple),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.orange),
                    onPressed: () => _pickDate(context),
                  ),
                ),
                readOnly: true,
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
                              ? Colors.purple
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
                                ? Colors.purple
                                : Colors
                                    .orange), // Red icon if image is required
                      ),
                      const SizedBox(height: 3),
                      if (_image == null && !_isImageRequired)
                        const Text(
                          'Upload Your Photo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.purple,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process reimbursement request
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reimbursement Requested')),
                    );
                  }
                },
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
