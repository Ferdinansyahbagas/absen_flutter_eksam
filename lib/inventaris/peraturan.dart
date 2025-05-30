import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PeraturanScreen extends StatefulWidget {
  @override
  _PeraturanScreenState createState() => _PeraturanScreenState();
}

class _PeraturanScreenState extends State<PeraturanScreen> {
  bool isLoading = true;
  List<dynamic> peraturanList = [];

  @override
  void initState() {
    super.initState();
    fetchPeraturan();
  }

  Future<void> fetchPeraturan() async {
    final url =
        Uri.parse('https://portal.eksam.cloud/api/v1/other/get-rule-parameter');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('Token tidak ditemukan!');
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          peraturanList = data['data'];
          isLoading = false;
        });
      } else {
        print('Gagal mengambil data peraturan: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peraturan Karyawan Eksam'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : peraturanList.isEmpty
              ? Center(
                  child: Text(
                    "Tidak ada peraturan untuk hari ini",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: peraturanList.length,
                  itemBuilder: (context, index) {
                    final item = peraturanList[index];
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Html(
                                data: item['peraturan'] ?? 'Tanpa Judul',
                                style: {
                                  "body": Style(
                                    textAlign: TextAlign.left,
                                    fontSize: FontSize(16.0),
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 101, 19, 116),
                                  ),
                                },
                              ),
                              SizedBox(height: 8),
                              // Html(
                              //   data: item['deskripsi'] ?? '-',
                              //   style: {
                              //     "body": Style(
                              //       textAlign: TextAlign.left,
                              //       fontSize: FontSize(16.0),
                              //       fontWeight: FontWeight.normal,
                              //       color: Colors.black87,
                              //     ),
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
