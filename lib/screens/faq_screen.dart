import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.green.shade600;

    final List<Map<String, String>> faqData = [
      {
        'question': 'What is HealthMate?',
        'answer':
            'HealthMate is your personal health and fitness companion app. It helps you track your steps, water intake, sleep, heart rate, connect with doctors, and achieve your health goals.',
      },
      {
        'question': 'How do I create an account on HealthMate?',
        'answer':
            'Open the app, tap on "Sign Up," fill your name, email, and password, and start your journey to better health!',
      },
      {
        'question': 'How can I track my daily steps?',
        'answer':
            'HealthMate automatically tracks your daily steps through your phone\'s sensors or connected fitness devices. You can view it in your dashboard.',
      },
      {
        'question': 'Can I connect with a doctor using HealthMate?',
        'answer':
            'Yes! You can browse available doctors, view their profiles, and ask questions through the "Select Doctor" feature.',
      },
      {
        'question': 'How do I log my water intake and sleep hours?',
        'answer':
            'Go to the dashboard and select "Water Intake" or "Sleep Tracker" sections to add your daily records.',
      },
      {
        'question': 'Is HealthMate free to use?',
        'answer':
            'Yes! HealthMate\'s basic features are completely free. Some future premium features might require a subscription.',
      },
      {
        'question': 'How do I change the app language?',
        'answer':
            'On the login screen, you can easily switch between English and नेपाली (Nepali) by tapping the language buttons.',
      },
      {
        'question': 'Can I use HealthMate offline?',
        'answer':
            'Yes, you can record steps and water intake offline. However, syncing with doctors requires an internet connection.',
      },
      {
        'question': 'How do I reset my password if I forget it?',
        'answer':
            'Tap on "Forgot Password" on the login page and follow the email instructions to reset your password.',
      },
      {
        'question': 'How can I enable dark mode in HealthMate?',
        'answer':
            'Tap the light/dark mode icon on the dashboard\'s top-right corner to switch between Light and Dark themes.',
      },
      {
        'question': 'Is my personal data safe with HealthMate?',
        'answer':
            'Absolutely! HealthMate uses Firebase Authentication and Firestore for secure, encrypted storage of your data.',
      },
      {
        'question': 'How can I contact HealthMate support?',
        'answer':
            'For any support, you can email us at support@healthmate.com.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQs'), backgroundColor: primaryColor),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          final faq = faqData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
