import 'package:flutter/material.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  _HydrationScreenState createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _currentIntake =
      1200; // Initial value (can later be fetched from database)
  final int _dailyGoal = 2000;

  void _addWater(int ml) {
    setState(() {
      _currentIntake += ml;
      if (_currentIntake > _dailyGoal) _currentIntake = _dailyGoal;
    });
  }

  void _resetIntake() {
    setState(() {
      _currentIntake = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _currentIntake / _dailyGoal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('Hydration Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Today\'s Water Intake',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '$_currentIntake ml / $_dailyGoal ml',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            SizedBox(height: 30),
            Text(
              'Quick Add',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 15,
              children: [
                ElevatedButton(
                  onPressed: () => _addWater(100),
                  child: Text('+100 ml'),
                ),
                ElevatedButton(
                  onPressed: () => _addWater(200),
                  child: Text('+200 ml'),
                ),
                ElevatedButton(
                  onPressed: () => _addWater(300),
                  child: Text('+300 ml'),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _resetIntake,
              icon: Icon(Icons.refresh),
              label: Text('Reset Intake'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
