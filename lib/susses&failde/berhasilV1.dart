//Clock In and Out SuccessPage
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Package to format the date and time
import 'package:absen/homepage/home.dart';

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get current date and time
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMMM yyyy').format(now);
    String formattedTime = DateFormat('hh:mm:ss a')
        .format(now); // Updated to 12-hour format with AM/PM

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange,
              Colors.pink,
              const Color.fromARGB(255, 101, 19, 116),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 150),
              Text(
                'Your Absence Was',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Successful✨​ ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Great, now You Can Start Working 👍​',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 200),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 130, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  ); // Action when back to menu button is pressed
                },
                child: Text('Back To Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
