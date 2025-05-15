import 'package:flutter/material.dart';
import 'package:absen/Jamkelumas/ClockoutLupa.dart';
import 'package:absen/Jamkelumas/Overtimeoutlupa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

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
  bool isLupaClockOut = false;
  List<dynamic> lupaClockOutList = [];
  List<dynamic> lupaovertimeOutList = [];

  @override
  void initState() {
    super.initState();
    getData();
    getMenit();
    getHistoryData;
    getDatalupaOvertime();
  }

  Future<void> getData() async {
    try {
      final url =
          Uri.parse('https://portal.eksam.cloud/api/v1/attendance/get-lupa');
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var request = http.MultipartRequest('GET', url);
      request.headers['Authorization'] =
          'Bearer ${localStorage.getString('token')}';

      var response = await request.send();
      var rp = await http.Response.fromStream(response);
      var data = jsonDecode(rp.body.toString());

      setState(() {
        isLupaClockOut = data['lupa']; // Ambil status lupa dari API
        lupaClockOutList = data['data'] ?? [];
      });
    } catch (e) {
      print("Error mengecek status clock-in: $e");
    }
  }

  Future<void> getDatalupaOvertime() async {
    final url = Uri.parse(
        'https://portal.eksam.cloud/api/v1/attendance/is-self-overtime-lupa');
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
          lupaovertimeOutList = data['data'] ?? [];
        });
      } else {
        print('Error fetching history data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _showLupaClockOutModal() async {
    await getData(); // ambil data lupa clock out
    await getDatalupaOvertime(); // ambil data lupa overtime

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        String selectedTab = 'lupaClockOut';

        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pilih Jenis Lupa",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ChoiceChip(
                          label: Text("Lupa Clock Out"),
                          selected: selectedTab == 'lupaClockOut',
                          onSelected: (val) {
                            setModalState(() {
                              selectedTab = 'lupaClockOut';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text("Lupa Overtime"),
                          selected: selectedTab == 'lupaOvertime',
                          onSelected: (val) {
                            setModalState(() {
                              selectedTab = 'lupaOvertime';
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: selectedTab == 'lupaClockOut'
                          ? _buildLupaClockOutList()
                          : _buildLupaOvertimeList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLupaClockOutList() {
    return lupaClockOutList.isNotEmpty
        ? ListView.builder(
            itemCount: lupaClockOutList.length,
            itemBuilder: (context, index) {
              var item = lupaClockOutList[index];
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(DateTime.parse(item['date']));
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
                              ClockOutLupaScreen(id: item['id'].toString()),
                        ),
                      );
                    },
                    child: Text("Clock Out"),
                  ),
                ),
              );
            },
          )
        : Center(child: Text("Tidak ada data lupa clock out"));
  }

  Widget _buildLupaOvertimeList() {
    return lupaovertimeOutList.isNotEmpty
        ? ListView.builder(
            itemCount: lupaovertimeOutList.length,
            itemBuilder: (context, index) {
              var item = lupaovertimeOutList[index];
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(DateTime.parse(item['date']));
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text("Belum Isi Lupa Overtime"),
                  subtitle: Text(formattedDate),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Overtimeoutlupa(id: item['id'].toString()),
                        ),
                      );
                    },
                    child: Text("Isi Overtime"),
                  ),
                ),
              );
            },
          )
        : Center(child: Text("Tidak ada data lupa overtime"));
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

  String formatTanggal(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  void _showDateFilterPopup(
      BuildContext context, Function(DateTime, DateTime) onFilter) {
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // START DATE Picker
                TextFormField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'START DATE',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon:
                        const Icon(Icons.calendar_today, color: Colors.purple),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900), // Mulai dari tahun 1900
                      lastDate: DateTime(2100), // Sampai tahun 2100
                    );
                    if (pickedDate != null) {
                      startDate = pickedDate;
                      startDateController.text =
                          formatTanggal(pickedDate.toIso8601String());
                      // Reset End Date jika Start Date diubah
                      endDate = null;
                      endDateController.clear();
                    }
                  },
                ),

                const SizedBox(height: 20),

                // END DATE Picker
                TextFormField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'END DATE',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon:
                        const Icon(Icons.calendar_today, color: Colors.purple),
                  ),
                  onTap: () async {
                    if (startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pilih Start Date terlebih dahulu')),
                      );
                      return;
                    }

                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(1900), // Mulai dari tahun 1900
                      lastDate: DateTime(2100), // Sampai tahun 2100
                    );
                    if (pickedDate != null) {
                      endDate = pickedDate;
                      endDateController.text =
                          formatTanggal(pickedDate.toIso8601String());
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (startDate != null && endDate != null) {
                          onFilter(startDate!, endDate!);
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Lengkapi Start Date dan End Date')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Text('Submit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCheckHistoryPressed(BuildContext context, List historyData) {
    // TextEditingController searchController = TextEditingController();
    List filteredData = List.from(historyData);

    void filterDataByDateRange(DateTime? startDate, DateTime? endDate) {
      if (startDate != null && endDate != null) {
        filteredData = historyData.where((item) {
          DateTime itemDate = DateTime.parse(item['date']);
          return itemDate
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              itemDate.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      } else {
        filteredData = List.from(historyData);
      }
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 101, 19, 116),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.purple),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showDateFilterPopup(context, (start, end) {
                                setState(() {
                                  filterDataByDateRange(start, end);
                                });
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Filter Date',
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.date_range,
                                    color: Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                              formatTanggal(historyItem['date']),
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
                                  isScrollControlled:
                                      true, // Biar modal bisa diperbesar sesuai isi
                                  builder: (BuildContext context) {
                                    return DraggableScrollableSheet(
                                      expand:
                                          false, // Biar bisa di-scroll tanpa full screen
                                      builder: (context, scrollController) {
                                        return Container(
                                          padding: const EdgeInsets.all(16.0),
                                          width: double.infinity, // Full lebar
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16.0)),
                                            color: Colors.white,
                                          ),
                                          child: SingleChildScrollView(
                                            controller:
                                                scrollController, // Scrollable content
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Date",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      formatTanggal(
                                                          historyItem['date']),
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 15),
                                                _buildRow(
                                                    "Clock In",
                                                    historyItem['starttime'] +
                                                        " AM"),
                                                _buildRow(
                                                    "Clock Out",
                                                    historyItem['endtime'] +
                                                        " PM"),
                                                _buildRow("Work Duration",
                                                    "${historyItem['duration']} Menit"),
                                                _buildRow(
                                                    "Location",
                                                    historyItem['location']
                                                        ['name']),
                                                _buildRow(
                                                    "Status",
                                                    historyItem['status']
                                                        ['name']),
                                                _buildRow(
                                                    "Type",
                                                    historyItem['type']
                                                        ['name']),
                                                _buildRow("Geolocation",
                                                    historyItem['geolocation']),
                                                const SizedBox(height: 10),
                                                const Text(
                                                  "Note",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  historyItem['notes'],
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
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

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Biar rata kiri-kanan
        children: [
          SizedBox(
            width: 120, // Atur lebar tetap untuk label
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(width: 10), // Jarak antara label dan isi
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, // Rata kanan untuk isi
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
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
              const SizedBox(height: 150),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 101, 19, 116),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: _showLupaClockOutModal,
                      child: const Text(
                        'Lupa Clock Out',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Jarak antar tombol
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 101, 19, 116),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
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
