import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: user == null
          ? const Center(child: Text("User not found"))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Welcome, ${user.email}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// ACTIVE ORDERS
            const Text("Active Orders", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              color: Colors.blue[50],
              child: ListTile(
                title: const Text("Order #12345"),
                subtitle: const Text("Status: Preparing"),
              ),
            ),

            const SizedBox(height: 20),

            /// FAVOURITES (scrollable)
            const Text("Favourites", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  5,
                      (index) => Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.teal[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text("Item ${index + 1}")),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ORDER HISTORY
            const Text("Order History", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text("Order #12234"),
                subtitle: const Text("Delivered on May 12"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Order #12210"),
                subtitle: const Text("Delivered on May 10"),
              ),
            ),

            const SizedBox(height: 20),

            /// ADDRESS & PHONE (hardcoded for now)
            const Text("Contact Info", style: TextStyle(fontSize: 16)),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text("+357 99 999999"),
            ),
            const ListTile(
              leading: Icon(Icons.location_on),
              title: Text("Larnaca, Cyprus"),
            ),
          ],
        ),
      ),
    );
  }
}
