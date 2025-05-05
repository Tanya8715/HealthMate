import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StepCountPage extends StatefulWidget {
  const StepCountPage({super.key});

  @override
  _StepCountPageState createState() => _StepCountPageState();
}

class _StepCountPageState extends State<StepCountPage> {
  int _steps = 0;
  late StreamSubscription<StepCount> _stepCountStreamSubscription;
  final int _stepGoal = 10000; // 🎯 Updated step goal to 10,000
  bool _isTesting = false;
  bool _goalAchieved = false; // 👈 Track if popup already shown

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startStepCounting();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      await Permission.activityRecognition.request();
    }
  }

  void _startStepCounting() {
    _stepCountStreamSubscription = Pedometer.stepCountStream.listen(
      (StepCount stepCount) {
        if (!_isTesting) {
          setState(() {
            _steps = stepCount.steps;
          });
          _saveSteps();
          _checkGoalAchievement();
        }
      },
      onError: (error) {
        print("Step Count Error: $error");
      },
      cancelOnError: true,
    );
  }

  Future<void> _saveSteps() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'steps': _steps});
      } catch (e) {
        print('Error saving steps: $e');
      }
    }
  }

  void _checkGoalAchievement() {
    if (_steps >= _stepGoal && !_goalAchieved) {
      _goalAchieved = true; // 👈 Mark as shown
      _showGoalAchievedPopup();
    }
  }

  void _showGoalAchievedPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 10), () async {
          if (mounted) {
            Navigator.of(context).pop(true);

            await _saveAchievementNotification(); // Save notification

            setState(() {
              _steps = 0; // Reset local steps
              _goalAchieved = false; // Reset goal flag
            });
          }
        });
        return AlertDialog(
          title: const Text('🎉 Congratulations!'),
          content: const Text(
            'You have achieved 10,000 steps today! Keep up the great work!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);

                await _saveAchievementNotification(); // Save notification

                setState(() {
                  _steps = 0;
                  _goalAchieved = false;
                });
              },
              child: const Text('Thanks!'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAchievementNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(
              'notifications',
            ) // ✅ inside notifications sub-collection
            .add({
              'title': 'Steps Goal Completed 🎯',
              'message': 'Congratulations! You achieved 10,000 steps!',
              'timestamp': FieldValue.serverTimestamp(),
              'stepsCompleted': 10000, // optional, good for tracking
            });
      } catch (e) {
        print('Error saving notification: $e');
      }
    }
  }

  @override
  void dispose() {
    _stepCountStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_steps / _stepGoal).clamp(0.0, 1.0);
    int percent = (progress * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Step Count Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 15,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.lightBlueAccent.shade700,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_steps / $_stepGoal steps',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _steps = 0;
                    _goalAchieved = false; // Reset goal achievement
                    _isTesting = false;
                  });
                  _saveSteps();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Refresh Steps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _steps += 100;
                    _isTesting = true;
                  });
                  _saveSteps();
                  _checkGoalAchievement(); // 👈 Check achievement after adding test steps
                },
                icon: const Icon(Icons.directions_walk, color: Colors.white),
                label: const Text('Add Test Steps +100'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
