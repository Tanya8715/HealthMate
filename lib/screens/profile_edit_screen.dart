import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _avatarUrlController =
      TextEditingController(); // 👈 NEW

  String? _selectedGender;
  bool _isLoading = true;

  final List<String> genderOptions = ['Male', 'Female', 'Others'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _selectedGender =
                genderOptions.contains(data['gender']) ? data['gender'] : null;
            _heightController.text = (data['height'] ?? '').toString();
            _weightController.text = (data['weight'] ?? '').toString();
            _avatarUrlController.text = data['avatarUrl'] ?? '';
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
        final int height = int.tryParse(_heightController.text.trim()) ?? 0;
        final int weight = int.tryParse(_weightController.text.trim()) ?? 0;

        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'gender': _selectedGender ?? '',
          'height': height,
          'weight': weight,
          'avatarUrl': _avatarUrlController.text.trim(), // 👈 from text field
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully!')),
        );

        Navigator.pop(context, true); // Refresh Dashboard
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Widget _buildAvatar(double radius) {
    final String avatarUrl = _avatarUrlController.text.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage:
          avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : const AssetImage('assets/images/avatar.png') as ImageProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAvatar(60),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _avatarUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Avatar Image URL',
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter image URL'
                              : null,
                  onChanged: (_) => setState(() {}), // 👈 Update avatar live
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter your name'
                              : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items:
                      genderOptions.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null ? 'Select gender' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter height'
                              : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter weight'
                              : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _updateProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
