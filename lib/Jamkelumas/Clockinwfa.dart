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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Clock In WFA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Work Type Dropdown
              const Text(
                'Work Type',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(101, 19, 116, 1)),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: "Reguler",
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                ),
                items: ["Reguler"].map((String workType) {
                  return DropdownMenuItem<String>(
                      value: workType, child: Text(workType));
                }).toList(),
                onChanged: null, // Disabled
              ),
              const SizedBox(height: 20),

              // Workplace Type Dropdown
              const Text(
                'Workplace Type',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(101, 19, 116, 1)),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: "WFA",
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                ),
                items: ["WFA"].map((String workplaceType) {
                  return DropdownMenuItem<String>(
                      value: workplaceType, child: Text(workplaceType));
                }).toList(),
                onChanged: null, // Disabled
              ),
              const SizedBox(height: 20),

              // Date Picker
              const Text(
                'Tanggal',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(101, 19, 116, 1)),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(101, 19, 116, 1), width: 2)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  child: Text(
                    selectedDate == null
                        ? "Choose Date"
                        : DateFormat('dd MMMM yyyy').format(selectedDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Note Field
              const Text(
                'Note',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(101, 19, 116, 1)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(101, 19, 116, 1))),
                  hintText: "Enter your note",
                ),
              ),
              const SizedBox(height: 120),

              // Submit Button
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
      ),
    );
  }
}
