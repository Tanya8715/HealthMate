import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/doctor.dart';
import 'login_screen.dart';
import 'health_status_screen.dart';
import 'profile_edit_screen.dart';
import 'hydration_screen.dart';
import 'sleep_tracker_screen.dart';
import 'step_count_page.dart';
import 'select_doctor_screen.dart';
import 'notification_screen.dart';
import 'faq_screen.dart';
import 'set_goals_screen.dart';
import 'progress_tracking_screen.dart';
//import 'about_screen.dart'; // 👈 NEW import added here

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
  int waterIntake = 0;
  int sleepHours = 0;

  int stepGoal = 10000;
  int waterGoal = 2000;
  int sleepGoal = 8;

  List<int> weeklySteps = List.filled(7, 0);
  List<Doctor> doctorList = [];
  List<int> weeklyWaterIntake = List.filled(7, 0);
  List<double> weeklySleepHours = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    fetchGoals();
    fetchDoctors();
    syncDailyProgress();
  }

  Future<void> syncDailyProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final firestore = FirebaseFirestore.instance;

    final userDoc = await firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();
    if (userData == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastSynced = (userData['lastSynced'] as Timestamp?)?.toDate();

    if (lastSynced != null &&
        lastSynced.year == today.year &&
        lastSynced.month == today.month &&
        lastSynced.day == today.day) {
      print("Already synced today.");
      return;
    }

    // Get current values
    final steps = (userData['steps'] ?? 0).toInt();
    final sleep = (userData['sleepHours'] ?? 0.0).toDouble();
    final water = (userData['waterIntake'] ?? 0).toInt();

    // Save to weekly collections
    await firestore.collection('weekly_step').doc(uid).set({
      'days': FieldValue.arrayUnion([steps]),
    }, SetOptions(merge: true));

    await firestore.collection('weekly_sleep').doc(uid).set({
      'hours': FieldValue.arrayUnion([sleep]),
    }, SetOptions(merge: true));

    await firestore.collection('weekly_water').doc(uid).set({
      'ml': FieldValue.arrayUnion([water]),
    }, SetOptions(merge: true));

    // Update last sync timestamp
    await firestore.collection('users').doc(uid).update({
      'lastSynced': Timestamp.fromDate(now),
    });

    print("Synced today's progress.");
  }

  Future<void> fetchGoals() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('goals').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          stepGoal = (data['stepGoal'] ?? 10000).toDouble().toInt();
          waterGoal = (data['waterGoal'] ?? 2000).toDouble().toInt();
          sleepGoal = (data['sleepGoal'] ?? 8).toDouble().toInt();
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

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void showAchievementNotifications(
    int steps,
    int waterIntake,
    int sleepHours,
  ) {
    if (steps >= stepGoal) showSnackbar("🎯 Steps Goal Completed!");
    if (waterIntake >= waterGoal) showSnackbar("💧 Water Goal Achieved!");
    if (sleepHours >= sleepGoal) showSnackbar("😴 Sleep Goal Completed!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            _firestore
                .collection('users')
                .doc(_auth.currentUser?.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          steps = (data['steps'] ?? 0).toDouble().toInt();
          waterIntake = (data['waterIntake'] ?? 0).toDouble().toInt();
          sleepHours = (data['sleepHours'] ?? 0).toDouble().toInt();
          userName = data['name'] ?? 'User';
          userEmail = data['email'] ?? '';
          userAvatarUrl = data['avatarUrl'] ?? '';

          if (data.containsKey('weeklyWaterIntake') &&
              data['weeklyWaterIntake'] is List) {
            List list = data['weeklyWaterIntake'];
            while (list.length < 7) {
              list.add(0);
            }
            weeklyWaterIntake =
                list.map((e) => (e is num) ? e.toInt() : 0).toList();
          } else {
            weeklyWaterIntake = List.filled(7, 0);
            _firestore.collection('users').doc(_auth.currentUser!.uid).update({
              'weeklyWaterIntake': weeklyWaterIntake,
            });
          }

          if (data.containsKey('weeklySleepHours') &&
              data['weeklySleepHours'] is List) {
            List list = data['weeklySleepHours'];
            while (list.length < 7) {
              list.add(0.0);
            }
            weeklySleepHours =
                list.map((e) => (e is num) ? e.toDouble() : 0.0).toList();
          } else {
            weeklySleepHours = List.filled(7, 0.0);
            _firestore.collection('users').doc(_auth.currentUser!.uid).update({
              'weeklySleepHours': weeklySleepHours,
            });
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showAchievementNotifications(steps, waterIntake, sleepHours);
          });

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildTodaySummary(),
              const SizedBox(height: 30),
              _buildWeeklyStepsChart(),
              const SizedBox(height: 30),
              _buildSelectDoctorButton(),
              const SizedBox(height: 30),
              _buildFooter(),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    final userId = _auth.currentUser?.uid ?? '';

    return AppBar(
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
        StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('notifications')
                  .where('read', isEqualTo: false)
                  .snapshots(),
          builder: (context, snapshot) {
            int unreadCount = 0;
            if (snapshot.hasData) {
              unreadCount = snapshot.data!.docs.length;
            }

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.brightness_6),
          onPressed: widget.onToggleTheme,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey.shade300,
          backgroundImage:
              userAvatarUrl.isNotEmpty
                  ? NetworkImage(userAvatarUrl)
                  : const AssetImage('assets/images/avatar.png')
                      as ImageProvider,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName!',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'Email: $userEmail',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.green),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            );
            if (result == true) setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildTodaySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularProgress('Steps', steps, stepGoal, Colors.green),
            _buildCircularProgress(
              'Water',
              waterIntake,
              waterGoal,
              Colors.blue,
            ),
            _buildCircularProgress(
              'Sleep',
              sleepHours,
              sleepGoal,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularProgress(
    String label,
    int value,
    int goal,
    Color color,
  ) {
    double percent = (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 50.0,
          lineWidth: 8.0,
          percent: percent,
          center: Text(
            '${(percent * 100).toInt()}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          progressColor: color,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWeeklyStepsChart() {
    final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final double maxY = [
      stepGoal.toDouble(),
      waterGoal.toDouble(),
      sleepGoal.toDouble(),
      ...weeklySteps.map((e) => e.toDouble()),
      waterIntake.toDouble(),
      sleepHours.toDouble(),
    ].reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Health Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        AspectRatio(
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
                    (_) => FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                getDrawingVerticalLine:
                    (_) => FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
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
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              groupsSpace: 16,
              barGroups: List.generate(7, (index) {
                return BarChartGroupData(
                  x: index,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY:
                          (index < weeklySteps.length)
                              ? weeklySteps[index].toDouble()
                              : 0.0,
                      width: 6,
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY:
                          (index < weeklyWaterIntake.length)
                              ? weeklyWaterIntake[index].toDouble()
                              : 0.0,
                      width: 6,
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY:
                          (index < weeklySleepHours.length)
                              ? weeklySleepHours[index]
                              : 0.0,
                      width: 6,
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
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
    );
  }

  Widget _buildSelectDoctorButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _selectDoctor,
        icon: const Icon(Icons.medical_services),
        label: const Text('Select Doctor'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _selectDoctor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDoctorScreen(doctors: doctorList),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Icon(Icons.favorite, color: Colors.red, size: 16),
        const SizedBox(height: 5),
        Text(
          'Made with care by HealthMate Team',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 3),
        const Text(
          '©️ 2025 HealthMate • All rights reserved.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final userId = _auth.currentUser?.uid ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.green[600]),
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  userAvatarUrl.isNotEmpty
                      ? NetworkImage(userAvatarUrl)
                      : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
            ),
          ),
          _buildDrawerItem(
            Icons.dashboard,
            'Dashboard',
            () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            Icons.show_chart,
            'Progress Tracking',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressTrackingScreen()),
            ),
          ),
          _buildDrawerItem(
            Icons.flag,
            'Set Goals',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SetGoalsScreen()),
            ),
          ),

          _buildDrawerItem(
            Icons.favorite,
            'Health Status',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthStatusScreen()),
            ),
          ),
          _buildDrawerItem(
            Icons.directions_walk,
            'Step Count',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StepCountPage()),
            ),
          ),
          _buildDrawerItem(
            Icons.water_drop,
            'Hydration',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HydrationScreen()),
            ),
          ),
          _buildDrawerItem(
            Icons.bedtime,
            'Sleep Tracker',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SleepTrackerScreen()),
            ),
          ),
          _buildDrawerItem(
            Icons.help_outline,
            'FAQs',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FAQScreen()),
            ),
          ),
          const Divider(),
          // _buildDrawerItem(
          //   Icons.info_outline,
          //   'About',
          //   () => Navigator.push(
          //     context,
          //    // MaterialPageRoute(builder: (_) => const AboutScreen()),
          //   ),
          // ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
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
