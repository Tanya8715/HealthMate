import 'package:flutter/material.dart';

class HealthStatusScreen extends StatelessWidget {
  final int heartRate = 78; // bpm
  final double bmi = 22.3; // kg/m²
  final double sleepHours = 7.5; // hrs
  final double weight = 65.0;

  const HealthStatusScreen({super.key}); // kg

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Status'),
        backgroundColor: Colors.green[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Health Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            HealthTile(
              icon: Icons.favorite,
              label: 'Heart Rate',
              value: '$heartRate bpm',
              color: Colors.redAccent,
            ),
            HealthTile(
              icon: Icons.fitness_center,
              label: 'BMI',
              value: '$bmi',
              color: Colors.orangeAccent,
            ),
            HealthTile(
              icon: Icons.hotel,
              label: 'Sleep',
              value: '$sleepHours hrs',
              color: Colors.blueAccent,
            ),
            HealthTile(
              icon: Icons.monitor_weight,
              label: 'Weight',
              value: '$weight kg',
              color: Colors.purpleAccent,
            ),

            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Future: navigate to edit or sync health data
                },
                icon: Icon(Icons.edit),
                label: Text('Update Health Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const HealthTile({super.key, 
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
