import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';
import 'package:healthmate/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _selectedSex;
  String? _selectedAge;
  DateTime? _selectedDate;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('agree_terms_validation'.tr())));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: _passwordController.text.trim(),
          );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': email,
        'sex': _selectedSex,
        'age': _selectedAge,
        'dob': _selectedDate?.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      });

      await AuthService().sendOtpToEmail(email);

      final isVerified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email)),
      );

      if (isVerified == true) {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'isVerified': true});

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('account_created'.tr())));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('otp_verification_failed'.tr())));
      }
    } on FirebaseAuthException catch (e) {
      String error = e.message ?? 'signup_failed'.tr();
      if (e.code == 'email-already-in-use') error = 'email_in_use'.tr();
      if (e.code == 'weak-password') error = 'weak_password'.tr();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_generic'.tr(args: [e.toString()]))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/SignUp.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.setLocale(const Locale('en')),
                    child: const Text('English'),
                  ),
                  TextButton(
                    onPressed: () => context.setLocale(const Locale('ne')),
                    child: const Text('नेपाली'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _nameController,
                icon: Icons.person,
                label: 'name'.tr(),
                validator: (value) => value!.isEmpty ? 'enter_name'.tr() : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                icon: Icons.email,
                label: 'email'.tr(),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'enter_email'.tr();
                  if (!value.contains('@')) return 'invalid_email'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _passwordController,
                label: 'password'.tr(),
                obscureText: _obscurePassword,
                toggleVisibility:
                    () => setState(() => _obscurePassword = !_obscurePassword),
                validator:
                    (value) =>
                        value!.length < 6 ? 'min_password_length'.tr() : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'confirm_password'.tr(),
                obscureText: _obscureConfirm,
                toggleVisibility:
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator:
                    (value) =>
                        value != _passwordController.text
                            ? 'password_mismatch'.tr()
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSex,
                decoration: _dropdownDecoration(
                  'Select Sex'.tr(),
                  icon: Icons.transgender,
                ),
                items:
                    ['male'.tr(), 'female'.tr(), 'others'.tr()]
                        .map(
                          (sex) =>
                              DropdownMenuItem(value: sex, child: Text(sex)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedSex = value),
                validator:
                    (value) =>
                        value == null ? 'select_sex_validation'.tr() : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAge,
                decoration: _dropdownDecoration(
                  'Select Age'.tr(),
                  icon: Icons.cake,
                ),
                items:
                    ['under_18', '18_24', '25_34', '35_44', '45_54', '55_plus']
                        .map(
                          (ageKey) => DropdownMenuItem(
                            value: ageKey.tr(),
                            child: Text(ageKey.tr()),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedAge = value),
                validator:
                    (value) =>
                        value == null ? 'select_age_validation'.tr() : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _dropdownDecoration(
                      'Dob'.tr(),
                      icon: Icons.calendar_today,
                    ),
                    controller: TextEditingController(
                      text:
                          _selectedDate == null
                              ? ''
                              : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                    ),
                    validator:
                        (_) =>
                            _selectedDate == null
                                ? 'dob_validation'.tr()
                                : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ FIXED: Terms and Conditions Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() => _agreedToTerms = value ?? false);
                    },
                    activeColor: Colors.green,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                      child: Text(
                        'agree_terms'.tr(),
                        style: const TextStyle(
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'signup_button'.tr(),
                          style: const TextStyle(fontSize: 18),
                        ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                  child: Text('already_account'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.png',
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "signup".tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0.5, 0.5),
                blurRadius: 1,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _dropdownDecoration(label, icon: icon),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        prefixIcon: const Icon(Icons.lock, color: Colors.green),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.green,
          ),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
