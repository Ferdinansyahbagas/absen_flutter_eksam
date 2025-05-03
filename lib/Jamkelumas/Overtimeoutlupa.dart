import 'package:flutter/material.dart';
import 'package:absen/history/depan.dart'; // Mengimpor halaman history
import 'package:absen/susses&failde/gagalovertimelupa.dart';
import 'package:absen/susses&failde/berhasilovertimelupa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; //unntuk format tanggal
import 'dart:convert';

class Overtimeoutlupa extends StatefulWidget {
  const Overtimeoutlupa({super.key});

  @override
  _OvertimeoutlupaState createState() => _OvertimeoutlupaState();
}

class _OvertimeoutlupaState extends State<Overtimeoutlupa> {
  String note = '';
  String formattedDate = '';
  String formattedTime = '';
  String? _absenId; // Tambahan untuk ID absen
  String? userStatus; // Tambahan untuk menyimpan user level
  String? _selectedWorkType;
  String? _selectedWorkplaceType;
  bool _isTimeEmpty = false;
  bool _isNoteRequired = false;
  List<String> WorkTypes = [];
  List<String> WorkplaceTypes = [];
  DateTime? selectedDate;
  TimeOfDay? _selectedTime; // Variabel untuk menyimpan waktu clock-out
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProfil();
    getStatus();
    _loadSelectedValues();
    getDatalupaOvertime();
  }

  Future<void> _loadSelectedValues() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    bool isClockInDone = localStorage.getBool('clockInDone') ?? false;
    if (isClockInDone) {
      setState(() {
        _selectedWorkType = localStorage.getString('workType');
        _selectedWorkplaceType = localStorage.getString('workplaceType');
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        DateTime now = DateTime.now();
        DateTime fullDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
          0,
        );
        formattedTime = DateFormat('HH:mm:ss').format(fullDateTime);
        _isTimeEmpty = false;
      });
    }
  }

  Future<void> getProfil() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        userStatus = data['data']['user_level_id'].toString();
      });

      print("Profil pengguna: ${data['data']}");
    } catch (e) {
      print("Error mengambil profil pengguna: $e");
    }
  }

  Future<void> getStatus() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/get-type-parameter');
    var request = http.MultipartRequest('GET', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (rp.statusCode == 200) {
        setState(() {
          WorkTypes = List<String>.from(
            data['data']
                .where(
                    (item) => item['name'].toString().toLowerCase() == 'lembur')
                .map((item) => item['name']),
          );
        });
      } else {
        print('Error fetching history data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getDatalupaOvertime() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/overtime-detail/{id}');
    var request = http.MultipartRequest('GET', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        var data = jsonDecode(rp.body.toString());
        print(data);
        setState(() {
          // _selectedWorkType = data['data']['type']['name'];
          _selectedWorkplaceType = data['data']['attendance_location']['name'];
          formattedDate = data['data']['date'];
          _absenId = data['data']['id'].toString(); // Ambil ID absen
        });
      } else {
        print('Error fetching history data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _submitData() async {
    setState(() {
      _isTimeEmpty = _selectedTime == null;
      _isNoteRequired = _noteController.text.isEmpty;
    });

    if (_isTimeEmpty || _isNoteRequired || _absenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua field sebelum submit.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String formattedTime =
        "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 101, 19, 116),
          ),
        );
      },
    );

    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/attendance/overtime-forgot/$_absenId');
      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      request.fields['id'] = _absenId!;
      request.fields['notes'] = _noteController.text;
      request.fields['jam_clock_out'] = formattedTime;
      request.fields['date'] = formattedDate;

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      Navigator.pop(context); // Tutup loading

      if (response.statusCode == 200) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Successovertimelupa()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Failureovertimelupa()));
      }
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => Failureovertimelupa()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Clock Out'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Work Type Dropdown
              const Text('Work Type',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(101, 19, 116, 1))),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWorkType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                ),
                items: [_selectedWorkType ?? 'No Work Type Selected']
                    .map((String workType) {
                  return DropdownMenuItem<String>(
                      value: workType, child: Text(workType));
                }).toList(),
                onChanged: null, // Disabled
              ),
              const SizedBox(height: 20),
              // Workplace Type Dropdown
              const Text('Workplace Type',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(101, 19, 116, 1))),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWorkplaceType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                ),
                items: [_selectedWorkplaceType ?? 'No Workplace Type Selected']
                    .map((String workplaceType) {
                  return DropdownMenuItem<String>(
                      value: workplaceType, child: Text(workplaceType));
                }).toList(),
                onChanged: null, // Disabled
              ),
              const SizedBox(height: 20),
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tanggal Clock Out',
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 101, 19, 116)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 101, 19, 116), width: 2),
                  ),
                ),
                child: Text(
                    formattedDate.isNotEmpty ? formattedDate : 'Memuat...'),
              ),
              const SizedBox(height: 20),

              // Input untuk Clock-Out Time
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Clock-Out Time',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.always, // Label selalu di atas
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isTimeEmpty
                              ? Colors.red
                              : const Color.fromARGB(255, 101, 19, 116)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 101, 19, 116), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText:
                        _isTimeEmpty ? 'Clock-Out Time Wajib Diisi' : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedTime.isEmpty ? 'Select Time' : formattedTime,
                      ),
                      const Icon(Icons.access_time, color: Colors.orange),
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
                  labelStyle: TextStyle(
                    color: _isNoteRequired ? Colors.red : Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isNoteRequired
                          ? Colors.red
                          : const Color.fromRGBO(101, 19, 116, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isNoteRequired
                          ? Colors.red
                          : const Color.fromRGBO(101, 19, 116, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _isNoteRequired = false;
                    });
                  }
                },
              ),

              const SizedBox(height: 120),
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
      ),
    );
  }
}
