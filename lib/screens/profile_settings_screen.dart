import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String _currentAvatarUrl = '';
  String _currentName = '';
  String _newName = '';
  File? _newAvatar;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      setState(() {
        _currentAvatarUrl = data?['avatarUrl'] ?? '';
        _currentName = data?['name'] ?? '';
        _nameController.text = _currentName;
      });
    }
  }

  Future<void> updateProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDocRef = _firestore.collection('users').doc(user.uid);

      // If a new avatar is selected, upload the image
      if (_newAvatar != null) {
        // Here you can use Firebase Storage to upload the image and get the URL.
        // For simplicity, we'll assume you already have a method to upload the image to Firebase Storage and get a URL.
        String avatarUrl = await uploadImage(_newAvatar!);
        await userDocRef.update({'avatarUrl': avatarUrl});
      }

      if (_newName.isNotEmpty) {
        await userDocRef.update({'name': _newName});
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      Navigator.pop(context); // Go back to dashboard
    }
  }

  Future<String> uploadImage(File image) async {
    // Implement Firebase Storage upload logic here and return the URL of the uploaded image
    // Example:
    // final storageRef = FirebaseStorage.instance.ref().child('profile_pics/${DateTime.now().millisecondsSinceEpoch}');
    // UploadTask uploadTask = storageRef.putFile(image);
    // TaskSnapshot taskSnapshot = await uploadTask;
    // String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    // return downloadUrl;
    return ''; // For now, returning an empty string until you implement image upload.
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newAvatar = File(pickedFile.path);
      });
    }
  }

  Future<void> deleteProfilePicture() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'avatarUrl': '',
      });
      setState(() {
        _currentAvatarUrl = '';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile picture deleted')));
    }
  }

  Future<void> deleteProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentAvatarUrl.isNotEmpty || _newAvatar != null)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _newAvatar != null
                          ? FileImage(_newAvatar!)
                          : NetworkImage(_currentAvatarUrl) as ImageProvider,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Choose Profile Picture'),
            ),
            SizedBox(height: 20),
            Text('Update Name:'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Enter new name'),
              onChanged: (value) => _newName = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              child: Text('Update Profile'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: deleteProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete Profile'),
            ),
            if (_currentAvatarUrl.isNotEmpty)
              ElevatedButton(
                onPressed: deleteProfilePicture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: Text('Delete Profile Picture'),
              ),
          ],
        ),
      ),
    );
  }
}
