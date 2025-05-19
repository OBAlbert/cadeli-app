import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_page.dart';
import 'screens/main_page.dart';
import 'screens/verify_email_page.dart'; // we'll create this next

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadeli App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFFA1BDC7), // grey-blue palette
        primaryColor: Colors.blueAccent,
      ),
      home: const AuthGate(), // 👈 handles logic
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    } else if (!user.emailVerified) {
      return const VerifyEmailPage(); // 👈 next step
    } else {
      return const MainPage();
    }
  }
}
