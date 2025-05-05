import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/app_notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _markAllAsRead();
  }

  Future<void> _markAllAsRead() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications =
              snapshot.data?.docs.map((doc) {
                return AppNotification.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
              }).toList();

          if (notifications == null || notifications.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isUnread = !notification.read;

              return ListTile(
                leading: Icon(
                  Icons.notifications_active,
                  color: isUnread ? Colors.green : Colors.green,
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(notification.message),
                trailing: Text(
                  DateFormat('MMM d, h:mm a').format(notification.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
