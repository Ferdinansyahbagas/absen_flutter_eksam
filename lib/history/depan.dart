//jangan lupa ganti nama filenya
import 'package:flutter/material.dart';
import 'package:absen/homepage/home.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ); // Handle back button press
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Work Entry
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Total Work Entry',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('134 Days',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 10),
                  Text('Your Total Hours Work:',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('8 Hours 10 Minutes',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Late Work Entry
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You\'re Late for Work In Total',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('34 Days',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 10),
                  Text('Total Hours You\'re Late:',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('250 Minutes', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Call History Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16.0)),
                onPressed: () {
                  // Handle calling history functionality
                },
                child: const Text('Call Your History'),
              ),
            ),

            const SizedBox(height: 20),

            // Attendance History List
            Expanded(
              child: AttendanceList(),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceList extends StatefulWidget {
  const AttendanceList({super.key});

  @override
  _AttendanceListState createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  final List<Map<String, String>> attendanceData = [
    {
      'date': '12/10/2024',
      'workTime': '10:23 AM - 11:52 PM',
      'status': 'Present',
      'note': 'Good work | Complete tasks well',
    },
    {
      'date': '11/10/2024',
      'workTime': '9:50 AM - 5:30 PM',
      'status': 'Late',
      'note': 'Arrived late due to traffic',
    },
    {
      'date': '10/10/2024',
      'workTime': '8:00 AM - 4:00 PM',
      'status': 'Present',
      'note': 'Meeting and project work',
    },
  ];

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter
        Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: selectedFilter,
              items: ['All', 'Present', 'Late', 'Absent'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedFilter = newValue!;
                });
              },
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: attendanceData.length,
            itemBuilder: (context, index) {
              return AttendanceCard(
                data: attendanceData[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceDetailsScreen(
                        data: attendanceData[index],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onTap;

  const AttendanceCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(data['date']!),
        subtitle: Text(data['workTime']!),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
          onPressed: onTap,
          child: const Text('Open'),
        ),
      ),
    );
  }
}

class AttendanceDetailsScreen extends StatelessWidget {
  final Map<String, String> data;

  const AttendanceDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.purple,
        leading: const Icon(Icons.arrow_back),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${data['date']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Clock In', '10:23 AM'),
            _buildInfoRow('Clock Out', '11:52 PM'),
            _buildInfoRow('Work Duration', '8 Hours 10 Minutes'),
            _buildInfoRow('Late Duration', '-5 Minutes'),
            _buildInfoRow('Location', 'Office'),
            _buildInfoRow('Status', data['status']!),
            _buildInfoRow('Note', data['note']!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
