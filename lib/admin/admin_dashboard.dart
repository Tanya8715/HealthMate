import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/screens/login_screen.dart';
import 'package:intl/intl.dart'; // ADD THIS for time formatting

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedSection = 'Users';
  bool doctorSortDescending = false;
  final _formKey = GlobalKey<FormState>();

  final _docNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedSpecialization;

  final _editPatientController = TextEditingController();
  final _editTimeController = TextEditingController();
  final _editDoctorController = TextEditingController();
  final _editSpecializationController = TextEditingController();

  final List<String> specializations = [
    'Cardiologist (Heart Specialist)',
    'General Physician',
    'Nutritionist/Dietitian',
    'Psychologist',
    'Neurologist',
    'Orthopedic Surgeon',
    'Physiotherapist',
    'Dermatologist (Skin Specialist)',
    'Pediatrician (Child Specialist)',
    'Gynecologist (Women\'s Health)',
    'Gastroenterologist (Stomach Specialist)',
  ];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showAddDoctorDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _docNameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _contactController.text = data['contact'] ?? '';
      _imageUrlController.text = data['imageUrl'] ?? '';
      _selectedSpecialization = data['specialization'];
    } else {
      _docNameController.clear();
      _emailController.clear();
      _contactController.clear();
      _imageUrlController.clear();
      _selectedSpecialization = null;
    }

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text(doc != null ? 'Edit Doctor' : 'Add Doctor'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildInput(_docNameController, 'Name'),
                        _buildInput(
                          _emailController,
                          'Email',
                          keyboard: TextInputType.emailAddress,
                        ),
                        _buildInput(
                          _contactController,
                          'Contact',
                          keyboard: TextInputType.phone,
                        ),
                        _buildInput(_imageUrlController, 'Image URL'),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedSpecialization,
                          decoration: const InputDecoration(
                            labelText: 'Specialization',
                            border: OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          items:
                              specializations
                                  .map(
                                    (spec) => DropdownMenuItem(
                                      value: spec,
                                      child: Text(spec),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setStateDialog(
                                () => _selectedSpecialization = val,
                              ),
                          validator:
                              (val) =>
                                  val == null ? 'Select specialization' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final data = {
                        'name': _docNameController.text.trim(),
                        'email': _emailController.text.trim(),
                        'contact': _contactController.text.trim(),
                        'specialization': _selectedSpecialization,
                        'imageUrl': _imageUrlController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      };
                      if (doc != null) {
                        await doc.reference.update(data);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('doctors')
                            .add(data);
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(doc != null ? 'Update' : 'Add'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showEditAppointmentDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    _editDoctorController.text = data['doctorName'] ?? '';
    _editSpecializationController.text = data['doctorSpecialization'] ?? '';
    _editPatientController.text = data['userName'] ?? '';
    _editTimeController.text = data['appointmentTime'] ?? '';

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Appointment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInput(_editDoctorController, 'Doctor Name'),
                  _buildInput(
                    _editSpecializationController,
                    'doctorSpecialization',
                  ),
                  _buildInput(_editPatientController, 'Patient Name'),
                  _buildInput(_editTimeController, 'Appointment Time'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await doc.reference.update({
                    'doctorName': _editDoctorController.text.trim(),
                    'doctorSpecialization':
                        _editSpecializationController.text.trim(),
                    'userName': _editPatientController.text.trim(),
                    'appointmentTime': _editTimeController.text.trim(),
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (_, i) {
            final data = users[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Text(data['email'] ?? ''),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed:
                    () => setState(
                      () => doctorSortDescending = !doctorSortDescending,
                    ),
                icon: Icon(
                  doctorSortDescending
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                ),
                label: const Text('Name'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('doctors')
                    .orderBy('name', descending: doctorSortDescending)
                    .snapshots(),
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final doctors = snapshot.data!.docs;
              return ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (_, i) {
                  final doc = doctors[i];
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                      ),
                      title: Text(data['name'] ?? 'Unnamed'),
                      subtitle: Text(data['doctorSpecialization'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddDoctorDialog(doc: doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => doc.reference.delete(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final appointments = snapshot.data!.docs;
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (_, i) {
            final data = appointments[i].data() as Map<String, dynamic>;

            // FORMAT time into AM/PM properly
            String formattedTime = data['appointmentTime'] ?? '';
            try {
              final inputFormat = DateFormat('HH:mm');
              final outputFormat = DateFormat('hh:mm a');
              final dateTime = inputFormat.parse(formattedTime);
              formattedTime = outputFormat.format(dateTime);
            } catch (e) {
              // If parsing fails, keep original
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(
                  'Doctor: ${data['doctorName']} (${data['doctorSpecialization'] ?? 'No Specialization'})',

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Patient: ${data['userName']}\nDate: $formattedTime',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => _showEditAppointmentDialog(appointments[i]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => appointments[i].reference.delete(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: const Center(
                child: Text(
                  'Admin Menu',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ),
            _buildDrawerItem(Icons.people, 'Users'),
            _buildDrawerItem(Icons.local_hospital, 'Doctors'),
            _buildDrawerItem(Icons.calendar_month, 'Appointments'),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Padding(
          key: ValueKey<String>(selectedSection),
          padding: const EdgeInsets.all(12),
          child:
              selectedSection == 'Users'
                  ? _buildUsersList()
                  : selectedSection == 'Doctors'
                  ? _buildDoctorList()
                  : _buildAppointmentsList(),
        ),
      ),
      floatingActionButton:
          selectedSection == 'Doctors'
              ? FloatingActionButton(
                backgroundColor: primaryColor,
                onPressed: () => _showAddDoctorDialog(),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedSection == title,
      onTap: () {
        setState(() {
          selectedSection = title;
          Navigator.pop(context);
        });
      },
    );
  }
}
