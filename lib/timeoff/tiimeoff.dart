import 'package:flutter/material.dart';
import 'TimeoffScreen.dart';
import 'package:absen/susses&failde/berhasilV2I.dart';
import 'package:absen/susses&failde/gagalV2I.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TimeOff extends StatefulWidget {
  const TimeOff({super.key});

  @override
  _TimeOffState createState() => _TimeOffState();
}

class _TimeOffState extends State<TimeOff> {
  String formatStarttedDate = '';
  String formatEndtedDate = '';
  String Reason = '';
  String? _selectedType = '';
  String? iduser;
  String? limit;
  String? type = '';
  bool _isReasonEmpty = false;
  bool _isStartDateEmpty = false;
  bool _isEndDateEmpty = false;
  bool _isQuotaEmpty = false; // Tambahan: cek jika kuota habis
  String _quotaWarning = ''; // Pesan peringatan kuota
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? selectedDate;
  List<String> _quotaOptions = [];
  List<String> _typeOptions = [''];
  final _reasonController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getProfile();
    // getData();
    getDatakuota();
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
          _isStartDateEmpty = false;
          formatStarttedDate = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _selectedEndDate = picked;
          _isEndDateEmpty = false;
          formatEndtedDate = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  // Future<void> getDatakuota() async {
  //   final url = Uri.parse(
  //       'https://portal.eksam.cloud/api/v1/request-history/get-self-kuota');
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();

  //   try {
  //     var response = await http.get(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer ${localStorage.getString('token')}',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);
  //       print("Response API Kuota: ${jsonEncode(data)}");

  //       if (data['data'] == null || (data['data'] as List).isEmpty) {
  //         print("Data kuota kosong");
  //         setState(() {
  //           _quotaOptions = ["Tidak ada kuota tersedia"];
  //           _selectedType = _quotaOptions.first;
  //         });
  //         return;
  //       }

  //       setState(() {
  //         _quotaOptions = (data['data'] as List).map<String>((item) {
  //           String typeName = item['type']['name'].toString();
  //           String remaining = item['kuota'].toString();
  //           String maxQuota = item['type']['max_quota'].toString();
  //           return "$typeName ($remaining/$maxQuota)";
  //         }).toList();

  //         if (_quotaOptions.isNotEmpty) {
  //           _selectedType = _quotaOptions.first;
  //         }
  //       });
  //     } else {
  //       print('Gagal mengambil data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Terjadi kesalahan: $e');
  //   }
  // }
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

        if (data['data'] == null || (data['data'] as List).isEmpty) {
          setState(() {
            _quotaOptions = [];
            _selectedType = null;
            _isQuotaEmpty = true;
            _quotaWarning = "Kuota cuti tidak tersedia!";
          });
          return;
        }

        List<String> filteredQuota = (data['data'] as List)
            .where((item) =>
                item['type']['name'].toString() != "WFA" &&
                item['type']['name'].toString() != "Cuti Sakit")
            .map<String>((item) {
              String typeName = item['type']['name'].toString();
              int remaining = int.parse(item['kuota'].toString());
              String maxQuota = item['type']['max_quota'].toString();

              return remaining > 0 ? "$typeName ($remaining/$maxQuota)" : "";
            })
            .where((element) => element.isNotEmpty)
            .toList();

