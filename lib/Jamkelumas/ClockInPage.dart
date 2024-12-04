import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:absen/homepage/home.dart';
import 'package:absen/susses&failde/berhasilV1.dart';
import 'package:absen/susses&failde/gagalV1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

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
  List<String> workTypes = []; // Dynamically set work types
  final List<String> workplaceTypes = ['WFO', 'WFH'];
  bool _isImageRequired = false; // Flag to indicate if image is required
  bool _isHoliday = false; // Flag for holiday status

  @override
  void initState() {
    super.initState();
    _setWorkTypesBasedOnDay();
  }

  // Check if today is a weekend or holiday from API
  Future<void> _setWorkTypesBasedOnDay() async {
    try {
      // Get current day
      final int currentDay = DateTime.now().weekday;
      // Check if today is a weekend
      if (currentDay == DateTime.saturday || currentDay == DateTime.sunday) {
        setState(() {
          _isHoliday = true;
          workTypes = ['Lembur'];
          _selectedWorkType = 'Lembur';
        });
        return;
      }

      // Fetch holiday data from API
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/other/cek-libur'); // Replace with your API URL

      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      print(data);
      if (response.statusCode == 200) {
        setState(() {
          _isHoliday = data['data']['libur'];
        });

        // Check if today is in the holiday list
        if (_isHoliday) {
          setState(() {
            workTypes = ['Lembur'];
            _selectedWorkType = 'Lembur';
          });
        } else {
          setState(() {
            _isHoliday = false;
            workTypes = ['Reguler', 'Lembur'];
            _selectedWorkType = 'Reguler';
          });
        }
      } else {
        // Handle API error
        print('Failed to fetch holidays: ${response.statusCode}');
        setState(() {
          workTypes = ['Reguler', 'Lembur']; // Default options
        });
      }
    } catch (e) {
      print('Error checking holidays: $e');
      setState(() {
        workTypes = ['Reguler', 'Lembur']; // Default options
      });
    }
  }

  // Function to pick image only from camera
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isImageRequired = false; // Reset flag once image is picked
        });
        print("Image selected successfully: ${pickedFile.path}");
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error accessing camera. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to submit data to API
  Future<void> _submitData() async {
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
      // Example API endpoint
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/attendance/clock-in');

      // Prepare multipart request to send image and data
      var request = http.MultipartRequest('POST', url);

      // Save selected work type and workplace type to SharedPreferences
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('workType', _selectedWorkType!);
      await localStorage.setString('workplaceType', _selectedWorkplaceType!);

      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';
      String type = '1';
      String location = '1';
      if (_selectedWorkType == "Lembur") {
        type = '2';
      } else {
        type = '1';
      }
      if (_selectedWorkplaceType == "WFH") {
        location = '2';
      } else {
        location = '1';
      }
      request.fields['type'] = type;
      request.fields['status'] = '1';
      request.fields['location'] = location;

      // Add image file
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // Field name for image in the API
          _image!.path,
          contentType: MediaType('image', 'jpeg'), // Set content type
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
                    color: Colors.purple,
                    width: 2,
                  ),
                ),
              ),
              items: workTypes.map((String workType) {
                return DropdownMenuItem<String>(
                  value: workType,
                  child: Text(workType),
                );
              }).toList(),
              onChanged: !_isHoliday
                  ? (String? newValue) {
                      setState(() {
                        _selectedWorkType = newValue;
                      });
                    }
                  : null, // Disable dropdown if it's a holiday
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
            // Upload Photo Button with Conditional Styling
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
                              : Colors.orange), // Red icon if image is required
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
            const SizedBox(height: 180),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitData, // Call the function to submit data
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  iconColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 120,
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
}