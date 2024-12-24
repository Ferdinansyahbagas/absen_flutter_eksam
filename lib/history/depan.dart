import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String menit = '';
  String day = '';

  @override
  void initState() {
    super.initState();
    getMenit();
    getHistoryData;
  }

  // Function to fetch history data from the API
  void getHistoryData(BuildContext context) async {
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/attendance/get-self-all');

      var request = http.MultipartRequest('POST', url);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      if (response.statusCode == 200) {
        print("Successfully retrieved data");

        List historyData =
            data['data']; // Assuming 'data' contains the list of history

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

        // Navigate to bottom sheet with the fetched data
        _onCheckHistoryPressed(context, historyData);
      } else {
        print("Error fetching data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getMenit() async {
    try {
      final url = Uri.parse(
          'https://dev-portal.eksam.cloud/api/v1/attendance/get-work-hour');

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
        });

        print("test");
        print(menit);

        // Navigate to bottom sheet with the fetched data
      } else {
        print("Error fetching data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

// Function to show the bottom sheet with attendance history
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
      shape: RoundedRectangleBorder(
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
                                          decoration: InputDecoration(
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
                                      icon: Icon(Icons.search,
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
                            SizedBox(width: 10),
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
                                  PopupMenuItem<int>(
                                    value: 10,
                                    child: Text(
                                      'in the last 10 days',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 25,
                                    child: Text(
                                      'in the last 25 days',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 50,
                                    child: Text(
                                      'in the last 50 days',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem<int>(
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Filter',
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 101, 19, 116),
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
                            side: BorderSide(color: Colors.orange),
                          ),
                          child: ListTile(
                            title: Text(
                              historyItem['date'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${historyItem['starttime']} - ${historyItem['endtime']}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
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
                                          0.40, // Atur tinggi sesuai kebutuhan
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Tampilkan informasi attendance seperti di gambar
                                          Row(children: [
                                            Text(
                                              "Date",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                                width: 10), // Jarak horizontal
                                            Text(
                                              historyItem['date'],
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ]),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              Text(
                                                "Clock In ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                              SizedBox(
                                                  width:
                                                      50), // Jarak horizontal

                                              Text(
                                                '${historyItem['starttime']} AM',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Clock Out ",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              SizedBox(
                                                  width:
                                                      40), // Jarak horizontal
                                              Text(
                                                '${historyItem['endtime']} PM',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Work Duration",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              SizedBox(
                                                  width:
                                                      15), // Jarak horizontal

                                              Text(
                                                '${historyItem['duration']} Menit',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Location ",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              SizedBox(
                                                  width:
                                                      48), // Jarak horizontal

                                              Text(
                                                historyItem['location']['name'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Status",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                              SizedBox(
                                                  width:
                                                      66), // Jarak horizontal

                                              Text(
                                                historyItem['status']['name'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Note",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          ),
                                          SizedBox(
                                              width: 10), // Jarak horizontal

                                          Text(
                                            historyItem['notes'],
                                            style: TextStyle(
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
                                side: BorderSide(
                                    color: const Color.fromARGB(
                                        255, 101, 19, 116)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              title: "Your Total Work Entry",
              value: '$day Days',
              color: Colors.orange,
            ),
            _buildSubtitleCard(
              subtitle: "Your Total Hours Work",
              subtitleValue: '$menit Minutes',
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "You're Late For Work In Total",
              value: "34 Days",
              color: Colors.orange,
            ),
            _buildSubtitleCard(
              subtitle: "Total Hours You're Late For Work",
              subtitleValue: "2316 Minutes",
            ),
            const SizedBox(height: 160),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 101, 19, 116),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100.0, vertical: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => getHistoryData(context),
                child: const Text(
                  'Cek Your History',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
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
              fontSize: 14.0,
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
    Key? key,
    required this.date,
    required this.clockIn,
    required this.clockOut,
    required this.workDuration,
    required this.location,
    required this.status,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Details"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date: $date",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("Clock In: $clockIn"),
            Text("Clock Out: $clockOut"),
            Text("Work Duration: $workDuration"),
            Text("Location: $location"),
            Text("Status: $status"),
            SizedBox(height: 16),
            Text("Note:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(note),
          ],
        ),
      ),
    );
  }
}
