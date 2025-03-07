import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:absen/susses&failde/berhasilV1.dart';
import 'package:absen/susses&failde/gagalV1.dart';

class ClockinwfaPage extends StatefulWidget {
  @override
  _ClockinwfaPageState createState() => _ClockinwfaPageState();
}

class _ClockinwfaPageState extends State<ClockinwfaPage> {
  DateTime? selectedDate;
  TextEditingController noteController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (selectedDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FailurePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clock Out")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Work Type"),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: "Reguler",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
              ),
            ),
            SizedBox(height: 10),
            Text("Workplace Type"),
            TextField(
              decoration: InputDecoration(
                enabled: false,
                hintText: "WFA",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 101, 19, 116)),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                child: Text(selectedDate == null
                    ? "Choose Date"
                    : DateFormat('dd MMMM yyyy').format(selectedDate!)),
              ),
            ),
            SizedBox(height: 10),
            Text("Note"),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your note",
              ),
            ),
            SizedBox(height: 120),
            Center(
              child: ElevatedButton(
                onPressed: _submit, // Call the function to submit data
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  iconColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 120,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
