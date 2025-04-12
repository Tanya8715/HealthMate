import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'health_status_screen.dart';
import 'profile_settings_screen.dart';
import 'heartrate_screen.dart';
import 'hydration_screen.dart';
import 'package:healthmate/screens/activity_tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = '';
  String userEmail = '';
  String userAvatarUrl =
      'https://img.freepik.com/premium-vector/cute-woman-avatar-profile-vector-illustration_1058532-14592.jpg';

  int steps = 4500;
  int caloriesBurned = 350;
  int dailyGoal = 10000;
  int waterIntake = 1200;

  List<String> recentActivities = [
    'Morning Walk: 2000 steps',
    'Running: 1500 steps',
    'Cycling: 1000 steps',
  ];

  List<String> notifications = [
    'Great job! You completed 50% of your daily steps goal.',
    'Drink more water today, you’ve only consumed 1200 ml.',
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          userName = data?['name'] ?? 'User';
          userEmail = data?['email'] ?? user.email ?? '';
          userAvatarUrl = data?['avatarUrl'] ?? userAvatarUrl;
        });
      } else {
        setState(() {
          userName = 'User';
          userEmail = user.email ?? '';
        });
      }
    }
  }

  void logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[600]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(userAvatarUrl),
                ),
                SizedBox(height: 10),
                Text(
                  userName,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Health Status'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HealthStatusScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_walk),
            title: Text('Activity Tracker'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HeartRateTrackerScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.water_drop),
            title: Text('Hydration'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HydrationScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {
              // Implement notifications screen if needed
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: logout,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double stepProgress = (steps / dailyGoal);
    double waterProgress = (waterIntake / 2000);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            SizedBox(width: 10),
            Text('HealthMate'),
          ],
        ),
      ),
      drawer: buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName!',
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
                ],
              ),
              SizedBox(height: 20),

              // Summary
              Text(
                'Your Activity Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Steps: $steps / $dailyGoal'),
              LinearProgressIndicator(
                value: stepProgress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              SizedBox(height: 10),
              Text('Calories Burned: $caloriesBurned kcal'),
              SizedBox(height: 10),
              Text('Water Intake: $waterIntake ml / 2000 ml'),
              LinearProgressIndicator(
                value: waterProgress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              SizedBox(height: 20),

              // Activities
              Text(
                'Recent Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...recentActivities.map(
                (activity) => ListTile(
                  leading: Icon(Icons.directions_walk),
                  title: Text(activity),
                ),
              ),
              SizedBox(height: 20),

              // Notifications
              Text(
                'Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...notifications.map(
                (note) => ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text(note),
                ),
              ),
              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Profile Settings Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettingsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: Text('Update Profile & Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
