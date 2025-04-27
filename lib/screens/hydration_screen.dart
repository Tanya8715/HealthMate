import 'package:flutter/material.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  _HydrationScreenState createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _currentIntake =
      1200; // Initial value (can later be fetched from database)
  final int _mlPerGlass = 250; // Milliliters per glass
  final int _dailyGoalGlasses = 8; // Daily goal in glasses

  // Function to add water in milliliters
  void _addWater(int ml) {
    setState(() {
      _currentIntake += ml;
      if (_currentIntake > _dailyGoalGlasses * _mlPerGlass) {
        _currentIntake = _dailyGoalGlasses * _mlPerGlass;
      }
    });
  }

  // Function to reset the water intake
  void _resetIntake() {
    setState(() {
      _currentIntake = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _currentIntake / (_dailyGoalGlasses * _mlPerGlass);
    int currentGlasses = (_currentIntake / _mlPerGlass).floor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('Hydration Tracker'),
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
            SizedBox(height: 20),
            // Displaying water intake in glasses instead of ml
            Row(
              children: [
                Icon(Icons.local_drink, color: Colors.blue[700], size: 30),
                SizedBox(width: 10),
                Text(
                  '$currentGlasses glasses / $_dailyGoalGlasses glasses',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Circular Progress Indicator for Hydration Progress
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
            SizedBox(height: 30),
            Text(
              'Quick Add',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            // Quick add buttons to add water in increments of glasses (ml)
            Wrap(
              spacing: 15,
              children: [
                _buildAddWaterButton(100, '+100 ml'),
                _buildAddWaterButton(200, '+200 ml'),
                _buildAddWaterButton(300, '+300 ml'),
              ],
            ),
            Spacer(),
            // Button to reset the water intake
            ElevatedButton.icon(
              onPressed: _resetIntake,
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text('Reset Intake'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors
                        .redAccent, // Replacing 'primary' with 'backgroundColor'
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable method for creating water add buttons with styling
  Widget _buildAddWaterButton(int ml, String label) {
    return ElevatedButton(
      onPressed: () => _addWater(ml),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Colors.blue[700], // Replacing 'primary' with 'backgroundColor'
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Text(label, style: TextStyle(fontSize: 16)),
    );
  }
}
