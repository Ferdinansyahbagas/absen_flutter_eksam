import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:absen/susses&failde/berhasilWFA&WFH.dart';
import 'package:absen/susses&failde/gagalV2I.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ClockinwfaPage extends StatefulWidget {
  const ClockinwfaPage({super.key});

  @override
  _ClockinwfaPageState createState() => _ClockinwfaPageState();
}

class _ClockinwfaPageState extends State<ClockinwfaPage> {
  String? bataswfh;
  String? selectedWorkType;
  String? selectedWorkPlaceType;
  String iduser = "";
  String? type = '1';
  // ignore: unused_field
  String? _selectedType = ' ';
  bool isQuotaEmpty = false; // Tambahkan state untuk cek kuota kosong
  DateTime? selectedDate;
  List<String> workTypes = []; // Dynamically set work types
  List<String> workPlaceTypes = []; // Dynamically set work types
  List<String> _quotaOptions = [];
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getStatus();
    getData();
    getProfile();
    getDatakuota();
  }

  Future<void> getData() async {
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/request-history/get-type');
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${localStorage.getString('token')}',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<String> fetchedTypes = data['data']
            .where((item) =>
                item['id'] == 9 &&
                item['name'] == 'WFA') // Filter hanya ID 9 dan WFA
            .map<String>((item) => item['name'].toString())
            .toList();

        setState(() {
          workPlaceTypes = fetchedTypes;
          selectedWorkPlaceType =
              workPlaceTypes.isNotEmpty ? workPlaceTypes.first : null;
        });
      } else {
        print('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> getStatus() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/get-type-parameter');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? token = localStorage.getString('token');

    if (token == null || token.isEmpty) {
      print("Error: Token tidak ditemukan!");
      return;
    }

    try {
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<String> fetchedWorkTypes = data['data']
            .map<String>((item) => item['name'].toString())
            .toList(); // Ambil semua work types

        setState(() {
          workTypes = fetchedWorkTypes;
          selectedWorkType = "Reguler"; // Hardcoded tetap "Reguler"
        });
      } else {
        print('Error fetching work types: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getDatakuota() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/request-history/get-self-kuota');
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${localStorage.getString('token')}',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Response API Kuota: ${jsonEncode(data)}");

        // Filter hanya kuota WFA
        var wfaQuota = (data['data'] as List?)
            ?.where((item) => item['type']['name'].toString() == "WFA")
            .toList();

        if (wfaQuota == null || wfaQuota.isEmpty) {
          // Jika tidak ada kuota WFA, set peringatan
          setState(() {
            _quotaOptions = ["Tidak ada kuota WFA tersedia"];
            _selectedType = _quotaOptions.first;
            isQuotaEmpty = true; // Set flag kuota kosong
          });
          return;
        }

        // Ambil informasi kuota WFA
        setState(() {
          _quotaOptions = wfaQuota.map<String>((item) {
            String typeName = item['type']['name'].toString();
            String remaining = item['kuota'].toString();
            String maxQuota = item['type']['max_quota'].toString();
            return "$typeName ($remaining/$maxQuota)";
          }).toList();

          isQuotaEmpty = wfaQuota.first['kuota'] == 0; // Cek jika kuota 0
          _selectedType = _quotaOptions.isNotEmpty ? _quotaOptions.first : null;
        });
      } else {
        print('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> getProfile() async {
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? token = localStorage.getString('token');

    if (token == null || token.isEmpty) {
      print("Error: Token tidak ditemukan!");
      return;
    }

    try {
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Profile Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          iduser = data['data']['id'].toString();
          bataswfh = (data['data']['batas_wfh'] ?? "0").toString();
        });
        localStorage.setString('id', iduser);
      } else {
        print("Error retrieving profile");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _submitData() async {
    if (selectedDate == null || noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua data sebelum submit!")),
      );
      return;
    }
    if (isQuotaEmpty) {
      setState(() {}); // Update UI agar peringatan muncul
      return;
    }
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
      await getProfile();

      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/request-history/make-wfa-request');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? token = localStorage.getString('token');

      if (token == null || token.isEmpty) {
        print("Error: Token tidak ditemukan!");
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': iduser,
          'notes': noteController.text,
          'date': formattedDate,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPageWFA()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FailurePage2I()),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FailurePage2I()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Clock In WFA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
              const Text(
                'Work Type',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(101, 19, 116, 1)),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedWorkType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(101, 19, 116, 1), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(101, 19, 116, 1), width: 2),
                  ),
                ),
                items: workTypes.map((String workType) {
                  return DropdownMenuItem<String>(
                    value: workType,
                    child: Text(workType),
                  );
                }).toList(),
                onChanged: null,
              ),
              const SizedBox(height: 20),
              // Workplace Type Dropdown
              const Text(
                'Workplace Type',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(101, 19, 116, 1)),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value:
                    selectedWorkPlaceType, // Sekarang menggunakan selectedWorkType dari API
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
                items: workPlaceTypes.map((String type) {
                  return DropdownMenuItem<String>(
                      value: type, child: Text(type));
                }).toList(),
                onChanged: null,
              ),
              const SizedBox(height: 20),
// Tanggal (Date Picker)
              const Text(
                'Tanggal',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(101, 19, 116, 1)),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  child: Text(
                    selectedDate == null
                        ? "Pilih Tanggal"
                        : DateFormat('dd MMMM yyyy').format(selectedDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
// Note (Catatan)
              const Text(
                'Note',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(101, 19, 116, 1)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1))),
                  hintText: "Masukkan catatan",
                ),
              ),
              // Tampilkan peringatan jika kuota WFA kosong
              const SizedBox(height: 10),
              if (isQuotaEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Kuota WFA tidak tersedia!",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 120),
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
      ),
    );
  }
}
