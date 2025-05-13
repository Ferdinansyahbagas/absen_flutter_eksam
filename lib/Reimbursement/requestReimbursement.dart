import 'package:flutter/material.dart';
import 'package:absen/success_failed/gagalV3.dart';
import 'package:absen/success_failed/berhasilV3.dart';
import 'package:absen/Reimbursement/Reimbursementscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // for formatting date
import 'dart:convert';
import 'dart:io';

class ReimbursementForm extends StatefulWidget {
  const ReimbursementForm({super.key});

  @override
  _ReimbursementFormState createState() => _ReimbursementFormState();
}

class _ReimbursementFormState extends State<ReimbursementForm> {
  String description = '';
  String formattedDate = '';
  String totalReimbursement = '';
  File? _image;
  bool _isDateEmpty = false;
  bool _isTotalEmpty = false;
  bool _isImageRequired = false;
  bool _isDescriptionEmpty = false;
  DateTime? selectedDate;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // *Menampilkan dialog pilihan sumber gambar*
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // *Mengambil gambar dari sumber yang dipilih*
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isImageRequired = false;
      });
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

    // Show loading dialog
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

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: const Color.fromARGB(255, 101, 19, 116),
          ),
        );
      },
    );
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/other/add-self-reimbursement');
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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SuccessPage3()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FailurePage3()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const FailurePage3()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ReimbursementPage()),
            ); // Action for back button
          },
        ),
        title: const Text(
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
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isDescriptionEmpty
                            ? Colors.red
                            : const Color.fromARGB(255, 101, 19, 116)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 101, 19, 116), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border saat error
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border saat error dan fokus
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText:
                      _isDescriptionEmpty ? 'Tolong Isi description' : null,
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                    _isDescriptionEmpty = false;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Field for total reimbursement
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total Reimbursement',
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isTotalEmpty
                            ? Colors.red
                            : const Color.fromARGB(255, 101, 19, 116)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 101, 19, 116), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border saat error
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border saat error dan fokus
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _isTotalEmpty
                      ? 'Tolong Masukan total reimbursement'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    totalReimbursement = value;
                    _isTotalEmpty = false;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date picker field
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isDateEmpty
                              ? Colors.red
                              : const Color.fromARGB(255, 101, 19, 116)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 101, 19, 116), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.red), // Border saat error
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.red), // Border saat error dan fokus
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _isDateEmpty
                        ? 'Tanggal Wajib Di isi'
                        : null, // Error message
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null ? 'Select Date' : formattedDate,
                      ),
                      const Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Upload Photo Button
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 130,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isImageRequired
                          ? Colors.red
                          : (_image == null
                              ? const Color.fromRGBO(101, 19, 116, 1)
                              : Colors.orange),
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
                                : Colors.orange),
                      ),
                      const SizedBox(height: 3),
                      if (_image == null && !_isImageRequired)
                        const Text(
                          'Upload Photo Anda',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(101, 19, 116, 1)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (_image != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (kIsWeb)
                                  Image.network(_image!.path, fit: BoxFit.cover)
                                else
                                  Image.file(_image!, fit: BoxFit.cover),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Lihat Photo',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.orange,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              const SizedBox(height: 130),
              // Submit button
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, 45), // Full width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ), // Call the function to submit data
                child: const Text('Request Reimbursement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
