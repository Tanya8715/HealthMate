import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<bool> _checkIfSlotBooked(DateTime appointmentDateTime) async {
    final snapshot =
        await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: widget.doctor.id)
            .where(
              'appointmentDate',
              isEqualTo:
                  "${appointmentDateTime.year}-${appointmentDateTime.month.toString().padLeft(2, '0')}-${appointmentDateTime.day.toString().padLeft(2, '0')}",
            )
            .where(
              'appointmentTime',
              isEqualTo:
                  "${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}",
            )
            .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _bookAppointment() async {
    if (selectedDate == null || selectedTime == null) return;
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        setState(() => isLoading = false);
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName =
          userDoc.exists ? (userDoc.data()?['name'] ?? 'Unknown') : 'Unknown';

      final appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final alreadyBooked = await _checkIfSlotBooked(appointmentDateTime);

      if (alreadyBooked) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ Appointment already booked for this time. Please choose another time.',
            ),
          ),
        );
        return;
      }

      await _firestore.collection('appointments').add({
        'doctorId': widget.doctor.id,
        'doctorName': widget.doctor.name,
        'doctorSpecialization': widget.doctor.specialization,
        'userId': user.uid,
        'userName': userName,
        'appointmentDate':
            "${appointmentDateTime.year}-${appointmentDateTime.month.toString().padLeft(2, '0')}-${appointmentDateTime.day.toString().padLeft(2, '0')}",
        'appointmentTime':
            "${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}",
        'createdAt': DateTime.now().toIso8601String(),
      });

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Appointment booked successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error booking appointment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentSelected = selectedDate != null && selectedTime != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: Colors.green.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Doctor: Dr. ${widget.doctor.name}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Specialization: ${widget.doctor.specialization}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDate == null
                    ? 'Select Date'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.access_time),
              label: Text(
                selectedTime == null
                    ? 'Select Time'
                    : selectedTime!.format(context),
              ),
            ),
            const SizedBox(height: 30),
            if (appointmentSelected)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                          : const Text("Confirm Appointment"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
