import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<int> weeklySteps = [0, 0, 0, 0, 0, 0, 0];
  List<double> weeklySleep = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    loadWeeklyData();
  }

  Future<void> loadWeeklyData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Example: fetch from "weekly_data" collection (you have to save data daily or use mock data now)
    final stepsQuery =
        await _firestore.collection('weekly_steps').doc(uid).get();

    final sleepQuery =
        await _firestore.collection('weekly_sleep').doc(uid).get();

    if (stepsQuery.exists) {
      final data = stepsQuery.data()!;
      setState(() {
        weeklySteps = List<int>.from(data['days'] ?? [0, 0, 0, 0, 0, 0, 0]);
      });
    }

    if (sleepQuery.exists) {
      final data = sleepQuery.data()!;
      setState(() {
        weeklySleep = List<double>.from(data['hours'] ?? [0, 0, 0, 0, 0, 0, 0]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Weekly Progress")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Steps (Last 7 Days)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        7,
                        (index) => FlSpot(
                          index.toDouble(),
                          weeklySteps[index].toDouble(),
                        ),
                      ),
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sleep Hours (Last 7 Days)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(
                    7,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklySleep[index],
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
