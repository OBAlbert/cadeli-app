import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in user
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  /// Register user and add Firestore entry
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create Firestore user profile
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          await docRef.set({
            'email': email,
            'fullName': '',
            'address': '',
            'phone': '',
            'bio': '',
            'favourites': [],
            'orderHistory': [],
            'activeOrders': [],
            'createdAt': Timestamp.now(),
          });
          print("User data saved to Firestore");
        } else {
          print("User doc already exists");
        }
      }

      return user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
