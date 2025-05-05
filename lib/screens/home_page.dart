import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart' as login;
import 'widgets/footer_widget.dart';
import 'package:health/health.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Health _health = Health();

  String userName = 'User';
  bool _loading = true;
  int _stepCount = 0;
  double _waterIntake = 0.0;
  double _weight = 70.0;

  int get _caloriesBurned {
    // Approximate calories = 0.04 × steps × weight / 60
    return (_stepCount * 0.04 * _weight / 60).round();
  }

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          userName = data['name'] ?? 'User';
          _stepCount = data['steps'] ?? 0;
          _waterIntake = (data['waterIntake'] ?? 0).toDouble();
          _weight = (data['weight'] ?? 70).toDouble();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.green.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const login.LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/home.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white.withOpacity(0.9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            Text(
                              'Welcome, $userName!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your journey to a healthier lifestyle starts here.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              children: [
                                _buildStatCard(
                                  "Steps",
                                  '$_stepCount',
                                  Icons.directions_walk,
                                  Colors.green,
                                ),
                                const SizedBox(width: 10),
                                _buildStatCard(
                                  "Calories",
                                  '$_caloriesBurned',
                                  Icons.local_fire_department,
                                  Colors.redAccent,
                                ),
                                const SizedBox(width: 10),
                                _buildStatCard(
                                  "Water",
                                  '${(_waterIntake / 1000).toStringAsFixed(1)}L',
                                  Icons.water_drop,
                                  Colors.blueAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Card(
                              color: Colors.green[50],
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      "Your Personal Health Companion",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "HealthMate helps you track your fitness journey with smart features including step count, water intake, sleep monitoring, goal tracking, and more — all in one place.",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "“Every step you take is a step closer to a healthier you.”",
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            _buildBullet(
                              "Track daily steps and calories burned.",
                            ),
                            _buildBullet("Monitor hydration and water intake."),
                            _buildBullet("Log and improve your sleep cycle."),
                            _buildBullet(
                              "Set custom health and fitness goals.",
                            ),
                            _buildBullet(
                              "Get daily health insights and reminders.",
                            ),
                            const SizedBox(height: 35),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => DashboardScreen(
                                            onToggleTheme: () {},
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  "Get Started",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            const FooterWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
