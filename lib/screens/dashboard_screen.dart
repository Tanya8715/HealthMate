import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';
import 'login_screen.dart';
import 'health_status_screen.dart';
import 'profile_edit_screen.dart';
import 'heartrate_screen.dart';
import 'hydration_screen.dart';
import 'sleep_tracker_screen.dart';
import 'step_count_page.dart';
import 'select_doctor_screen.dart';
import 'notification_screen.dart';
import 'faq_screen.dart';
import 'set_goals_screen.dart';
import 'progress_tracking_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const DashboardScreen({super.key, required this.onToggleTheme});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = 'User';
  String userEmail = '';
  String userAvatarUrl = '';

  int steps = 0;
  int dailyGoal = 10000;
  int waterIntake = 0;
  int sleepHours = 0;

  List<Doctor> doctorList = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchDoctors();
  }

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userName = data['name'] ?? 'User';
          userEmail = data['email'] ?? user.email ?? '';
          userAvatarUrl = data['avatarUrl'] ?? '';
          steps = data['steps'] ?? 0;
          waterIntake = data['waterIntake'] ?? 0;
          sleepHours = data['sleepHours'] ?? 0;
        });
      }
    }
  }

  Future<void> fetchDoctors() async {
    final query = await _firestore.collection('doctors').get();
    setState(() {
      doctorList =
          query.docs.map((doc) {
            final data = doc.data();
            return Doctor(
              id: doc.id,
              name: data['name'],
              email: data['email'],
              specialization: data['specialization'],
              contact: data['contact'],
              imageUrl: data['imageUrl'],
            );
          }).toList();
    });
  }

  void _selectDoctor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDoctorScreen(doctors: doctorList),
      ),
    );
  }

  Widget _buildProfileAvatar({double radius = 40}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      child: ClipOval(
        child:
            userAvatarUrl.isNotEmpty
                ? Image.network(
                  userAvatarUrl,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/default_avatar.png',
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                    );
                  },
                )
                : Image.asset(
                  'assets/images/default_avatar.png',
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                ),
      ),
    );
  }

  Widget _buildProgressCard(
    String label,
    int value,
    int goal,
    double progress,
    Color color,
  ) {
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
                value: (progress.isNaN || progress.isInfinite) ? 0 : progress,
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

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[800]),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    double stepProgress = (steps / dailyGoal).clamp(0.0, 1.0);
    double waterProgress = (waterIntake / 2000).clamp(0.0, 1.0);
    double sleepProgress = (sleepHours / 8).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            const SizedBox(width: 10),
            const Text(
              'HealthMate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green[600]),
              accountName: Text(userName, style: const TextStyle(fontSize: 18)),
              accountEmail: Text(userEmail),
              currentAccountPicture: _buildProfileAvatar(),
            ),
            _buildDrawerItem(
              Icons.dashboard,
              'Dashboard',
              () => Navigator.pop(context),
            ),
            _buildDrawerItem(Icons.show_chart, 'Progress Tracking', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgressTrackingScreen(),
                ),
              );
            }),
            _buildDrawerItem(Icons.flag, 'Set Goals', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetGoalsScreen()),
              );
            }),
            _buildDrawerItem(Icons.notifications, 'Notifications', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            }),
            _buildDrawerItem(Icons.favorite, 'Health Status', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HealthStatusScreen()),
              );
            }),
            _buildDrawerItem(Icons.bedtime, 'Sleep Tracker', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SleepTrackerScreen()),
              );
            }),
            _buildDrawerItem(Icons.monitor_heart, 'Heart Rate', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HeartRateTrackerScreen(),
                ),
              );
            }),
            _buildDrawerItem(Icons.water_drop, 'Hydration', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HydrationScreen()),
              );
            }),
            _buildDrawerItem(Icons.directions_walk, 'Step Count', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StepCountPage()),
              );
            }),
            _buildDrawerItem(
              Icons.person_search,
              'Select Doctor',
              _selectDoctor,
            ),
            _buildDrawerItem(Icons.settings, 'Settings', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              );
            }),
            _buildDrawerItem(Icons.help_outline, 'FAQs', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FAQScreen()),
              );
            }),
            const Spacer(),
            _buildDrawerItem(Icons.exit_to_app, 'Logout', () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              _buildProfileAvatar(),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $userName!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Email: $userEmail',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Your Activity Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildProgressCard(
            'Steps',
            steps,
            dailyGoal,
            stepProgress,
            Colors.green,
          ),
          _buildProgressCard(
            'Water Intake (ml)',
            waterIntake,
            2000,
            waterProgress,
            Colors.blue,
          ),
          _buildProgressCard(
            'Sleep (hrs)',
            sleepHours,
            8,
            sleepProgress,
            Colors.orange,
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: _selectDoctor,
              icon: const Icon(Icons.medical_services),
              label: const Text('Select Doctor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 16),
                const SizedBox(height: 5),
                Text(
                  'Made with care by HealthMate Team',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 3),
                const Text(
                  '© 2025 HealthMate • All rights reserved.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
