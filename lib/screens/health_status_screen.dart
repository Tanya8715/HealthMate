import 'package:flutter/material.dart';

class HealthStatusScreen extends StatefulWidget {
  const HealthStatusScreen({super.key});

  @override
  _HealthStatusScreenState createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends State<HealthStatusScreen> {
  int heartRate = 78; // bpm
  double bmi = 22.3; // kg/m²
  double sleepHours = 7.5; // hrs
  double weight = 65.0; // kg

  // Controllers for text input
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController sleepHoursController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    heartRateController.text = heartRate.toString();
    bmiController.text = bmi.toString();
    sleepHoursController.text = sleepHours.toString();
    weightController.text = weight.toString();
  }

  // Method to update a specific health value
  void updateHealthValue(String valueType) async {
    final updatedValue = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller;
        switch (valueType) {
          case 'Heart Rate':
            controller = heartRateController;
            break;
          case 'BMI':
            controller = bmiController;
            break;
          case 'Sleep':
            controller = sleepHoursController;
            break;
          case 'Weight':
            controller = weightController;
            break;
          default:
            controller = heartRateController;
        }

        return AlertDialog(
          title: Text('Update $valueType'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: 'Enter $valueType'),
            onChanged: (value) {
              // Updates live while user types (Optional)
            },
            onSubmitted: (value) {
              Navigator.of(context).pop(double.tryParse(value) ?? 0.0);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(0.0); // In case of cancellation
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(double.tryParse(controller.text) ?? 0.0);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );

    if (updatedValue != null) {
      setState(() {
        switch (valueType) {
          case 'Heart Rate':
            heartRate = updatedValue.toInt();
            break;
          case 'BMI':
            bmi = updatedValue;
            break;
          case 'Sleep':
            sleepHours = updatedValue;
            break;
          case 'Weight':
            weight = updatedValue;
            break;
        }
      });
    }
  }

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
              onTap: () => updateHealthValue('Heart Rate'),
            ),
            HealthTile(
              icon: Icons.fitness_center,
              label: 'BMI',
              value: '$bmi',
              color: Colors.orangeAccent,
              onTap: () => updateHealthValue('BMI'),
            ),
            HealthTile(
              icon: Icons.hotel,
              label: 'Sleep',
              value: '$sleepHours hrs',
              color: Colors.blueAccent,
              onTap: () => updateHealthValue('Sleep'),
            ),
            HealthTile(
              icon: Icons.monitor_weight,
              label: 'Weight',
              value: '$weight kg',
              color: Colors.purpleAccent,
              onTap: () => updateHealthValue('Weight'),
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
  final VoidCallback onTap;

  const HealthTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap, // Tapping the tile will trigger the update dialog
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
