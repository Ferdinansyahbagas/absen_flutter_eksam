import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:absen/homepage/home.dart';
import 'package:absen/susses&failde/berhasilV1.dart';
import 'package:absen/susses&failde/gagalV1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  _ClockInPageState createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  String? _selectedWorkType = 'Reguler';
  String? _selectedWorkplaceType = 'WFO';
  File? _image; // To store the image file
  final ImagePicker _picker = ImagePicker();

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
      final url = Uri.parse('http://127.0.0.1:8000/api/v1/attendance/clock-in');

      // Prepare multipart request to send image and data

      var request = http.MultipartRequest('POST', url);
      // Add form fields
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';
      request.fields['type'] = '1';
      request.fields['status'] = '1';
      request.fields['location'] = '1';

      // Add image file if selected
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto', // Field name in the API
          _image!.path,
        ));
      }

      // Send the request and get the response
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());
      print(data);
      var status = data['status'];
      if (status == 'success') {
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
        title: const Text('Clock In'),
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
                          : Colors
                              .yellow), // Ubah warna border jika foto sudah di-upload
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _image == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 35,
                            color: Colors.purple,
                          )
                        : Image.file(
                            _image!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                    const SizedBox(height: 3),
                    // Hanya tampilkan teks jika _image belum ada
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
            const SizedBox(height: 180),
            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitData, // Call the function to submit data
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  iconColor: Colors.white,
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
