import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcos_app/packed_food/pack_foods_scan.dart'; // Import your packed food screen
import 'package:pcos_app/cooked_food/cooked_food_screen.dart'; // Import your cooked food screen

class FoodOptionsScreen extends StatelessWidget {
  const FoodOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: colorScheme is not strictly needed for the new custom colors,
    // but kept for reference if other parts of the theme are used.
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Logging Options',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOptionCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: 'Scan Food (Packed)',
                  subtitle: 'Scan to analyze packed food for PCOS diet insights',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ImageToTextScreen(),
                      ),
                    );
                  },
                  color: Color(0xFF8EBF75), // Changed to a new color
                ),
                const SizedBox(height: 30),
                _buildOptionCard(
                  context,
                  icon: Icons.fastfood, // A relevant icon for cooked food
                  title: 'Analyze Cooked Food',
                  subtitle: 'Upload photos of home-cooked meals for PCOS dietary suggestions',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FoodCaptureScreen(),
                      ),
                    );
                  },
                  color: Colors.blueAccent.shade700, // Changed to a new color
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 45, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}