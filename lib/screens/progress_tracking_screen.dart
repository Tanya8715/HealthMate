import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressTrackingScreen extends StatelessWidget {
  const ProgressTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Progress Tracking'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final int steps = data['steps'] ?? 0;
          final int waterIntake = data['waterIntake'] ?? 0;
          final double sleepHours = (data['sleepHours'] ?? 0).toDouble();

          final int stepGoal = 10000;
          final int waterGoal = 2000;
          final int sleepGoal = 8;

          List<int> weeklySteps = [];
          List<int> weeklyWaterIntake = [];
          List<double> weeklySleepHours = [];

          if (data.containsKey('weeklySteps') && data['weeklySteps'] is List) {
            weeklySteps =
                (data['weeklySteps'] as List)
                    .map((e) => (e is num) ? e.toInt() : 0)
                    .toList();
          } else {
            weeklySteps = List.filled(7, 0);
            FirebaseFirestore.instance.collection('users').doc(userId).update({
              'weeklySteps': weeklySteps,
            });
          }

          if (data.containsKey('weeklyWaterIntake') &&
              data['weeklyWaterIntake'] is List) {
            weeklyWaterIntake =
                (data['weeklyWaterIntake'] as List)
                    .map((e) => (e is num) ? e.toInt() : 0)
                    .toList();
          } else {
            weeklyWaterIntake = List.filled(7, 0);
            FirebaseFirestore.instance.collection('users').doc(userId).update({
              'weeklyWaterIntake': weeklyWaterIntake,
            });
          }

          if (data.containsKey('weeklySleepHours') &&
              data['weeklySleepHours'] is List) {
            weeklySleepHours =
                (data['weeklySleepHours'] as List)
                    .map((e) => (e is num) ? e.toDouble() : 0.0)
                    .toList();
          } else {
            weeklySleepHours = List.filled(7, 0.0);
            FirebaseFirestore.instance.collection('users').doc(userId).update({
              'weeklySleepHours': weeklySleepHours,
            });
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const Text(
                  'Track Your Progress',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Monitor your steps, water intake and sleep goals in real time.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                _buildProgressCard('Steps', steps, stepGoal, Colors.green),
                _buildProgressCard(
                  'Water Intake (ml)',
                  waterIntake,
                  waterGoal,
                  Colors.blue,
                ),
                _buildProgressCard(
                  'Sleep (hrs)',
                  sleepHours.toInt(),
                  sleepGoal,
                  Colors.orange,
                ),

                const SizedBox(height: 30),
                _buildChartTitle('Weekly Overview (Steps, Water, Sleep)'),
                const SizedBox(height: 10),
                _buildGroupedBarChart(
                  weeklySteps,
                  weeklyWaterIntake,
                  weeklySleepHours,
                  stepGoal,
                  waterGoal,
                  sleepGoal,
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LegendItem(color: Colors.green, label: 'Steps'),
                    LegendItem(color: Colors.blue, label: 'Water'),
                    LegendItem(color: Colors.orange, label: 'Sleep'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(String label, int value, int goal, Color color) {
    final double progress = (value / goal).clamp(0.0, 1.0);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: $value / $goal',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: color.withOpacity(0.2),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGroupedBarChart(
    List<int> steps,
    List<int> waterIntake,
    List<double> sleepHours,
    int stepGoal,
    int waterGoal,
    int sleepGoal,
  ) {
    const List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    double maxY = [
      stepGoal.toDouble(),
      waterGoal.toDouble(),
      sleepGoal.toDouble(),
      ...steps.map((e) => e.toDouble()),
      ...waterIntake.map((e) => e.toDouble()),
      ...sleepHours,
    ].reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.8,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY + 500,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (maxY / 4).clamp(1, 5000),
            getDrawingHorizontalLine:
                (_) =>
                    FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
            getDrawingVerticalLine:
                (_) =>
                    FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, _) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          groupsSpace: 16,
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: (index < steps.length) ? steps[index].toDouble() : 0.0,
                  width: 6,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY:
                      (index < waterIntake.length)
                          ? waterIntake[index].toDouble()
                          : 0.0,
                  width: 6,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: (index < sleepHours.length) ? sleepHours[index] : 0.0,
                  width: 6,
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
