import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart'; // Adjust path if needed

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all doctors from Firestore
  Future<List<Doctor>> getDoctors() async {
    try {
      final querySnapshot = await _firestore.collection('doctors').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Doctor.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  // Add a new doctor to Firestore
  Future<void> addDoctor(Doctor doctor) async {
    try {
      await _firestore.collection('doctors').add(doctor.toMap());
    } catch (e) {
      print('Error adding doctor: $e');
    }
  }
}
