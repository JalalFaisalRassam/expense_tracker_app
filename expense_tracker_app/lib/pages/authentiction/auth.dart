import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/pages/authentiction/login_page.dart';
import 'package:expense_tracker/pages/main_page.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  // Initialize Firebase asynchronously (consider using a dedicated initialization function)
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase(); // Call initialization on widget build
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Loading indicator
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error')); // Handle errors gracefully
          } else {
            final user = snapshot.data;
            return user != null ? MainPage() : LoginPage();
          }
        },
      ),
    );
  }
}
