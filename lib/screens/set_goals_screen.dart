import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetGoalsScreen extends StatefulWidget {
  const SetGoalsScreen({super.key});

  @override
  State<SetGoalsScreen> createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsScreen> {
  final _stepController = TextEditingController();
  final _waterController = TextEditingController();
  final _sleepController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveGoals() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('goals').doc(uid).set({
      'stepGoal': int.tryParse(_stepController.text) ?? 10000,
      'waterGoal': int.tryParse(_waterController.text) ?? 2000,
      'sleepGoal': double.tryParse(_sleepController.text) ?? 8,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Goals Updated!")));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _stepController.dispose();
    _waterController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Your Goals")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _stepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Daily Step Goal'),
            ),
            TextField(
              controller: _waterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Water Intake Goal (ml)',
              ),
            ),
            TextField(
              controller: _sleepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sleep Hours Goal'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveGoals,
              child: const Text("Save Goals"),
            ),
          ],
        ),
      ),
    );
  }
}
