import 'package:flutter/material.dart';
import 'TimeoffScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:absen/susses&failde/berhasilV2I.dart';
import 'package:absen/susses&failde/gagalV2I.dart';

class TimeOff extends StatefulWidget {
  @override
  _TimeOffState createState() => _TimeOffState();
}

class _TimeOffState extends State<TimeOff> {
  final _reasonController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? selectedDate;
  String formattedDate = '';
  String _selectedType = 'Permission';
  String Reason = '';
  String? iduser;
  String? limit;
  String? type = '1';

  @override
  void initState() {
    super.initState();
    getProfile();
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
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> getProfile() async {
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/karyawan/get-profile');

      var request = http.MultipartRequest('GET', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());
      print(data);

      if (response.statusCode == 200) {
        setState(() {
          limit = data['data']['batas_cuti'].toString();
          iduser = data['data']['id'].toString();
        });
        localStorage.setString('id', data['data']['id']);
      } else {
        print("Error retrieving profile");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _submitData() async {
    try {
      await getProfile();
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/request-history/make-request');

      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      String formattedStartDate = _selectedStartDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
          : '';
      String formattedEndDate = _selectedEndDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
          : '';

      if (_selectedType == "Permission") {
        setState(() {
          type = '3';
        });
      } else if (_selectedType == "Sick") {
        setState(() {
          type = '2';
        });
      }

      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';
      request.fields['user_id'] = iduser.toString();
      request.fields['startdate'] = formattedStartDate;
      request.fields['enddate'] = formattedEndDate;
      request.fields['type'] = type.toString();

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      print(rp.body.toString());
      var data = jsonDecode(rp.body.toString());
      print(data);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage2I()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FailurePage2I()),
        );
      }
    } catch (e) {
      print(e);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FailurePage2I()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TimeOffScreen()),
            );
          },
        ),
        title: Text(
          'Time Off',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 140,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 147, 4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Teks di sebelah kiri
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Tengah vertikal
                    children: [
                      Text(
                        'Your Remaining\nLeave Is',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Angka di sebelah kanan
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline
                          .alphabetic, // Menambahkan baseline agar teks sejajar
                      children: [
                        Text(
                          limit.toString(),
                          style: TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontSize: 44,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '12',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Type Time off',
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _selectedType,
              items:
                  ['Permission', 'Sick', 'Annual Vacation'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Reason',
                labelStyle: TextStyle(color: Colors.purple),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  Reason = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your reason';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Text(
              'Start Date',
              style: TextStyle(color: Colors.black54),
            ),
            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedStartDate == null
                          ? 'Select Start Date'
                          : DateFormat('yyyy-MM-dd')
                              .format(_selectedStartDate!),
                    ),
                    Icon(Icons.calendar_today, color: Colors.orange),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'End Date',
              style: TextStyle(color: Colors.black54),
            ),
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedEndDate == null
                          ? 'Select End Date'
                          : DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
                    ),
                    Icon(Icons.calendar_today, color: Colors.orange),
                  ],
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _submitData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
