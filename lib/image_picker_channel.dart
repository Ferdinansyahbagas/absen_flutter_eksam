import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  _ClockInPageState createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  String? _selectedWorkType = 'Reguler';
  String? _selectedWorkplaceType = 'WFO';
  String? batasWfh;
  bool isPending = false; // Untuk status tombol setelah submit WFH

  @override
  void initState() {
    super.initState();
    _fetchBatasWFH();
    _checkWFHStatus();
  }

  Future<void> _fetchBatasWFH() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer ${localStorage.getString('token')}'
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        batasWfh = data['data']['batas_wfh'].toString();
      });
    }
  }

  Future<void> _checkWFHStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-wfh');
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer ${localStorage.getString('token')}'
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        isPending = data['is_wfh']; // Ubah tombol jika sudah mengajukan WFH
      });
    }
  }

  Future<void> _submitWFH() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/attendance/clock-in');
    var response = await http.post(url,
        headers: {'Authorization': 'Bearer ${localStorage.getString('token')}'},
        body: {'type': '1', 'location': '2'});

    if (response.statusCode == 200) {
      setState(() {
        isPending = true;
      });
    }
  }

  Future<void> _cancelWFH() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/attendance/cancel-wfh');
    var response = await http.delete(url, headers: {
      'Authorization': 'Bearer ${localStorage.getString('token')}'
    });

    if (response.statusCode == 200) {
      setState(() {
        isPending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clock In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jenis Pekerjaan'),
            DropdownButtonFormField<String>(
              value: _selectedWorkType,
              items: ['Reguler', 'Lembur'].map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWorkType = newValue;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text('Jenis Tempat Kerja'),
            DropdownButtonFormField<String>(
              value: _selectedWorkplaceType,
              items: ['WFO', 'WFH'].map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWorkplaceType = newValue;
                });
              },
            ),
            if (_selectedWorkType == 'Reguler' &&
                _selectedWorkplaceType == 'WFH')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Batas WFH anda tersisa: $batasWfh'),
              ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: isPending ? null : _submitWFH,
                    child: Text(isPending ? 'Pending' : 'Clock In'),
                  ),
                  if (isPending)
                    TextButton(
                      onPressed: _cancelWFH,
                      child: const Text('Batalkan'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
