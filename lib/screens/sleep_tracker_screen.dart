import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;
  double sleepHours = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? reminderTimer;

  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  Future<void> calculateAndSaveSleep() async {
    if (sleepTime == null || wakeTime == null) return;

    final now = DateTime.now();
    DateTime sleepDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      sleepTime!.hour,
      sleepTime!.minute,
    );
    DateTime wakeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      wakeTime!.hour,
      wakeTime!.minute,
    );

    if (wakeDateTime.isBefore(sleepDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }

    final duration = wakeDateTime.difference(sleepDateTime);
    setState(() {
      sleepHours = duration.inMinutes / 60.0;
    });

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'sleepHours': sleepHours,
      });
    }

    if (sleepHours < 8) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Not Enough Sleep'),
              content: const Text(
                'It’s recommended to sleep at least 8 hours.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Okay'),
                ),
              ],
            ),
      );
    }

    reminderTimer?.cancel();

    final reminderTime = sleepDateTime.subtract(const Duration(minutes: 1));
    final delay = reminderTime.difference(DateTime.now());

    if (!delay.isNegative) {
      reminderTimer = Timer(delay, () {
        if (!mounted) return;
        showSleepReminder();
      });
    }
  }

  void showSleepReminder() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Time to Sleep'),
            content: const Text('Do you want to go to sleep now?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  pickTime(isSleepTime: true);
                },
                child: const Text('Change Time'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  startSleepTimer();
                },
                child: const Text('Sleep Now'),
              ),
            ],
          ),
    );
  }

  void startSleepTimer() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userId = user.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            'title': 'Sleep Tracking Started',
            'message': 'You started sleep tracking. Have a good night!',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep tracking started. Good night!')),
    );
  }

  Future<void> pickTime({required bool isSleepTime}) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.black,
              dayPeriodTextColor: Colors.black,
              dialHandColor: Colors.green,
            ),
            colorScheme: const ColorScheme.light(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          sleepTime = picked;
        } else {
          wakeTime = picked;
        }
      });
      await calculateAndSaveSleep();
    }
  }

  void resetSleepTracker() async {
    reminderTimer?.cancel();

    setState(() {
      sleepTime = null;
      wakeTime = null;
      sleepHours = 0;
    });

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'sleepHours': 0,
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sleep tracker reset.')));
  }

  @override
  void dispose() {
    reminderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Sleep Tracker',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[600],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetSleepTracker,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.nightlight_round,
                  color: Colors.green,
                ),
                title: const Text("Sleep Time"),
                trailing: Text(
                  formatTimeOfDay(sleepTime),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => pickTime(isSleepTime: true),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.wb_sunny, color: Colors.orange),
                title: const Text("Wake Time"),
                trailing: Text(
                  formatTimeOfDay(wakeTime),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => pickTime(isSleepTime: false),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Sleep Duration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${sleepHours.toStringAsFixed(2)} hours',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
