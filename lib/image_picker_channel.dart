import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isLupaClockOut = false;
  List<dynamic> lupaClockOutList = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final url = Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-lupa');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] = 'Bearer ${localStorage.getString('token')}';
      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        isLupaClockOut = data['lupa'];
        lupaClockOutList = data['data'] ?? [];
      });
    } catch (e) {
      print("Error mengecek status clock-in: $e");
    }
  }

  void _showLupaClockOutModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lupa Clock Out", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: lupaClockOutList.isNotEmpty
                      ? ListView.builder(
                          itemCount: lupaClockOutList.length,
                          itemBuilder: (context, index) {
                            var item = lupaClockOutList[index];
                            String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(item['date']));
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text("Belum Clock Out"),
                                subtitle: Text(formattedDate),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/clockoutlupa');
                                  },
                                  child: Text("Clock Out"),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(child: Text("Tidak ada data lupa clock out")),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: _showLupaClockOutModal,
              child: Text("Lupa Clock Out", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}