class Doctor {
  final String id;
  final String name;
  final String email;
  final String specialization;
  final String contact;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.contact,
    required this.imageUrl,
  });

  // Convert Firestore data into a Doctor object
  factory Doctor.fromMap(Map<String, dynamic> data, String id) {
    return Doctor(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      specialization: data['specialization'] ?? '',
      contact: data['contact'] ?? '',
      imageUrl: data['imageUrl'] ?? '', // Handle missing image gracefully
    );
  }

  // Convert Doctor object into a map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'specialization': specialization,
      'contact': contact,
      'imageUrl': imageUrl,
    };
  }
}
