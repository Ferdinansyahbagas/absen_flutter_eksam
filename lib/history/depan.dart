import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  void _onCheckHistoryPressed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.purple),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.search, color: Colors.orange),
                                onPressed: () {
                                  // Tambahkan fungsi pencarian di sini
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
                          border: Border.all(color: Colors.purple),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: PopupMenuButton<int>(
                          onSelected: (value) {
                            // Tambahkan fungsi filter di sini
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<int>>[
                            PopupMenuItem<int>(
                              value: 10,
                              child: Text('in the last 10 days'),
                            ),
                            PopupMenuItem<int>(
                              value: 25,
                              child: Text('in the last 25 days'),
                            ),
                            PopupMenuItem<int>(
                              value: 50,
                              child: Text('in the last 50 days'),
                            ),
                            PopupMenuItem<int>(
                              value: 100,
                              child: Text('in the last 100 days'),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                Text('Filter',
                                    style: TextStyle(color: Colors.purple)),
                                Icon(Icons.arrow_drop_down,
                                    color: Colors.purple),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.orange),
                        ),
                        child: ListTile(
                          title: Text(
                            '12/10/2024',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('10:20:32 AM - 15:23:10 PM'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AttendanceDetailScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.orange,
                              side: BorderSide(color: Colors.purple),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Open',
                              style: TextStyle(
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
              value: "134 Days",
              subtitle: "Your Total Hours Work",
              subtitleValue: "8 hours 16 minutes",
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            _buildCard(
              title: "You're Late For Work In Total",
              value: "34 Days",
              subtitle: "Total Hours You're Late For Work",
              subtitleValue: "2316 minutes",
              color: Colors.orange,
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 110.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => _onCheckHistoryPressed(context),
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
    required String subtitle,
    required String subtitleValue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  subtitleValue,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceDetailScreen extends StatelessWidget {
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
              "Date: 12/10/2024",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("Clock In: 10:20:32 AM"),
            Text("Clock Out: 15:23:10 PM"),
            Text("Work Duration: 8 Hours 15 Minutes"),
            Text("Late Duration: -15 Minutes"),
            Text("Location: Office"),
            Text("Status: Lembur"),
            SizedBox(height: 16),
            Text("Note:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Good work, I complete tasks well"),
          ],
        ),
      ),
    );
  }
}
