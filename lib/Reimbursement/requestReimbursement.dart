import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for formatting date
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';

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

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
                onTap: () {
                  _showImageSourceSelectionDialog(context);
                },
                child: Container(
                  height: 130,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: _image == null
                            ? Colors.purple
                            : Colors
                                .yellow), // Ubah border warna menjadi kuning jika ada foto
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _image == null
                          ? IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 35,
                                color: Colors.purple,
                              ),
                              onPressed: () {
                                _showImageSourceSelectionDialog(context);
                              },
                            )
                          : Image.file(
                              _image!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(
                          height: 3), // Adding space between icon and text
                      _image == null
                          ? const Text(
                              'Upload Your Photo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.purple,
                              ),
                            )
                          : Container(),
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

// Show dialog to choose between Camera or Gallery
  void _showImageSourceSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }
}
