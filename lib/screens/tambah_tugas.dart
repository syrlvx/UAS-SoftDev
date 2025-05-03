import 'package:flutter/material.dart';
import 'package:purelux/screens/tugas_admin.dart';
import 'package:purelux/widgets/bottom_nav_bar_admin.dart';

class TambahTugasScreen extends StatefulWidget {
  const TambahTugasScreen({Key? key}) : super(key: key);

  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  String selectedCategory = 'Development';
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay(hour: 10, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 11, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomNavBarAdmin()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create New Task",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Task Name", style: TextStyle(color: Colors.blue)),
              const TextField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: ' ',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Select Category",
                  style: TextStyle(color: Colors.blue)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  _categoryChip('Development'),
                  _categoryChip('Research'),
                  _categoryChip('Design'),
                  _categoryChip('Backend'),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Date", style: TextStyle(color: Colors.blue)),
              InkWell(
                onTap: _selectDate,
                child: Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Start time",
                          style: TextStyle(color: Colors.blue)),
                      InkWell(
                        onTap: _selectStartTime,
                        child: Text(
                          startTime.format(context),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("End time",
                          style: TextStyle(color: Colors.blue)),
                      InkWell(
                        onTap: _selectEndTime,
                        child: Text(
                          endTime.format(context),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text("Create Task",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedCategory == label,
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = label;
        });
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.blue[50],
      labelStyle: TextStyle(
        color: selectedCategory == label ? Colors.white : Colors.blue,
      ),
    );
  }

  // Function to show date picker and update selected date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to show start time picker and update selected start time
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
      });
    }
  }

  // Function to show end time picker and update selected end time
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
      });
    }
  }
}
