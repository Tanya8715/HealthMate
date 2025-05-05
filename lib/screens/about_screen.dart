import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.green.shade600;
    final Color textColor = Colors.grey.shade800;
    final Color subTextColor = Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About HealthMate'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 55,
              backgroundImage: const AssetImage('assets/images/logo.png'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            Text(
              'HealthMate',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Trusted Health & Fitness Companion',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 20),

            _buildSectionTitle('About HealthMate', primaryColor),
            const SizedBox(height: 12),
            Text(
              'HealthMate is a comprehensive health and fitness tracking app designed to help you live a healthier, happier life. '
              'From step counting and water tracking to sleep monitoring and doctor consultations, HealthMate empowers you to take control of your well-being effortlessly.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 15, color: textColor),
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Core Features', primaryColor),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.directions_walk,
              'Track your daily steps and stay active.',
              primaryColor,
            ),
            _buildFeatureItem(
              Icons.water_drop,
              'Monitor your daily water intake.',
              primaryColor,
            ),
            _buildFeatureItem(
              Icons.bedtime,
              'Track your sleep hours for better rest.',
              primaryColor,
            ),
            _buildFeatureItem(
              Icons.monitor_heart,
              'Stay updated with your heart rate (future).',
              primaryColor,
            ),
            _buildFeatureItem(
              Icons.flag,
              'Set personalized health goals.',
              primaryColor,
            ),
            _buildFeatureItem(
              Icons.medical_services,
              'Connect and chat with healthcare professionals.',
              primaryColor,
            ),
            _buildFeatureItem(
              Icons.notifications,
              'Get real-time health notifications and reminders.',
              primaryColor,
            ),
            _buildFeatureItem(
              Icons.help_outline,
              'FAQs and support at your fingertips.',
              primaryColor,
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Our Mission', primaryColor),
            const SizedBox(height: 12),
            Text(
              'To empower individuals around the world to achieve their best health through technology, motivation, and easy-to-use tracking tools.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: textColor),
            ),

            const SizedBox(height: 30),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 13, color: subTextColor),
            ),
            const SizedBox(height: 5),
            Text(
              '© 2025 HealthMate Team. All rights reserved.',
              style: TextStyle(fontSize: 13, color: subTextColor),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
