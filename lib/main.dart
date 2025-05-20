// lib/main.dart
import 'package:cadeli/models/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'screens/login_page.dart';
import 'screens/main_page.dart';
import 'screens/verify_email_page.dart';
import 'screens/start_page.dart';

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
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cadeli App',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFFA1BDC7),
          primaryColor: Colors.blueAccent,
        ),
        home: const StartPage(),
      ),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Case 1: User is not logged in
    if (user == null) {
      return const LoginPage();
    }

    // Case 2: User is logged in but deleted remotely (we can't access them)
    if (user.email == null || user.uid.isEmpty) {
      FirebaseAuth.instance.signOut(); // auto log them out
      return const LoginPage();
    }

    // Case 3: Email not verified
    if (!user.emailVerified) {
      return const VerifyEmailPage();
    }

    // Case 4: Fully verified and logged in
    return const MainPage();
  }
}


