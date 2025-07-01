// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Import your screens
import 'package:pcos_app/screens/login_screen.dart';
import 'package:pcos_app/screens/home_screen.dart';
import 'package:pcos_app/screens/onboarding_screen.dart';
import 'package:pcos_app/screens/splash_screen.dart'; // Import the SplashScreen

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
      title: 'PCOS Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set SplashScreen as the initial home screen
      home: const SplashScreen(), // This widget determines where to go first
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper: Connection waiting...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        print('AuthWrapper: User is ${user == null ? 'NOT logged in' : 'logged in: ${user.uid}'}');

        if (user == null) {
          // No user logged in, go to Login Screen
          return const LoginScreen();
        } else {
          // User is logged in, check if onboarding is complete
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                print('AuthWrapper: User doc fetching...');
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userDocSnapshot.hasError) {
                print('AuthWrapper: Error fetching user doc: ${userDocSnapshot.error}');
                return Scaffold(
                  body: Center(child: Text('Error: ${userDocSnapshot.error}')),
                );
              }

              final userData = userDocSnapshot.data?.data() as Map<String, dynamic>?;
              final onboardingComplete = userData?['onboardingComplete'] ?? false; // Default to false if not set

              print('AuthWrapper: User data fetched. Onboarding complete: $onboardingComplete');

              if (onboardingComplete) {
                // Onboarding complete, go to Home Screen
                return const HomeScreen();
              } else {
                // User logged in but onboarding not complete, go to Onboarding Screen
                return const OnboardingScreen();
              }
            },
          );
        }
      },
    );
  }
}
