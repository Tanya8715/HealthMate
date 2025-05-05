import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;
  double sleepHours = 0;
  Timer? reminderTimer;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      if (sleepHours < 4 || sleepHours > 12) {
        await _saveAbnormalSleepNotification();
        _showSleepResultDialog(isAbnormal: true);
      } else {
        _showSleepResultDialog(isAbnormal: false);
      }
    }
  }

  Future<void> _saveAbnormalSleepNotification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
            'message':
                '😴 Abnormal sleep detected: ${sleepHours.toStringAsFixed(1)} hrs',
            'timestamp': FieldValue.serverTimestamp(),
          });
    }
  }

  void _showSleepResultDialog({required bool isAbnormal}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isAbnormal ? '⚠️ Sleep Warning' : '✅ Sleep Success'),
            content: Text(
              isAbnormal
                  ? 'You had ${sleepHours.toStringAsFixed(1)} hrs of sleep, which is outside the healthy range.'
                  : 'Great! You slept ${sleepHours.toStringAsFixed(1)} hrs. Keep it up!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> startSleepReminderTimer() async {
    reminderTimer?.cancel();

    if (sleepTime == null) return;

    final now = DateTime.now();
    DateTime sleepDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      sleepTime!.hour,
      sleepTime!.minute,
    );

    if (sleepDateTime.isBefore(now)) {
      sleepDateTime = sleepDateTime.add(const Duration(days: 1));
    }

    final reminderTime = sleepDateTime.subtract(const Duration(minutes: 1));
    final diff = reminderTime.difference(now);

    if (diff.isNegative) {
      debugPrint(
        "Sleep reminder too close to current time. Skipping reminder.",
      );
      return;
    }

    debugPrint("Sleep reminder will trigger in: $diff");

    reminderTimer = Timer(diff, () async {
      if (mounted) await showSleepReminderPopup();
    });
  }

  Future<void> showSleepReminderPopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // ❗️Force user to press OK
      builder:
          (context) => AlertDialog(
            title: const Text('⏰ Sleep Reminder'),
            content: const Text(
              "It's almost time to sleep. Get ready to relax!",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
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
          startSleepReminderTimer(); // ⏰ Start the reminder timer here
        } else {
          wakeTime = picked;
        }
      });

      await calculateAndSaveSleep();
    }
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
                      'Total Sleep',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${sleepHours.toStringAsFixed(1)} hrs',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Center(
              child: Text(
                'Getting enough sleep is vital for your mental & physical health!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
