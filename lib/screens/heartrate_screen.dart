import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeartRateTrackerScreen extends StatefulWidget {
  const HeartRateTrackerScreen({super.key});

  @override
  _HeartRateTrackerScreenState createState() => _HeartRateTrackerScreenState();
}

class _HeartRateTrackerScreenState extends State<HeartRateTrackerScreen> {
  List<int> heartRates = [];
  TextEditingController heartRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadHeartRates();
  }

  // Load stored heart rate data from SharedPreferences
  Future<void> loadHeartRates() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedHeartRates = prefs.getStringList('heartRates');
    if (storedHeartRates != null) {
      setState(() {
        heartRates =
            storedHeartRates.map((rate) => int.tryParse(rate) ?? 0).toList();
      });
    }
  }

  // Save heart rate to SharedPreferences
  Future<void> saveHeartRate(int heartRate) async {
    final prefs = await SharedPreferences.getInstance();
    heartRates.add(heartRate);
    List<String> heartRateStrings =
        heartRates.map((rate) => rate.toString()).toList();
    await prefs.setStringList('heartRates', heartRateStrings);
    setState(() {});
  }

  // Clear all heart rates
  Future<void> clearHeartRates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('heartRates');
    setState(() {
      heartRates.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Heart Rate Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input section for heart rate
            Text(
              'Enter your Heart Rate:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: heartRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Heart Rate (bpm)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (heartRateController.text.isNotEmpty) {
                  int heartRate = int.tryParse(heartRateController.text) ?? 0;
                  if (heartRate > 0) {
                    saveHeartRate(heartRate);
                    heartRateController.clear();
                  } else {
                    // Show error message if the input is invalid
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid heart rate'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              child: Text('Save Heart Rate'),
            ),
            SizedBox(height: 20),

            // Displaying the saved heart rates
            Text(
              'Your Daily Heart Rates:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            heartRates.isEmpty
                ? Text('No data available')
                : Expanded(
                  child: ListView.builder(
                    itemCount: heartRates.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.favorite),
                        title: Text('Heart Rate: ${heartRates[index]} bpm'),
                      );
                    },
                  ),
                ),
            SizedBox(height: 20),

            // Clear Heart Rates Button
            ElevatedButton(
              onPressed: clearHeartRates,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Clear All Heart Rates'),
            ),
          ],
        ),
      ),
    );
  }
}
