import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'verify_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isPhoneSelected = false;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();
      final address = _addressController.text.trim();
      final phone = _phoneController.text.trim();

      UserCredential userCred;

      if (!isPhoneSelected) {
        userCred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await userCred.user!.sendEmailVerification();
      } else {
        // NOTE: You can later implement real phone auth flow here using Firebase Phone Auth
        throw Exception("Phone verification not implemented yet");
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'method': isPhoneSelected ? 'phone' : 'email',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception:', '').trim());
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA1BDC7),
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: const Color(0xFF102027),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField("Full Name", _nameController),
            const SizedBox(height: 12),
            _buildField("Address", _addressController),
            const SizedBox(height: 12),

            // Method toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Email"),
                  selected: !isPhoneSelected,
                  onSelected: (_) => setState(() => isPhoneSelected = false),
                  selectedColor: Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("Phone"),
                  selected: isPhoneSelected,
                  onSelected: (_) => setState(() => isPhoneSelected = true),
                  selectedColor: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (isPhoneSelected)
              _buildField("Phone Number", _phoneController)
            else
              _buildField("Email", _emailController),

            const SizedBox(height: 12),
            _buildField("Password", _passwordController, isPassword: true),

            const SizedBox(height: 20),

            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Register"),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
