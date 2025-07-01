// // lib/screens/signup_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pcos_app/screens/onboarding_screen.dart'; // Import OnboardingScreen
//
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController(); // Added name controller
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _registerUser() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null; // Clear previous errors
//     });
//
//     if (_formKey.currentState!.validate()) {
//       try {
//         UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//
//         // If registration is successful, create a user document in Firestore
//         if (userCredential.user != null) {
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(userCredential.user!.uid)
//               .set({
//             'name': _nameController.text.trim(), // Save the name
//             'email': userCredential.user!.email,
//             'createdAt': FieldValue.serverTimestamp(),
//             'onboardingComplete': false, // New users start with onboarding incomplete
//             // You can add more initial fields here if needed
//           });
//           print('User registered and document created: ${userCredential.user!.email}');
//
//           // Navigate to OnboardingScreen after successful registration
//           if (mounted) {
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(builder: (context) => const OnboardingScreen()),
//                   (route) => false, // Remove all previous routes from stack
//             );
//           }
//         }
//       } on FirebaseAuthException catch (e) {
//         setState(() {
//           if (e.code == 'weak-password') {
//             _errorMessage = 'The password provided is too weak.';
//           } else if (e.code == 'email-already-in-use') {
//             _errorMessage = 'An account already exists for that email.';
//           } else if (e.code == 'invalid-email') {
//             _errorMessage = 'The email address is not valid.';
//           } else {
//             _errorMessage = 'Registration failed: ${e.message}';
//           }
//         });
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'An unexpected error occurred: $e';
//         });
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false; // Ensure loading is off
//           });
//         }
//       }
//     } else {
//       // If form validation fails, ensure isLoading is off
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Account'),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//       ),
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
//                   'Sign Up for PCOS Tracker',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 TextFormField(
//                   controller: _nameController,
//                   keyboardType: TextInputType.name,
//                   decoration: const InputDecoration(
//                     labelText: 'Full Name',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
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
//                       return 'Please enter a password';
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
//                   onPressed: _isLoading ? null : _registerUser,
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
//                     'Sign Up',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextButton(
//                   onPressed: _isLoading
//                       ? null
//                       : () {
//                     Navigator.of(context).pop(); // Go back to LoginScreen
//                   },
//                   child: Text(
//                     'Already have an account? Log In',
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

// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcos_app/screens/onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': _nameController.text.trim(),
            'email': userCredential.user!.email,
            'createdAt': FieldValue.serverTimestamp(),
            'onboardingComplete': false,
          });
          print('User registered and document created: ${userCredential.user!.email}');

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  (route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'weak-password') {
            _errorMessage = 'The password provided is too weak.';
          } else if (e.code == 'email-already-in-use') {
            _errorMessage = 'An account already exists for that email.';
          } else if (e.code == 'invalid-email') {
            _errorMessage = 'The email address is not valid.';
          } else {
            _errorMessage = 'Registration failed: ${e.message}';
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
        iconTheme: const IconThemeData(color: Colors.white), // Back button icon color
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
                        'Join PCOSense',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay( // Attractive style for greeting
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700, // Darker purple for heading
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Create your account to get started!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Full Name Field
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade800),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.shade50.withOpacity(0.5),
                          prefixIcon: Icon(Icons.person, color: Colors.deepPurple.shade400),
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
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

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
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.shade50.withOpacity(0.5),
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
                            return 'Please enter a password';
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

                      // Sign Up Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD3A4F4), Color(0xFF8A2BE2)],
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
                          onPressed: _isLoading ? null : _registerUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Log In Button (centered)
                      Center( // Centered as requested
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Already have an account? Log In',
                            style: GoogleFonts.montserrat(
                              color: Colors.deepPurple.shade700,
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
