import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  String? _name, _bio, _gender, _age, _medicalConditions;
  String _avatarUrl =
      'https://img.freepik.com/premium-vector/cute-woman-avatar-profile-vector-illustration_1058532-14592.jpg';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            _name = data?['name'] ?? '';
            _bio = data?['bio'] ?? '';
            _gender = data?['gender'] ?? '';
            _age = data?['age'] ?? '';
            _medicalConditions = data?['medicalConditions'] ?? '';
            _avatarUrl = data?['avatarUrl'] ?? _avatarUrl;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user != null && _formKey.currentState!.validate()) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'name': _name ?? '',
          'bio': _bio ?? '',
          'gender': _gender ?? '',
          'age': _age ?? '',
          'medicalConditions': _medicalConditions ?? '',
          'avatarUrl': _avatarUrl,
        });
        Navigator.pop(context);
      } catch (e) {
        print('Error updating profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(_avatarUrl),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) => _name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _bio,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  onChanged: (value) => _bio = value,
                ),
                TextFormField(
                  initialValue: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  onChanged: (value) => _gender = value,
                ),
                TextFormField(
                  initialValue: _age,
                  decoration: const InputDecoration(labelText: 'Age'),
                  onChanged: (value) => _age = value,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _medicalConditions,
                  decoration: const InputDecoration(
                    labelText: 'Medical Conditions',
                  ),
                  onChanged: (value) => _medicalConditions = value,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.green[600],
                    ),
                  ),
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
