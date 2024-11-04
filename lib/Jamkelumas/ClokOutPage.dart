import 'package:absen/homepage/home.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:absen/susses&failde/berhasilV1.dart';
import 'package:absen/susses&failde/gagalV1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class ClockOutScreen extends StatefulWidget {
  const ClockOutScreen({super.key});

  @override
  _ClockOutScreenState createState() => _ClockOutScreenState();
}

class _ClockOutScreenState extends State<ClockOutScreen> {
  String? _selectedWorkType = 'Reguler';
  String? _selectedWorkplaceType = 'WFO';
  File? _image; // To store the image file
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteController = TextEditingController();

  final List<String> workTypes = ['Reguler', 'Lembur'];
  final List<String> workplaceTypes = ['WFO', 'WFH'];

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to submit data to API
  Future<void> _submitData() async {
    try {
      // Example API endpoint
      final url =
          Uri.parse('http://127.0.0.1:8000/api/v1/attendance/clock-out');

      // Prepare multipart request to send image and data
      var request = http.MultipartRequest('PUT', url);

      // Add form fields
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';
      request.fields['workType'] = _selectedWorkType!;
      request.fields['workplaceType'] = _selectedWorkplaceType!;

      // Add image file if selected
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // Field name in the API
          _image!.path,
        ));
      }

      // Send the request and get the response
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());
      print(data);
      var status = data['status'];
      if (response.statusCode == 200) {
        // Successfully submitted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage()),
        );
      } else {
        // Submission failed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FailurePage()),
        );
      }
    } catch (e) {
      // Handle error and navigate to failure page
      print("Error: $e");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FailurePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock Out'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ); // Handle back button press
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Work Type Dropdown
            const Text(
              'Work Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedWorkType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.purple, // Customize border color
                    width: 2, // Customize border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.purple, // Keep the border color when focused
                    width: 2, // Keep the border width when focused
                  ),
                ),
              ),
              items: workTypes.map((String workType) {
                return DropdownMenuItem<String>(
                  value: workType,
                  child: Text(workType),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWorkType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // Workplace Type Dropdown
            const Text(
              'Workplace Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedWorkplaceType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.purple, // Customize border color
                    width: 2, // Customize border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.purple, // Keep the border color when focused
                    width: 2, // Keep the border width when focused
                  ),
                ),
              ),
              items: workplaceTypes.map((String workplaceType) {
                return DropdownMenuItem<String>(
                  value: workplaceType,
                  child: Text(workplaceType),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWorkplaceType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

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
                          : Colors.yellow), // Change to yellow if photo exists
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
                    const SizedBox(height: 3),
                    if (_image == null)
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
            const SizedBox(height: 20),

            // TextField for Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 120),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 145,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
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
