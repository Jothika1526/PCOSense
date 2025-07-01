// // lib/screens/login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pcos_app/screens/home_screen.dart';
// import 'package:pcos_app/screens/onboarding_screen.dart';
// import 'package:pcos_app/screens/sign_up_screen.dart'; // NEW import for SignUpScreen
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   // --- Helper function for navigation after successful auth ---
//   Future<void> _handlePostAuthNavigation(User user) async {
//     // Fetch user document to check onboarding status
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .get();
//
//     bool onboardingComplete = false;
//     if (userDoc.exists) {
//       final userData = userDoc.data() as Map<String, dynamic>?;
//       onboardingComplete = userData?['onboardingComplete'] ?? false;
//     } else {
//       // This case should ideally not happen for a newly registered user
//       // as SignUpScreen now creates the doc.
//       // But for robustness (e.g., if user logged in but doc was deleted, or from another auth provider)
//       // we'll ensure a doc exists and assume onboarding is not complete.
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'email': user.email,
//         'createdAt': FieldValue.serverTimestamp(),
//         'onboardingComplete': false,
//       }, SetOptions(merge: true));
//       print('Created user document for existing user with no doc: ${user.email}');
//       onboardingComplete = false;
//     }
//
//     print('LoginScreen: User authenticated: ${user.email}, Onboarding complete: $onboardingComplete');
//
//     if (mounted) {
//       if (onboardingComplete) {
//         // If onboarding is complete, go to Home Screen
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//               (route) => false, // Remove all previous routes
//         );
//       } else {
//         // If onboarding is NOT complete, go to Onboarding Screen
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const OnboardingScreen()),
//               (route) => false, // Remove all previous routes
//         );
//       }
//     }
//   }
//
//   // --- Sign In Function ---
//   Future<void> _signInUser() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null; // Clear previous errors
//     });
//
//     if (_formKey.currentState!.validate()) {
//       try {
//         UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//
//         // After successful sign-in, handle navigation
//         if (mounted && userCredential.user != null) {
//           await _handlePostAuthNavigation(userCredential.user!);
//         }
//
//       } on FirebaseAuthException catch (e) {
//         setState(() {
//           if (e.code == 'user-not-found') {
//             _errorMessage = 'No user found for that email.';
//           } else if (e.code == 'wrong-password') {
//             _errorMessage = 'Wrong password provided for that user.';
//           } else if (e.code == 'invalid-email') {
//             _errorMessage = 'The email address is not valid.';
//           } else {
//             _errorMessage = 'Login failed: ${e.message}';
//           }
//         });
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'An unexpected error occurred: $e';
//         });
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false; // Always ensure loading is off
//           });
//         }
//       }
//     } else { // If form validation fails, ensure isLoading is false
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Removed _registerUser() function from LoginScreen as it's now in SignUpScreen
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('PCOS Tracker Login')),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 Text(
//                   'Welcome to PCOS Tracker',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.email),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!value.contains('@') || !value.contains('.')) {
//                       return 'Please enter a valid email address';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.lock),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters long';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 if (_errorMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 10.0),
//                     child: Text(
//                       _errorMessage!,
//                       style: const TextStyle(color: Colors.red, fontSize: 14),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _signInUser,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     backgroundColor: Theme.of(context).primaryColor,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                     'Log In',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextButton(
//                   onPressed: _isLoading
//                       ? null
//                       : () {
//                     // Navigate to the new SignUpScreen
//                     Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => const SignUpScreen()),
//                     );
//                   },
//                   child: Text(
//                     'Don\'t have an account? Sign Up',
//                     style: TextStyle(color: Theme.of(context).colorScheme.secondary),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcos_app/screens/home_screen.dart';
import 'package:pcos_app/screens/onboarding_screen.dart';
import 'package:pcos_app/screens/sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Helper function for navigation after successful auth ---
  Future<void> _handlePostAuthNavigation(User user) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    bool onboardingComplete = false;
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>?;
      onboardingComplete = userData?['onboardingComplete'] ?? false;
    } else {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingComplete': false,
      }, SetOptions(merge: true));
      print('Created user document for existing user with no doc: ${user.email}');
      onboardingComplete = false;
    }

    print('LoginScreen: User authenticated: ${user.email}, Onboarding complete: $onboardingComplete');

    if (mounted) {
      if (onboardingComplete) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              (route) => false,
        );
      }
    }
  }

  // --- Sign In Function ---
  Future<void> _signInUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted && userCredential.user != null) {
          await _handlePostAuthNavigation(userCredential.user!);
        }

      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            _errorMessage = 'No user found for that email.';
          } else if (e.code == 'wrong-password') {
            _errorMessage = 'Wrong password provided for that user.';
          } else if (e.code == 'invalid-email') {
            _errorMessage = 'The email address is not valid.';
          } else {
            _errorMessage = 'Login failed: ${e.message}';
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows body to go behind transparent app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        // Removed the title property as requested
      ),
      body: Container(
        // Background gradient from home_screen.dart
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.purple.shade100,
              Colors.deepPurple.shade200,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12, // Increased elevation for a more prominent card
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              color: Colors.white.withOpacity(0.95), // Slightly opaque white card
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Make column take minimum space
                    children: <Widget>[
                      // App Logo
                      Image.asset(
                        'assets/logo.jpg', // Path to your logo image
                        height: 120, // Adjust height as needed
                        width: 120, // Adjust width as needed
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay( // Attractive style for greeting
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700, // Darker purple for heading
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sign in to continue your journey.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade800),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none, // Remove default border
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.shade50.withOpacity(0.5), // Light purple fill
                          prefixIcon: Icon(Icons.email, color: Colors.deepPurple.shade400),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade800),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.shade50.withOpacity(0.5),
                          prefixIcon: Icon(Icons.lock, color: Colors.deepPurple.shade400),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Error Message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.montserrat(color: Colors.red.shade700, fontSize: 14, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Login Button
                      Container(
                        width: double.infinity, // Make button full width
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15), // Rounded corners for button
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD3A4F4), Color(0xFF8A2BE2)], // Lighter to Darker Purple
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8A2BE2).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signInUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Colors.transparent, // Make transparent to show gradient
                            shadowColor: Colors.transparent, // No shadow from button itself
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'Log In',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign Up Button (centered)
                      Center( // Centered as requested
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            );
                          },
                          child: Text(
                            'Don\'t have an account? Sign Up',
                            style: GoogleFonts.montserrat(
                              color: Colors.deepPurple.shade700, // Darker purple for text button
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
