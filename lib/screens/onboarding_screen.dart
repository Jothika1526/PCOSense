// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart'; // Ensure you have intl: ^0.19.0 in pubspec.yaml
// import 'package:pcos_app/screens/home_screen.dart'; // Ensure this path is correct
//
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   final List<GlobalKey<FormState>> _formKeys = [
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//   ];
//
//   int _currentPage = 0;
//   DateTime? _lastPeriodStartDate;
//   TextEditingController _averagePeriodDurationController = TextEditingController();
//   TextEditingController _typicalCycleLengthController = TextEditingController();
//   int? _reproductiveCategory;
//   bool? _hasPCOS;
//   bool? _generalUnusualBleeding;
//
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _averagePeriodDurationController.dispose();
//     _typicalCycleLengthController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _lastPeriodStartDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor, // Header background color
//               onPrimary: Colors.white, // Header text color
//               onSurface: Colors.black, // Body text color
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Theme.of(context).primaryColor, // Button text color
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _lastPeriodStartDate) {
//       setState(() {
//         _lastPeriodStartDate = picked;
//       });
//       // IMPORTANT: Removed direct validation call here. Validation for the date
//       // field is now handled by the manual check in _nextPage() and other
//       // form fields' validators will run when _nextPage() validates the form.
//     }
//   }
//
//   Future<void> _saveOnboardingData() async {
//     // Validation is already handled in _nextPage before calling this method
//     setState(() {
//       _isLoading = true;
//     });
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       print('Error: User not logged in during save data.');
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }
//
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'email': user.email,
//         'lastPeriodStartDate': _lastPeriodStartDate?.toIso8601String(), // Store as ISO 8601 string
//         'averagePeriodDuration': int.tryParse(_averagePeriodDurationController.text),
//         'typicalCycleLength': int.tryParse(_typicalCycleLengthController.text),
//         'hasPCOS': _hasPCOS,
//         'reproductiveCategory': _reproductiveCategory,
//         'generalUnusualBleeding': _generalUnusualBleeding,
//         'onboardingComplete': true, // Mark onboarding as complete
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true)); // Use merge: true to update existing fields
//
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//       }
//     } catch (e) {
//       print('Error saving onboarding data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save data: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _nextPage() {
//     // Manual validation for date picker before general form validation
//     if (_currentPage == 0 && _lastPeriodStartDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select your last period start date.')),
//       );
//       return; // Stop if date is not selected
//     }
//
//     // Validate current page's form
//     if (_formKeys[_currentPage].currentState!.validate()) {
//       if (_currentPage < _formKeys.length - 1) {
//         _pageController.nextPage(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeIn,
//         );
//       } else {
//         _saveOnboardingData(); // Submit on the last page
//       }
//     }
//   }
//
//   void _previousPage() {
//     if (_currentPage > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Get Started'),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//         leading: _currentPage > 0
//             ? IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: _previousPage,
//         )
//             : null,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           // Background Gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Theme.of(context).primaryColor.withOpacity(0.1),
//                   Theme.of(context).primaryColor.withOpacity(0.02),
//                   Colors.white,
//                 ],
//               ),
//             ),
//           ),
//           PageView(
//             controller: _pageController,
//             physics: const NeverScrollableScrollPhysics(), // Disable swipe
//             onPageChanged: (int page) {
//               setState(() {
//                 _currentPage = page;
//               });
//             },
//             children: [
//               // Page 1: Cycle Basics
//               _buildPage(
//                 _formKeys[0],
//                 'Your Cycle Basics',
//                 'Let\'s start with some fundamental information about your cycle.',
//                 [
//                   const SizedBox(height: 20),
//                   _buildDateSelectionTile(context),
//                   const SizedBox(height: 30),
//                   _buildNumberFormField(
//                     controller: _averagePeriodDurationController,
//                     labelText: 'How many days do your periods usually last?',
//                     hintText: 'e.g., 5',
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter duration';
//                       }
//                       final int? duration = int.tryParse(value);
//                       if (duration == null || duration <= 0 || duration > 10) {
//                         return 'Enter a valid number of days (1-10)';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   _buildNumberFormField(
//                     controller: _typicalCycleLengthController,
//                     labelText: 'What is your typical cycle length in days?',
//                     hintText: 'e.g., 28',
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter cycle length';
//                       }
//                       final int? length = int.tryParse(value);
//                       if (length == null || length < 20 || length > 45) {
//                         return 'Enter a valid cycle length (20-45 days)';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//
//               // Page 2: Health & Reproductive Goals
//               _buildPage(
//                 _formKeys[1],
//                 'Your Health Journey',
//                 'Tell us a bit about your health and reproductive goals.',
//                 [
//                   const SizedBox(height: 20),
//                   _buildDropdownFormField<int>(
//                     value: _reproductiveCategory,
//                     hintText: 'Select your reproductive category',
//                     labelText: 'Reproductive Category',
//                     validator: (value) => value == null ? 'Please select a category' : null,
//                     items: const [
//                       // Corrected dropdown items to show only text
//                       DropdownMenuItem(value: 0, child: Text('Regular (25-35 days)')),
//                       DropdownMenuItem(value: 1, child: Text('Long (> 35 days)')),
//                       DropdownMenuItem(value: 2, child: Text('Short (< 25 days)')),
//                       DropdownMenuItem(value: 3, child: Text('Post hormonal')),
//                       DropdownMenuItem(value: 4, child: Text('Pill or injection')),
//                       DropdownMenuItem(value: 5, child: Text('Postpartum (Breastfeeding)')),
//                       DropdownMenuItem(value: 6, child: Text('Postpartum (Not breastfeeding)')),
//                       DropdownMenuItem(value: 7, child: Text('Post miscarriage')),
//                       DropdownMenuItem(value: 8, child: Text('Pre-menopausal')),
//                       DropdownMenuItem(value: 9, child: Text('Other')),
//                     ],
//                     onChanged: (int? newValue) {
//                       setState(() {
//                         _reproductiveCategory = newValue;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   _buildSwitchListTile(
//                     title: 'Have you been diagnosed with PCOS?', // Pass String
//                     value: _hasPCOS ?? false,
//                     onChanged: (bool value) {
//                       setState(() {
//                         _hasPCOS = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   _buildSwitchListTile(
//                     title: 'Have you generally experienced unusual bleeding between periods?', // Pass String
//                     value: _generalUnusualBleeding ?? false,
//                     onChanged: (bool value) {
//                       setState(() {
//                         _generalUnusualBleeding = value;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//
//               // Page 3: Final Confirmation / Intro to Tracking (can be simple)
//               _buildPage(
//                 _formKeys[2],
//                 'Ready to Track!',
//                 'You\'re all set! We\'ll use this info to provide initial predictions. Consistent daily tracking will make them even smarter.',
//                 [
//                   const SizedBox(height: 40),
//                   Icon(Icons.check_circle_outline, size: 100, color: Theme.of(context).primaryColor),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Your journey to understanding your cycle begins now.',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//       bottomNavigationBar: _isLoading
//           ? const SizedBox.shrink()
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             if (_currentPage > 0)
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: _previousPage,
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     foregroundColor: Theme.of(context).primaryColor,
//                     side: BorderSide(color: Theme.of(context).primaryColor),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Text('Back', style: TextStyle(fontSize: 18)),
//                 ),
//               ),
//             if (_currentPage > 0) const SizedBox(width: 16),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _nextPage,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   backgroundColor: Theme.of(context).primaryColor,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: Text( // Changed button text to 'Start'
//                   _currentPage == _formKeys.length - 1 ? 'Start' : 'Next',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- Helper Widgets for Cleaner Code ---
//
//   Widget _buildPage(GlobalKey<FormState> formKey, String title, String subtitle, List<Widget> children) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Form(
//         key: formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).primaryColor.darken(0.1),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 subtitle,
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey[600]),
//               ),
//               const SizedBox(height: 30),
//               ...children,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDateSelectionTile(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         title: Text(
//           _lastPeriodStartDate == null
//               ? 'When did your last period start?'
//               : 'Last Period Start Date: ${DateFormat('MMM dd,yyyy').format(_lastPeriodStartDate!)}',
//           style: const TextStyle(
//             fontSize: 16,
//             color: Colors.black87,
//           ),
//         ),
//         trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
//         onTap: () async {
//           await _selectDate(context);
//           // Removed the direct call to validate() here to prevent premature errors.
//         },
//       ),
//     );
//   }
//
//   Widget _buildNumberFormField({
//     required TextEditingController controller,
//     required String labelText,
//     required String hintText,
//     required String? Function(String?) validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         labelText: labelText,
//         hintText: hintText,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
//         ),
//         fillColor: Colors.white,
//         filled: true,
//       ),
//       validator: validator,
//     );
//   }
//
//   Widget _buildDropdownFormField<T>({
//     required T? value,
//     required String hintText,
//     required String labelText,
//     required String? Function(T?) validator,
//     required List<DropdownMenuItem<T>> items,
//     required ValueChanged<T?> onChanged,
//   }) {
//     return DropdownButtonFormField<T>(
//       decoration: InputDecoration(
//         labelText: labelText,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
//         ),
//         fillColor: Colors.white,
//         filled: true,
//       ),
//       value: value,
//       hint: Text(hintText),
//       validator: validator,
//       items: items,
//       onChanged: onChanged,
//       isExpanded: true,
//     );
//   }
//
//   Widget _buildSwitchListTile({
//     required String title, // Corrected to String
//     required bool value,
//     required ValueChanged<bool> onChanged,
//     String? subtitle,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: SwitchListTile(
//         title: Text( // Text widget is built from the String title
//           title,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         subtitle: subtitle != null ? Text(subtitle) : null,
//         value: value,
//         onChanged: onChanged,
//         activeColor: Theme.of(context).primaryColor,
//       ),
//     );
//   }
// }
//
// // Extension to darken color for better UI
// extension ColorExtension on Color {
//   Color darken([double amount = .1]) {
//     assert(amount >= 0 && amount <= 1);
//     final hsl = HSLColor.fromColor(this);
//     final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
//     return hslDark.toColor();
//   }
// }


