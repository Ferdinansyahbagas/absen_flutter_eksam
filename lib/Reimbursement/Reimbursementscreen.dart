import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:absen/Reimbursement/requestReimbursement.dart';

class ReimbursementPage extends StatefulWidget {
  @override
  _ReimbursementPageState createState() => _ReimbursementPageState();
}

class _ReimbursementPageState extends State<ReimbursementPage> {
  List<dynamic> historyData = [];

  @override
  void initState() {
    super.initState();
    getHistoryData();
  }

  Future<void> getHistoryData() async {
    final url = Uri.parse(
        'https://dev-portal.eksam.cloud/api/v1/request-history/show-history');
    var request = http.MultipartRequest('POST', url);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    request.headers['Authorization'] =
        'Bearer ${localStorage.getString('token')}';

    try {
      var response = await request.send();
      var rp = await http.Response.fromStream(response);

      if (rp.statusCode == 200) {
        var data = jsonDecode(rp.body);
        setState(() {
          historyData = data['data'] ?? [];
        });
      } else {
        print('Error fetching history data: ${rp.statusCode}');
        print(rp.body);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reimbursement'),
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ReimbursementForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Request Reimbursement',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'History Time Off',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                return ReimbursementHistoryCard(
                  title: item['category']?.toString() ?? 'Unknown',
                  amount: item['amount']?.toString() ?? 'Unknown',
                  statusText: item['status']?.toString() ?? 'Unknown',
                  statusColor:
                      _getStatusColor(item['status']?.toString() ?? 'Unknown'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submission':
        return Colors.pink;
      case 'submission accepted':
        return Colors.green;
      case 'submission rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ReimbursementHistoryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String statusText;
  final Color statusColor;

  ReimbursementHistoryCard({
    required this.title,
    required this.amount,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    amount,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
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
