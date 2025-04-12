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

  // Placeholder for actual health data
  Future<void> fetchActivityData() async {
    await Future.delayed(Duration(seconds: 1)); // simulate delay
    setState(() {
      steps = 5000;
      heartRate = 72;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            SizedBox(width: 10),
            Text('Activity Tracker'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userAvatarUrl),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $userName!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Email: $userEmail',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Heart Rate Section
            Text(
              'Heart Rate: $heartRate bpm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: (heartRate / 200).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.red,
            ),
            SizedBox(height: 30),

            // Steps Section
            Text(
              'Steps: $steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: (steps / 10000).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement your Start Activity logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: Text('Start Activity'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement your Stop Activity logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                  ),
                  child: Text('Stop Activity'),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Back Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
