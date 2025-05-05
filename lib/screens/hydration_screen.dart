import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  _HydrationScreenState createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _currentIntake = 0;
  int _dailyWaterGoal = 2000; // Default 2L
  int _mlPerReminder = 250; // Default per reminder
  bool _isLoading = true;
  bool _goalAchieved = false; // 👈 flag to prevent multiple popups

  @override
  void initState() {
    super.initState();
    _fetchUserAndCalculateWater();
  }

  Future<void> _fetchUserAndCalculateWater() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        int weight = data['weight'] ?? 60;
        int height = data['height'] ?? 170;
        _dailyWaterGoal = _calculateDailyWaterGoal(weight, height);
        _mlPerReminder = (_dailyWaterGoal / 8).round();
        _currentIntake = data['waterIntake'] ?? 0;
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  int _calculateDailyWaterGoal(int weightKg, int heightCm) {
    int base = weightKg * 30;
    if (heightCm > 170) base += 300;
    return base;
  }

  Future<void> _saveWaterIntake() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'waterIntake': _currentIntake},
      );
    }
  }

  void _addWater(int ml) {
    setState(() {
      _currentIntake += ml;
      if (_currentIntake > _dailyWaterGoal) {
        _currentIntake = _dailyWaterGoal;
      }
    });
    _saveWaterIntake();
    _checkGoalAchievement();
  }

  void _resetIntake() {
    setState(() {
      _currentIntake = 0;
      _goalAchieved = false;
    });
    _saveWaterIntake();
  }

  void _checkGoalAchievement() {
    if (_currentIntake >= _dailyWaterGoal && !_goalAchieved) {
      _goalAchieved = true;
      _showGoalAchievedPopup();
    }
  }

  void _showGoalAchievedPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
        _saveHydrationAchievementNotification(); // 👈 Save notification
        return AlertDialog(
          title: const Text('🎉 Congratulations!'),
          content: const Text(
            'You have completed your daily water intake goal!\nStay hydrated and healthy!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Thanks!'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveHydrationAchievementNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
            'message': '🎉 You completed your daily water intake goal!',
            'timestamp': FieldValue.serverTimestamp(),
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double progress = _currentIntake / _dailyWaterGoal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Hydration Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Water Intake',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.local_drink, color: Colors.blue[700], size: 30),
                const SizedBox(width: 10),
                Text(
                  '${_currentIntake}ml / ${_dailyWaterGoal}ml',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Quick Add',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: List.generate(
                8,
                (index) =>
                    _buildAddWaterButton(_mlPerReminder, '+$_mlPerReminder ml'),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _resetIntake,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Reset Intake'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWaterButton(int ml, String label) {
    return ElevatedButton(
      onPressed: () => _addWater(ml),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