        setState(() {
          _quotaOptions = filteredQuota;
          _selectedType = _quotaOptions.isNotEmpty ? _quotaOptions.first : null;
          _isQuotaEmpty = _quotaOptions.isEmpty;
          _quotaWarning = _isQuotaEmpty
              ? "Kuota cuti tidak tersedia!"
              : ""; // Update warning
        });
      } else {
        print('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }
  // Future<void> getData() async {
  //   final url = Uri.parse(
  //       'https://portal.eksam.cloud/api/v1/request-history/get-type-parameter');
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   try {
  //     var response = await http.get(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer ${localStorage.getString('token')}',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);
  //       setState(() {
  //         _typeOptions =
  //             List<String>.from(data['data'].map((item) => item['name']));

  //         // Jika _selectedType tidak ada di daftar, atur ulang ke nilai pertama yang valid
  //         if (_typeOptions.isNotEmpty &&
  //             !_typeOptions.contains(_selectedType)) {
  //           _selectedType = _typeOptions.first;
  //         }
  //       });
  //     } else {
  //       print('Gagal mengambil data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Terjadi kesalahan: $e');
  //   }
  // }

  Future<void> getProfile() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-profile');

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
          'https://portal.eksam.cloud/api/v1/request-history/make-request');

      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      String formattedStartDate =
          DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
      String formattedEndDate =
          DateFormat('yyyy-MM-dd').format(_selectedEndDate!);

      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';
      request.fields['user_id'] = iduser.toString();
      request.fields['notes'] = Reason;
      request.fields['startdate'] = formattedStartDate;
      request.fields['enddate'] = formattedEndDate;
      request.fields['type'] = type!;

      var response = await request.send();
      // var rp = await http.Response.fromStream(response);
      // var data = jsonDecode(rp.body.toString());

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPage2I()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FailurePage2I()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FailurePage2I()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TimeOffScreen()),
            );
          },
        ),
        title: const Text(
          'Time Off',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Membungkus body agar bisa digulir
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Tipe Cuti',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              // DropdownButtonFormField<String>(
              //   value: _selectedType,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //       borderSide: const BorderSide(
              //         color: Color.fromRGBO(
              //             101, 19, 116, 1), // Customize border color
              //         width: 2, // Customize border width
              //       ),
              //     ),
              //   ),
              //   items: _typeOptions.map((String typeOptions) {
              //     return DropdownMenuItem<String>(
              //       value: typeOptions,
              //       child: Text(typeOptions),
              //     );
              //   }).toList(),
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedType = newValue;
              //     });
              //   },
              // ),
              // DropdownButtonFormField<String>(
              //   value:
              //       _typeOptions.contains(_selectedType) ? _selectedType : null,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   items: _typeOptions.map((String typeOptions) {
              //     return DropdownMenuItem<String>(
              //       value: typeOptions,
              //       child: Text(typeOptions),
              //     );
              //   }).toList(),
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedType = newValue;
              //     });
              //   },
              // ),
              DropdownButtonFormField<String>(
                value: _quotaOptions.contains(_selectedType)
                    ? _selectedType
                    : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _quotaOptions.map((String quota) {
                  return DropdownMenuItem<String>(
                    value: quota,
                    child: Text(quota),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isReasonEmpty
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
                      _isReasonEmpty ? 'Tolong Masukan Alasan Anda' : null,
                ),
                onChanged: (value) {
                  setState(() {
                    Reason = value;
                    _isReasonEmpty = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal mulai',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isStartDateEmpty
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
                    errorText: _isStartDateEmpty
                        ? 'Tolong Isi Tanggal Masuk'
                        : null, // Error message
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
                      const Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Akhir',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 101, 19, 116)),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .always, // Always show label on top
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isEndDateEmpty
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
                    errorText: _isEndDateEmpty
                        ? 'Tolong Isi Tanggal Akhir'
                        : null, // Error message
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedEndDate == null
                            ? 'Select Start Date'
                            : DateFormat('yyyy-MM-dd')
                                .format(_selectedEndDate!),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_isQuotaEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _quotaWarning,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Pastikan semua input sudah diisi
                    if (_selectedStartDate == null) {
                      setState(() {
                        _isStartDateEmpty = true;
                      });
                    }
                    if (_selectedEndDate == null) {
                      setState(() {
                        _isEndDateEmpty = true;
                      });
                    }
                    if (Reason.isEmpty) {
                      setState(() {
                        _isReasonEmpty = true;
                      });
                    }
                    if (_quotaOptions.isEmpty) {
                      setState(() {
                        _isQuotaEmpty = true;
                      });
                    }

                    // Jika ada input yang belum diisi, jangan lanjutkan
                    if (_isStartDateEmpty ||
                        _isEndDateEmpty ||
                        _isReasonEmpty ||
                        _isQuotaEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete all required fields.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Jika semua input valid, kirim data
                    await _submitData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
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
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