//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart'; // Ensure you have intl: ^0.19.0 in pubspec.yaml
// import 'package:pcos_app/screens/home_screen.dart'; // Ensure this path is correct
//
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   final List<GlobalKey<FormState>> _formKeys = [
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//   ];
//
//   int _currentPage = 0;
//   DateTime? _lastPeriodStartDate;
//   final TextEditingController _averagePeriodDurationController = TextEditingController();
//   final TextEditingController _typicalCycleLengthController = TextEditingController();
//   int? _reproductiveCategory;
//   bool? _hasPCOS;
//   bool? _generalUnusualBleeding;
//
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _averagePeriodDurationController.dispose();
//     _typicalCycleLengthController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _lastPeriodStartDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor, // Header background color
//               onPrimary: Colors.white, // Header text color
//               onSurface: Colors.black, // Body text color
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Theme.of(context).primaryColor, // Button text color
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _lastPeriodStartDate) {
//       setState(() {
//         _lastPeriodStartDate = picked;
//       });
//     }
//   }
//
//   Future<void> _saveOnboardingData() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error: User not logged in.')),
//         );
//       }
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }
//
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'email': user.email,
//         'lastPeriodStartDate': _lastPeriodStartDate?.toIso8601String(),
//         'averagePeriodDuration': int.tryParse(_averagePeriodDurationController.text),
//         'typicalCycleLength': int.tryParse(_typicalCycleLengthController.text),
//         'hasPCOS': _hasPCOS,
//         'reproductiveCategory': _reproductiveCategory,
//         'generalUnusualBleeding': _generalUnusualBleeding,
//         'onboardingComplete': true,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to save data: ${e.toString()}')),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _nextPage() {
//     if (_currentPage == 0 && _lastPeriodStartDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select your last period start date.')),
//       );
//       return;
//     }
//
//     if (_formKeys[_currentPage].currentState!.validate()) {
//       if (_currentPage < _formKeys.length - 1) {
//         _pageController.nextPage(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeIn,
//         );
//       } else {
//         _saveOnboardingData();
//       }
//     }
//   }
//
//   void _previousPage() {
//     if (_currentPage > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//         centerTitle: true, // Center the title
//         elevation: 0, // Remove shadow
//         leading: _currentPage > 0
//             ? IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), // Modern back icon
//           onPressed: _previousPage,
//         )
//             : null,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           // Background Gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Theme.of(context).primaryColor.withOpacity(0.1),
//                   Theme.of(context).primaryColor.withOpacity(0.02),
//                   Colors.white,
//                 ],
//               ),
//             ),
//           ),
//           PageView(
//             controller: _pageController,
//             physics: const NeverScrollableScrollPhysics(), // Disable swipe
//             onPageChanged: (int page) {
//               setState(() {
//                 _currentPage = page;
//               });
//             },
//             children: [
//               // Page 1: Cycle Basics
//               _buildPage(
//                 _formKeys[0],
//                 'Your Cycle Basics',
//                 'Let\'s start with some fundamental information about your cycle. This helps us provide accurate insights!',
//                 [
//                   _buildSectionTitle('Last Period Start Date'),
//                   _buildDateSelectionTile(context),
//                   const SizedBox(height: 30),
//                   _buildSectionTitle('Period & Cycle Duration'),
//                   _buildNumberFormField(
//                     controller: _averagePeriodDurationController,
//                     labelText: 'Average Period Duration (days)',
//                     hintText: 'e.g., 5',
//                     icon: Icons.calendar_today, // Added icon
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter duration';
//                       }
//                       final int? duration = int.tryParse(value);
//                       if (duration == null || duration <= 0 || duration > 10) {
//                         return 'Enter a valid number of days (1-10)';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   _buildNumberFormField(
//                     controller: _typicalCycleLengthController,
//                     labelText: 'Typical Cycle Length (days)',
//                     hintText: 'e.g., 28',
//                     icon: Icons.repeat, // Added icon
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter cycle length';
//                       }
//                       final int? length = int.tryParse(value);
//                       if (length == null || length < 20 || length > 45) {
//                         return 'Enter a valid cycle length (20-45 days)';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//
//               // Page 2: Health & Reproductive Goals
//               _buildPage(
//                 _formKeys[1],
//                 'Your Health Journey',
//                 'Tell us a bit about your health and reproductive goals. This helps tailor your experience.',
//                 [
//                   _buildSectionTitle('Reproductive Category'),
//                   _buildDropdownFormField<int>(
//                     value: _reproductiveCategory,
//                     hintText: 'Select your reproductive category',
//                     labelText: 'Reproductive Category',
//                     icon: Icons.category, // Added icon
//                     validator: (value) => value == null ? 'Please select a category' : null,
//                     items: const [
//                       DropdownMenuItem(value: 0, child: Text('Regular (25-35 days)')),
//                       DropdownMenuItem(value: 1, child: Text('Long (> 35 days)')),
//                       DropdownMenuItem(value: 2, child: Text('Short (< 25 days)')),
//                       DropdownMenuItem(value: 3, child: Text('Post hormonal')),
//                       DropdownMenuItem(value: 4, child: Text('Pill or injection')),
//                       DropdownMenuItem(value: 5, child: Text('Postpartum (Breastfeeding)')),
//                       DropdownMenuItem(value: 6, child: Text('Postpartum (Not breastfeeding)')),
//                       DropdownMenuItem(value: 7, child: Text('Post miscarriage')),
//                       DropdownMenuItem(value: 8, child: Text('Pre-menopausal')),
//                       DropdownMenuItem(value: 9, child: Text('Other')),
//                     ],
//                     onChanged: (int? newValue) {
//                       setState(() {
//                         _reproductiveCategory = newValue;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 30),
//                   _buildSectionTitle('Conditions & Symptoms'),
//                   _buildSwitchListTile(
//                     title: 'Diagnosed with PCOS?',
//                     subtitle: 'This helps us provide more relevant insights.',
//                     value: _hasPCOS ?? false,
//                     onChanged: (bool value) {
//                       setState(() {
//                         _hasPCOS = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   _buildSwitchListTile(
//                     title: 'Unusual bleeding between periods?',
//                     subtitle: 'Such as spotting or heavy bleeding outside your regular period.',
//                     value: _generalUnusualBleeding ?? false,
//                     onChanged: (bool value) {
//                       setState(() {
//                         _generalUnusualBleeding = value;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//
//               // Page 3: Final Confirmation / Intro to Tracking
//               _buildPage(
//                 _formKeys[2],
//                 'Ready to Track!',
//                 'You\'re all set! We\'ll use this info to provide initial predictions. Consistent daily tracking will make them even smarter and more accurate.',
//                 [
//                   const SizedBox(height: 40),
//                   // A more engaging icon or illustration can go here
//                   Icon(
//                     Icons.favorite_rounded, // Changed icon for a warmer feel
//                     size: 100,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Your journey to understanding your cycle begins now. Get ready to gain insights and feel empowered!',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                       color: Colors.grey[700],
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//       bottomNavigationBar: _isLoading
//           ? const SizedBox.shrink()
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             if (_currentPage > 0)
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: _previousPage,
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     foregroundColor: Theme.of(context).primaryColor,
//                     side: BorderSide(color: Theme.of(context).primaryColor.darken(0.1)),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Slightly more rounded
//                     backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05), // Light background for back button
//                   ),
//                   child: const Text('Back', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             if (_currentPage > 0) const SizedBox(width: 16),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _nextPage,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   backgroundColor: Theme.of(context).primaryColor,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Slightly more rounded
//                   elevation: 5, // Add a subtle shadow
//                   shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
//                 ),
//                 child: Text(
//                   _currentPage == _formKeys.length - 1 ? 'Start Tracking' : 'Next',
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- Helper Widgets for Cleaner Code ---
//
//   Widget _buildPage(GlobalKey<FormState> formKey, String title, String subtitle, List<Widget> children) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Adjusted padding
//       child: Form(
//         key: formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 30, // Slightly larger title
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).primaryColor.darken(0.15), // Darker primary color
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 subtitle,
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey[600], fontSize: 16),
//               ),
//               const SizedBox(height: 30),
//               ...children,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).primaryColor.darken(0.1),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDateSelectionTile(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15), // More rounded corners
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.15), // Slightly more visible shadow
//             spreadRadius: 1,
//             blurRadius: 7,
//             offset: const Offset(0, 4), // Deeper shadow
//           ),
//         ],
//         border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1), // Subtle border
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Increased padding
//         title: Text(
//           _lastPeriodStartDate == null
//               ? 'Select your last period start date' // More direct call to action
//               : 'Last Period Start Date: ${DateFormat('MMM dd, yyyy').format(_lastPeriodStartDate!)}',
//           style: const TextStyle(
//             fontSize: 17, // Slightly larger font
//             color: Colors.black87,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         trailing: Icon(Icons.calendar_month_rounded, color: Theme.of(context).primaryColor, size: 28), // Updated icon
//         onTap: () async {
//           await _selectDate(context);
//         },
//       ),
//     );
//   }
//
//   Widget _buildNumberFormField({
//     required TextEditingController controller,
//     required String labelText,
//     required String hintText,
//     required String? Function(String?) validator,
//     IconData? icon, // Added optional icon parameter
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         labelText: labelText,
//         hintText: hintText,
//         prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)) : null, // Icon display
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15), // More rounded corners
//           borderSide: BorderSide.none, // No border for filled fields
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1), // Subtle border
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
//         ),
//         errorBorder: OutlineInputBorder( // Error border style
//           borderRadius: BorderRadius.circular(15),
//           borderSide: const BorderSide(color: Colors.red, width: 1),
//         ),
//         focusedErrorBorder: OutlineInputBorder( // Focused error border style
//           borderRadius: BorderRadius.circular(15),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//         fillColor: Colors.white,
//         filled: true,
//         contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Adjusted padding
//       ),
//       validator: validator,
//       cursorColor: Theme.of(context).primaryColor, // Cursor color
//       style: const TextStyle(fontSize: 16),
//     );
//   }
//
//   Widget _buildDropdownFormField<T>({
//     required T? value,
//     required String hintText,
//     required String labelText,
//     required String? Function(T?) validator,
//     required List<DropdownMenuItem<T>> items,
//     required ValueChanged<T?> onChanged,
//     IconData? icon, // Added optional icon parameter
//   }) {
//     return DropdownButtonFormField<T>(
//       decoration: InputDecoration(
//         labelText: labelText,
//         prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)) : null, // Icon display
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15), // More rounded corners
//           borderSide: BorderSide.none, // No border for filled fields
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1), // Subtle border
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: const BorderSide(color: Colors.red, width: 1),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//         fillColor: Colors.white,
//         filled: true,
//         contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//       ),
//       value: value,
//       hint: Text(hintText, style: TextStyle(color: Colors.grey[500])),
//       validator: validator,
//       items: items,
//       onChanged: onChanged,
//       isExpanded: true,
//       dropdownColor: Colors.white, // Dropdown background color
//       style: const TextStyle(fontSize: 16, color: Colors.black87), // Dropdown text style
//       icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).primaryColor), // Custom dropdown icon
//     );
//   }
//
//   Widget _buildSwitchListTile({
//     required String title,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//     String? subtitle,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15), // More rounded corners
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.15),
//             spreadRadius: 1,
//             blurRadius: 7,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1), // Subtle border
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: SwitchListTile(
//         title: Text(
//           title,
//           style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black87),
//         ),
//         subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[600])) : null,
//         value: value,
//         onChanged: onChanged,
//         activeColor: Theme.of(context).primaryColor,
//         activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5), // Lighter track when active
//         inactiveTrackColor: Colors.grey[300], // Inactive track color
//         contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20), // Adjusted padding
//       ),
//     );
//   }
// }
//
// // Extension to darken color for better UI
// extension ColorExtension on Color {
//   Color darken([double amount = .1]) {
//     assert(amount >= 0 && amount <= 1);
//     final hsl = HSLColor.fromColor(this);
//     final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
//     return hslDark.toColor();
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pcos_app/screens/home_screen.dart'; // Ensure this path is correct
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with WidgetsBindingObserver { // Mixin WidgetsBindingObserver
  final PageController _pageController = PageController();
  // We now have 6 pages (indexed 0 to 5)
  final List<GlobalKey<FormState>> _formKeys = List.generate(6, (index) => GlobalKey<FormState>());

  int _currentPage = 0;
  DateTime? _lastPeriodStartDate;
  final TextEditingController _averagePeriodDurationController = TextEditingController();
  final TextEditingController _typicalCycleLengthController = TextEditingController();
  int? _reproductiveCategory;
  bool? _hasPCOS;
  bool? _generalUnusualBleeding;

  bool _isLoading = false;
  bool _isKeyboardVisible = false; // State to control scroll physics

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for keyboard visibility
  }

  @override
  void didChangeMetrics() {
    // This callback is fired when the window metrics change, including keyboard appearing/disappearing
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _averagePeriodDurationController.dispose();
    _typicalCycleLengthController.dispose();

    WidgetsBinding.instance.removeObserver(this); // Remove observer

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Ensure keyboard is hidden before showing date picker
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _lastPeriodStartDate) {
      setState(() {
        _lastPeriodStartDate = picked;
      });
    }
  }

  Future<void> _saveOnboardingData() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'lastPeriodStartDate': _lastPeriodStartDate?.toIso8601String(),
        'averagePeriodDuration': int.tryParse(_averagePeriodDurationController.text),
        'typicalCycleLength': int.tryParse(_typicalCycleLengthController.text),
        'hasPCOS': _hasPCOS,
        'reproductiveCategory': _reproductiveCategory,
        'generalUnusualBleeding': _generalUnusualBleeding,
        'onboardingComplete': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    bool currentPageIsValid = false;

    // Validation for Page 0 (Last Period Start Date)
    if (_currentPage == 0) {
      if (_lastPeriodStartDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your last period start date.')),
        );
        return; // Stay on Page 0
      } else {
        currentPageIsValid = true;
      }
    }
    // Validation for pages with form fields (Pages 1, 2, 3, 4)
    else if (_currentPage < _formKeys.length - 1) { // Not the last page (final confirmation)
      // Check if form key is valid for the current page and its form fields
      if (_formKeys[_currentPage].currentState != null && _formKeys[_currentPage].currentState!.validate()) {
        currentPageIsValid = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please correct the highlighted fields.')),
        );
        return; // Stay on current page if form validation fails
      }
    }
    // For the last page (final confirmation, Page 5), it's always "valid" to proceed to save
    else if (_currentPage == _formKeys.length - 1) {
      currentPageIsValid = true;
    }


    if (currentPageIsValid) {
      // Clear focus when moving to next page to ensure keyboard retracts
      FocusScope.of(context).unfocus();
      if (_currentPage < _formKeys.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        // This is the very last page, save data
        _saveOnboardingData();
      }
    }
  }

  void _previousPage() {
    // Clear focus when moving to previous page to ensure keyboard retracts
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the vector art should be visible
    // Show on pages 0, 1, 2, 3, 4. Hide on page 5 (final confirmation).
    final bool showVectorArt = _currentPage < 5; // Updated for 6 pages

    // Calculate dynamic bottom padding for SingleChildScrollView
    // This padding should account for the bottom navigation bar and the space taken by the image (if present)
    // plus some buffer. MediaQuery.of(context).viewInsets.bottom handles keyboard offset.
    final double bottomNavBarHeight = kToolbarHeight; // Standard height of bottom app bar
    final double vectorArtHeight = MediaQuery.of(context).size.height * 0.4;
    final double baseContentPadding = 20.0; // General padding for content above bottom elements

    // bottomPaddingForScrollView includes space for nav bar and image (if visible)
    final double bottomPaddingForScrollView =
        (showVectorArt ? vectorArtHeight : 0) + bottomNavBarHeight + baseContentPadding;


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Get Started',
          style: GoogleFonts.poppins( // Applied Poppins font
            fontWeight: FontWeight.bold,
            fontSize: 24, // Slightly larger for prominence
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: _previousPage,
        )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Background Gradient (Fixed at the back)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Vector Art Image at the bottom half (Conditional Visibility and Fixed)
          Visibility(
            visible: showVectorArt,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: vectorArtHeight,
              child: Center(
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/front.png', // Ensure this path is correct in your assets
                    fit: BoxFit.contain,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // PageView for Questions (Fills the screen above the background)
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable horizontal swipe between pages
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                // Page 0 (Index 0): Last Period Start Date (1 Question + Original Subtitle)
                _buildQuestionPage(
                  _formKeys[0],
                  'Your Cycle Basics',
                  'Let\'s track your period for personalized insights!',
                  [
                    _buildSectionTitle('Last Period Start Date'),
                    _buildDateSelectionTile(context),
                    const SizedBox(height: 30), // Added buffer
                  ],
                  bottomPadding: bottomPaddingForScrollView,
                  isKeyboardVisible: _isKeyboardVisible,
                ),

                // Page 1 (Index 1): Average Period Duration & Typical Cycle Length (2 Questions - No Subtitle)
                _buildQuestionPage(
                  _formKeys[1],
                  'Your Cycle Basics',
                  'Tell us about your typical cycle.',
                  [
                    _buildSectionTitle('Period & Cycle Duration'),
                    _buildNumberFormField(
                      controller: _averagePeriodDurationController,
                      labelText: 'Average Period Duration (days)',
                      hintText: 'e.g., 5',
                      icon: Icons.calendar_today,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter duration';
                        }
                        final int? duration = int.tryParse(value);
                        if (duration == null || duration <= 0 || duration > 10) {
                          return '1-10 days expected';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20), // Spacing between fields
                    _buildNumberFormField(
                      controller: _typicalCycleLengthController,
                      labelText: 'Typical Cycle Length (days)',
                      hintText: 'e.g., 28',
                      icon: Icons.repeat,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter cycle length';
                        }
                        final int? length = int.tryParse(value);
                        if (length == null || length < 20 || length > 45) {
                          return '20-45 days expected';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30), // Added buffer
                  ],
                  bottomPadding: bottomPaddingForScrollView,
                  isKeyboardVisible: _isKeyboardVisible,
                ),

                // Page 2 (Index 2): Reproductive Category (1 Question - No Subtitle)
                _buildQuestionPage(
                  _formKeys[2],
                  'Your Health Journey',
                  'Select what best describes your reproductive stage.',
                  [
                    _buildSectionTitle('Reproductive Category'),
                    _buildDropdownFormField<int>(
                      value: _reproductiveCategory,
                      hintText: 'Select your category',
                      icon: Icons.category,
                      validator: (value) => value == null ? 'Please select a category' : null,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Regular (25-35 days)')),
                        DropdownMenuItem(value: 1, child: Text('Long (> 35 days)')),
                        DropdownMenuItem(value: 2, child: Text('Short (< 25 days)')),
                        DropdownMenuItem(value: 3, child: Text('Post hormonal')),
                        DropdownMenuItem(value: 4, child: Text('Pill or injection')),
                        DropdownMenuItem(value: 5, child: Text('Postpartum (Breastfeeding)')),
                        DropdownMenuItem(value: 6, child: Text('Postpartum (Not breastfeeding)')),
                        DropdownMenuItem(value: 7, child: Text('Post miscarriage')),
                        DropdownMenuItem(value: 8, child: Text('Pre-menopausal')),
                        DropdownMenuItem(value: 9, child: Text('Other')),
                      ],
                      onChanged: (int? newValue) {
                        setState(() {
                          _reproductiveCategory = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 30), // Added buffer
                  ],
                  bottomPadding: bottomPaddingForScrollView,
                  isKeyboardVisible: _isKeyboardVisible,
                ),

                // Page 3 (Index 3): Diagnosed with PCOS? (1 Question - No Subtitle)
                _buildQuestionPage(
                  _formKeys[3],
                  'Your Health Journey',
                  'This helps us tailor your experience.',
                  [
                    _buildSectionTitle('PCOS Diagnosis'),
                    _buildSwitchListTile(context, // Pass context here
                      title: 'Are you diagnosed with PCOS?',
                      subtitle: '', // Shorter subtitle
                      value: _hasPCOS ?? false,
                      onChanged: (bool value) {
                        setState(() {
                          _hasPCOS = value;
                        });
                      },
                    ),
                    const SizedBox(height: 30), // Added buffer
                  ],
                  bottomPadding: bottomPaddingForScrollView,
                  isKeyboardVisible: _isKeyboardVisible,
                ),

                // Page 4 (Index 4): Unusual bleeding between periods? (1 Question - No Subtitle)
                _buildQuestionPage(
                  _formKeys[4],
                  'Your Health Journey',
                  'Understanding your patterns is key.',
                  [
                    _buildSectionTitle('Unusual Bleeding?'),
                    _buildSwitchListTile(context, // Pass context here
                      title: 'Experience unusual bleeding?',
                      subtitle: 'e.g., spotting outside your period.', // Shorter subtitle
                      value: _generalUnusualBleeding ?? false,
                      onChanged: (bool value) {
                        setState(() {
                          _generalUnusualBleeding = value;
                        });
                      },
                    ),
                    const SizedBox(height: 30), // Added buffer
                  ],
                  bottomPadding: bottomPaddingForScrollView,
                  isKeyboardVisible: _isKeyboardVisible,
                ),


                // Page 5 (Index 5): Final Confirmation / Intro to Tracking (No Vector Art)
                _buildQuestionPage(
                  _formKeys[5], // Use valid form key for consistency
                  'Ready to Track!',
                  'Daily tracking makes your insights even smarter.', // This is the main subtitle
                  <Widget>[
                    const SizedBox(height: 40),
                    Center(
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 200, // Large heart
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // The main subtitle is handled by _buildQuestionPage itself.
                    // Add more descriptive text below the heart and the main subtitle.
                    Text(
                      'We\'re excited to support you on your journey.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Start logging your symptoms, periods, and more to unlock personalized insights.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                  // Apply custom styles for title and main subtitle on this page
                  titleStyle: GoogleFonts.pacifico(
                    fontSize: 40, // Make the title bigger
                    color: Theme.of(context).primaryColor.darken(0.15),
                    fontWeight: FontWeight.bold,
                  ),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.grey.shade700,
                    fontSize: 18, // Slightly larger
                    fontWeight: FontWeight.w600, // Made it bolder
                    height: 1.5,
                  ),
                  bottomPadding: bottomPaddingForScrollView,
                  isKeyboardVisible: _isKeyboardVisible,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading
          ? const SizedBox.shrink()
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor.darken(0.1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins( // Applied Poppins font
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                child: Text(
                  _currentPage == _formKeys.length - 1 ? 'Start Tracking' : 'Next',
                  style: GoogleFonts.poppins( // Applied Poppins font
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for Cleaner Code ---

  Widget _buildQuestionPage(
      GlobalKey<FormState> formKey,
      String title,
      String subtitle,
      List<Widget> children, {
        required double bottomPadding,
        required bool isKeyboardVisible, // Pass keyboard visibility state
        TextStyle? titleStyle, // New optional titleStyle parameter
        TextStyle? subtitleStyle, // New optional subtitleStyle parameter
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          // Only enable scrolling if the keyboard is visible
          physics: isKeyboardVisible ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
          // Add viewInsets.bottom here to automatically adjust padding when keyboard is up
          padding: EdgeInsets.only(bottom: bottomPadding + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: titleStyle ?? // Use provided style or fallback to default
                    TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor.darken(0.15),
                    ),
              ),
              if (subtitle.isNotEmpty) // Conditionally show subtitle
                const SizedBox(height: 10),
              if (subtitle.isNotEmpty) // Conditionally show subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: subtitleStyle ?? // Use provided style or fallback to default
                      Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey.shade600, fontSize: 16),
                ),
              const SizedBox(height: 30), // Consistent spacing
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor.darken(0.1),
        ),
      ),
    );
  }

  Widget _buildDateSelectionTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        leading: Icon(Icons.event_note_rounded, color: Theme.of(context).primaryColor, size: 28), // Enhanced icon
        title: Text(
          _lastPeriodStartDate == null
              ? 'Select your last period start date'
              : 'Period Start: ${DateFormat('MMM dd,yyyy').format(_lastPeriodStartDate!)}', // Shorter text
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.calendar_month_rounded, color: Theme.of(context).primaryColor, size: 28),
        onTap: () async {
          await _selectDate(context);
        },
      ),
    );
  }

  Widget _buildNumberFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String? Function(String?) validator,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: validator,
      cursorColor: Theme.of(context).primaryColor,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDropdownFormField<T>({
    required T? value,
    required String hintText,
    // labelText is explicitly empty string in usage, no need for parameter
    required String? Function(T?) validator,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: '', // Set this to an empty string for a cleaner look
        floatingLabelBehavior: FloatingLabelBehavior.never, // Ensures label doesn't float when selected
        prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      value: value,
      hint: Text(hintText, style: TextStyle(color: Colors.grey[500])),
      validator: validator,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      dropdownColor: Colors.white,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildSwitchListTile(BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: Colors.grey[600])) : null,
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        inactiveThumbColor: Colors.grey[300],
        inactiveTrackColor: Colors.grey[200],
      ),
    );
  }
}

// Extension to darken a color - This should only appear ONCE in the file.
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}