import 'package:flutter/material.dart';
import '../models/doctor.dart';
import 'doctor_chat_screen.dart';

class SelectDoctorScreen extends StatefulWidget {
  final List<Doctor> doctors;

  const SelectDoctorScreen({super.key, required this.doctors});

  @override
  State<SelectDoctorScreen> createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  bool sortDescending = false;
  List<Doctor> sortedDoctors = [];

  @override
  void initState() {
    super.initState();
    sortedDoctors = List.from(widget.doctors);
    _sortDoctors();
  }

  void _sortDoctors() {
    sortedDoctors.sort((a, b) {
      return sortDescending
          ? b.name.toLowerCase().compareTo(a.name.toLowerCase())
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Doctor"),
        actions: [
          Row(
            children: [
              const Text(
                'Sort by: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    sortDescending = !sortDescending;
                    _sortDoctors();
                  });
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedDoctors.length,
        itemBuilder: (context, index) {
          final doctor = sortedDoctors[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(doctor.imageUrl),
                radius: 25,
              ),
              title: Text(doctor.name),
              subtitle: Text(doctor.specialization),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorChatScreen(doctor: doctor),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
