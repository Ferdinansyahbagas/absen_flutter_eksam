import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PeraturanScreen extends StatefulWidget {
  @override
  _PeraturanScreenState createState() => _PeraturanScreenState();
}

class _PeraturanScreenState extends State<PeraturanScreen> {
  List<dynamic> peraturanList = [];
  bool isLoading = true;

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
          peraturanList = data['data']; // sesuai respons Laravel
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
                          Center(
                            child: Html(
                              data: item['peraturan'] ?? 'Tanpa Judul',
                              style: {
                                "body": Style(
                                  textAlign: TextAlign.center,
                                  fontSize: FontSize(16.0),
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 101, 19, 116),
                                ),
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: Html(
                              data: item['deskripsi'] ?? '-',
                              style: {
                                "body": Style(
                                  textAlign: TextAlign.center,
                                  fontSize: FontSize(16.0),
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 101, 19, 116),
                                ),
                              },
                            ),
                          ),
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
