import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'main_page.dart';
import 'register_page.dart';
import 'verify_email_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController smsCodeController = TextEditingController();

  final AuthService auth = AuthService();
  String _verificationId = '';
  bool _showPhoneField = false;
  bool _codeSent = false;

  Future<void> login() async {
    final user = await auth.signIn(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      if (!user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } else {
      _showError("Login failed. Please check your credentials.");
    }
  }

  Future<void> loginWithGoogle() async {
    final user = await auth.signInWithGoogle();
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      _showError("Google Sign-In failed.");
    }
  }

  void _sendCode() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) return;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolved
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
      },
      verificationFailed: (FirebaseAuthException e) {
        _showError('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _verifyCode() async {
    final code = smsCodeController.text.trim();
    if (code.isEmpty || _verificationId.isEmpty) return;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
    } catch (e) {
      _showError("Invalid SMS code.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              style: _btnStyle(Colors.purple),
              child: const Text("Login"),
            ),
            const SizedBox(height: 10),
            SignInButton(
              Buttons.GoogleDark,
              text: "Sign in with Google",
              onPressed: loginWithGoogle,
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[700]),
            const SizedBox(height: 10),

            // Phone login toggle
            !_showPhoneField
                ? TextButton(
              onPressed: () => setState(() => _showPhoneField = true),
              child: const Text("Use Phone Number Instead"),
            )
                : Column(
              children: [
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Enter Phone (e.g. +357...)"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                if (_codeSent)
                  TextField(
                    controller: smsCodeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Enter Code"),
                    keyboardType: TextInputType.number,
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _codeSent ? _verifyCode : _sendCode,
                  icon: const Icon(Icons.sms),
                  label: Text(_codeSent ? "Verify Code" : "Send SMS Code"),
                  style: _btnStyle(Colors.blueAccent),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
              },
              child: const Text(
                "Don't have an account? Register",
                style: TextStyle(color: Colors.purpleAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[300]),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ButtonStyle _btnStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    );
  }
}
