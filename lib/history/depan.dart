import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absen/Jamkelumas/ClockoutLupa.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String day = '';
  String menit = '';
  String Totalday = '';
  String menitTelat = '';
  String? lastClockOutDate;
  List<dynamic> lupaClockOutList = [];
  // bool isClockedIn = false;
  // bool hasClockedOut = false;
  bool isLupaClockOut = false; // Tambahkan variabel untuk cek lupa clock out

  @override
  void initState() {
    super.initState();
    getMenit();
    getData();
    getHistoryData;
  }

  Future<void> getData() async {
    // Cek status clock-in
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/attendance/is-lupa');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        isLupaClockOut = data['lupa']; // Ambil status lupa dari API
        // lastClockOutDate = data['data']['date']; // Ambil tanggal dari API

        // if (lastClockOutDate != null) {
        //   DateTime parsedDate = DateTime.parse(lastClockOutDate!);
        //   lastClockOutDate =
        //       DateFormat('dd MMM yyyy').format(parsedDate); // Format tanggal
        // }
        lupaClockOutList = data['data'] is List ? data['data'] : [];
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
                Text("Lupa Clock Out",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: lupaClockOutList.isNotEmpty
                      ? ListView.builder(
                          itemCount: lupaClockOutList.length,
                          itemBuilder: (context, index) {
                            var item = lupaClockOutList[index];
                            String formattedDate = DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(item['date']));
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text("Belum Clock Out"),
                                subtitle: Text(formattedDate),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ClockOutLupaScreen()));
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

// total telat api
  Future<void> getMenit() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/karyawan/get-user-info');

      var request = http.MultipartRequest('GET', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (response.statusCode == 200) {
        print("Successfully retrieved data");
        print(data);
        print(data['data']['menit'].toString());
        print(data['data']['hari'].toString());

        setState(() {
          menit = data['data']['menit'].toString();
          day = data['data']['hari'].toString();
          menitTelat = data['data']['menit_telat'].toString();
          Totalday = data['data']['telat'].toString();
        });

        print("test");
        print(menit);
      } else {
        print("Error fetching data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // fungsi untuk ngambil api history
  void getHistoryData(BuildContext context) async {
    try {
      final url = Uri.parse(
          'https://portal.eksam.cloud/api/v1/attendance/get-self-all');

      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (response.statusCode == 200) {
        print("Successfully retrieved data");

        List historyData = data['data'];

        for (var i = 0; i <= historyData.length - 1; i++) {
          if (historyData[i]['endtime'] == null) {
            historyData[i]['endtime'] = "-";
          }
          if (historyData[i]['starttime'] == null) {
            historyData[i]['starttime'] = "-";
          }
          if (historyData[i]['duration'] == null) {
            historyData[i]['duration'] = "-";
          }
          if (historyData[i]['notes'] == null) {
            historyData[i]['notes'] = "-";
          }
        }

        _onCheckHistoryPressed(context, historyData);
      } else {
        print("Error fetching data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _onCheckHistoryPressed(BuildContext context, List historyData) {
    TextEditingController searchController = TextEditingController();
    List filteredData = List.from(historyData);

    void filterData(int days) {
      DateTime today = DateTime.now();
      filteredData = historyData.where((item) {
        DateTime itemDate = DateTime.parse(item['date']);
        return today.difference(itemDate).inDays <= days;
      }).toList();
    }

    void searchHistory(String query) {
      filteredData = historyData.where((item) {
        return item['date'].contains(query) ||
            item['location']['name']
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['status']['name']
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['notes'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 101, 19, 116)),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: TextField(
                                          controller: searchController,
                                          decoration: const InputDecoration(
                                            hintText: 'Search',
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (query) {
                                            setState(() {
                                              searchHistory(query);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.search,
                                          color: Colors.orange),
                                      onPressed: () {
                                        setState(() {
                                          searchHistory(searchController.text);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 101, 19, 116)),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: PopupMenuButton<int>(
                                onSelected: (value) {
                                  setState(() {
                                    filterData(value);
                                  });
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<int>>[
                                  const PopupMenuItem<int>(
                                    value: 10,
                                    child: Text(
                                      'in the last 10 days',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 25,
                                    child: Text(
                                      'in the last 25 days',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 50,
                                    child: Text(
                                      'in the last 50 days',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 100,
                                    child: Text(
                                      'in the last 100 days',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Filter',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 101, 19, 116),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        var historyItem = filteredData[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(color: Colors.orange),
                          ),
                          child: ListTile(
                            title: Text(
                              historyItem['date'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${historyItem['starttime']} - ${historyItem['endtime']}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16.0)),
                                  ),
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: const EdgeInsets.all(16.0),
                                      width: double.infinity, // Full lebar
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.50, // Atur tinggi sesuai kebutuhan
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Tampilkan informasi attendance seperti di gambar
                                          Row(children: [
                                            const Text(
                                              "Date",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(
                                                width: 10), // Jarak horizontal
                                            Text(
                                              historyItem['date'],
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ]),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              const Text(
                                                "Clock In ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                              const SizedBox(width: 50),
                                              Text(
                                                '${historyItem['starttime']} AM',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Clock Out ",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      40), // Jarak horizontal
                                              Text(
                                                '${historyItem['endtime']} PM',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Work Duration",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      16), // Jarak horizontal

                                              Text(
                                                '${historyItem['duration']} Menit',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Location ",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      48), // Jarak horizontal

                                              Text(
                                                historyItem['location']['name'],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Status",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      66), // Jarak horizontal

                                              Text(
                                                historyItem['status']['name'],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Type",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      75), // Jarak horizontal
                                              Text(
                                                historyItem['type']['name'],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Geolocation",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      30), // Jarak horizontal

                                              Text(
                                                historyItem['geolocation'],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "Note",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(
                                              width: 10), // Jarak horizontal

                                          Text(
                                            historyItem['notes'],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange,
                                side: const BorderSide(
                                    color: Color.fromARGB(255, 101, 19, 116)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Open',
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance History',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                title: "Total Masuk Kerja Anda",
                value: '$day Days',
                color: Colors.orange,
              ),
              _buildSubtitleCard(
                subtitle: "Total Jam Kerja Anda",
                subtitleValue: '$menit Minutes',
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: "Anda Terlambat Kerja Secara Total",
                value: "$Totalday Days",
                color: Colors.orange,
              ),
              _buildSubtitleCard(
                subtitle: "Total Jam Anda Terlambat Masuk Kerja",
                subtitleValue: "$menitTelat Minutes",
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: _showLupaClockOutModal,
                child: Text("Lupa Clock Out",
                    style: TextStyle(color: Colors.white)),
              ),
              // if (isLupaClockOut && lastClockOutDate != null)
              //   Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.all(16.0),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(12.0),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.grey.withOpacity(0.3),
              //           spreadRadius: 2,
              //           blurRadius: 5,
              //           offset: const Offset(0, 3),
              //         ),
              //       ],
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Text(
              //           "Anda belum clock out di tanggal:",
              //           style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              //           textAlign: TextAlign.center,
              //         ),
              //         const SizedBox(height: 10),
              //         Text(
              //           lastClockOutDate!,
              //           style: const TextStyle(
              //             fontSize: 22,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.black,
              //           ),
              //         ),
              //         const SizedBox(height: 20),
              //         ElevatedButton(
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: Colors.orange,
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 40, vertical: 12),
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(8),
              //             ),
              //           ),
              //           onPressed: () {
              //             Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) => ClockOutLupaScreen()),
              //             );
              //           },
              //           child: const Text(
              //             "Clock Out Sekarang",
              //             style: TextStyle(fontSize: 16, color: Colors.white),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              const SizedBox(height: 150),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 101, 19, 116),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80.0, vertical: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () => getHistoryData(context),
                  child: const Text(
                    'Cek History Anda',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 132.0, // Disesuaikan dengan gambar
      width: double.infinity, // Full lebar
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleCard({
    required String subtitle,
    required String subtitleValue,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.pink, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Text(
            subtitleValue,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceDetailModal extends StatelessWidget {
  final String date;
  final String clockIn;
  final String clockOut;
  final String workDuration;
  final String location;
  final String status;
  final String note;

  const AttendanceDetailModal({
    super.key,
    required this.date,
    required this.clockIn,
    required this.clockOut,
    required this.workDuration,
    required this.location,
    required this.status,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Details"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date: $date",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Clock In: $clockIn"),
            Text("Clock Out: $clockOut"),
            Text("Work Duration: $workDuration"),
            Text("Location: $location"),
            Text("Status: $status"),
            const SizedBox(height: 16),
            const Text("Note:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(note),
          ],
        ),
      ),
    );
  }
}
