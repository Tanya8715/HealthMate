import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({super.key});

  @override
  _ActivityTrackerScreenState createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int steps = 0;
  int heartRate = 0;
  double caloriesBurned = 0.0;
  double waterIntake = 0.0;
  double weightKg = 0.0;

  final TextEditingController _weightController = TextEditingController();

  String userName = 'User';
  String userEmail = 'user@example.com';
  String userAvatarUrl =
      'https://img.freepik.com/premium-vector/cute-woman-avatar-profile-vector-illustration_1058532-14592.jpg';

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchActivityData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final data = userDoc.data();

        if (userDoc.exists && data != null) {
          setState(() {
            userName = data['name'] ?? 'User';
            userEmail = data['email'] ?? user.email ?? '';
            userAvatarUrl = data['avatarUrl'] ?? userAvatarUrl;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> fetchActivityData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      steps = 5000;
      heartRate = 72;
      caloriesBurned = 150.0;
      waterIntake = 2.5;
      weightKg = 55.0;
      _weightController.text = weightKg.toString();
    });
  }

  void _updateWeight() {
    final parsedWeight = double.tryParse(_weightController.text);
    if (parsedWeight != null) {
      setState(() {
        weightKg = parsedWeight;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Weight updated successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            const SizedBox(width: 10),
            const Text('Activity Tracker'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSection(greeting),
            const SizedBox(height: 20),
            Wrap(
              runSpacing: 16.0,
              spacing: 16.0,
              children: [
                _buildMetricCard(
                  'Heart Rate',
                  '$heartRate bpm',
                  heartRate / 200,
                  Colors.red,
                  Icons.favorite,
                ),
                _buildMetricCard(
                  'Steps',
                  '$steps',
                  steps / 10000,
                  Colors.green,
                  Icons.directions_walk,
                ),
                _buildMetricCard(
                  'Calories',
                  '${caloriesBurned.toStringAsFixed(2)} kcal',
                  caloriesBurned / 3000,
                  Colors.orange,
                  Icons.local_fire_department,
                ),
                _buildMetricCard(
                  'Water',
                  '${waterIntake.toStringAsFixed(2)} L',
                  waterIntake / 5,
                  Colors.blue,
                  Icons.water_drop,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildWeightSection(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 10),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String greeting) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(userAvatarUrl),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good $greeting, $userName!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    double progress,
    Color color,
    IconData icon,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 24,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                color: color,
                backgroundColor: Colors.grey[300],
                minHeight: 6,
              ),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSection() {
    double weightLbs = weightKg * 2.20462;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update Weight",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              controller: _weightController,
              decoration: InputDecoration(
                hintText: 'Enter weight in kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Equivalent in lbs: ${weightLbs.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _updateWeight,
              icon: const Icon(Icons.update),
              label: const Text("Update Weight"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text("Log Activity"),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.history),
          label: const Text("History"),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
        label: const Text("Back"),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
