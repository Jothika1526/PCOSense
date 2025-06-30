import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:path/path.dart' as path; // For handling file paths
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http_parser/http_parser.dart' show MediaType; // Added for explicit content type

// Temporary main function to run this screen directly
void main() {
  runApp(const MyAppForCookedFood());
}

class MyAppForCookedFood extends StatelessWidget {
  const MyAppForCookedFood({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooked Food Test App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // You can customize your theme here
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const FoodCaptureScreen(), // This correctly matches the class name below
    );
  }
}

class FoodCaptureScreen extends StatefulWidget {
  const FoodCaptureScreen({super.key});

  @override
  State<FoodCaptureScreen> createState() => _FoodCaptureScreenState();
}

class _FoodCaptureScreenState extends State<FoodCaptureScreen> {
  File? _imageFile; // Stores the selected image
  final TextEditingController _dishNameController = TextEditingController();
  String _backendResponse = "No analysis yet. Upload food to see results!";
  bool _isLoading = false; // To show loading indicator during submission

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Function to pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _backendResponse = "Ready to analyze!"; // Reset message
      });
    }
  }

  // Function to send data to FastAPI backend
  Future<void> _uploadFoodData() async {
    if (_imageFile == null || _dishNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and enter a dish name.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _backendResponse = "Analyzing your food...";
    });

    // IMPORTANT: Update this URL based on where your FastAPI server is running.
    // For phone hotspot to laptop: Use your laptop's actual local IP address.
    // (e.g., 'http://192.168.10.199:8000/upload_food_data/')
    // For Android Emulator: 'http://10.0.2.2:8000/upload_food_data/'
    // For iOS Simulator/Desktop: 'http://127.0.0.1:8000/upload_food_data/' or 'http://localhost:8000/upload_food_data/'
    final uri = Uri.parse('http://192.168.10.199:8000/upload_food_data/'); // <<< VERIFY THIS IP!
    var request = http.MultipartRequest('POST', uri);

    try {
      // Determine the MIME type based on file extension
      String fileExtension = path.extension(_imageFile!.path).toLowerCase();
      String? mimeType;

      if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
        mimeType = 'image/jpeg';
      } else if (fileExtension == '.png') {
        mimeType = 'image/png';
      } else {
        // Handle unsupported file types gracefully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported image format. Please use JPG/JPEG or PNG.')),
        );
        setState(() {
          _isLoading = false;
          _backendResponse = "Error: Unsupported image format.";
        });
        return; // Stop function execution
      }

      // Add image file to the request with explicit content type
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // This 'file' key MUST match the FastAPI @app.post parameter name (file: UploadFile)
          _imageFile!.path,
          filename: path.basename(_imageFile!.path),
          contentType: MediaType('image', fileExtension.substring(1)), // e.g., image/jpeg or image/png
        ),
      );

      // Add dish name field to the request
      request.fields['dish_name'] = _dishNameController.text.trim(); // This 'dish_name' key MUST match FastAPI @app.post parameter name (dish_name: str = Form(...))

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _backendResponse = "Analysis Result: ${responseData['analysis_answer']}";
          _dishNameController.clear(); // Clear input after successful upload
          _imageFile = null; // Clear image preview
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food data uploaded successfully!')),
        );
      } else {
        // Handle non-200 status codes (e.g., 400, 500)
        String errorMessage = 'Failed to upload data. Status: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          if (errorData.containsKey('detail')) {
            errorMessage += '\nDetail: ${errorData['detail']}';
          }
        } catch (e) {
          // If response body is not JSON, use the raw body
          errorMessage += '\nRaw response: ${response.body}';
        }
        setState(() {
          _backendResponse = errorMessage;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Handle network-related errors (e.g., connection timed out, no internet)
      setState(() {
        _backendResponse = 'Network Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
      print('HTTP request error: $e'); // Print detailed error to console for debugging
    } finally {
      setState(() {
        _isLoading = false; // Always stop loading indicator
      });
    }
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Capture Your Food',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            bottom: 20.0 + MediaQuery.of(context).padding.bottom,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Upload a photo of your dish!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              _buildImageInputCard(context),
              const SizedBox(height: 20),
              _buildDishNameInputCard(context),
              const SizedBox(height: 20),
              _buildBackendResponseCard(context),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _uploadFoodData, // Disable when loading
        tooltip: 'Upload Food Data',
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(50),
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isLoading
                    ? [Colors.grey.shade400, Colors.grey.shade600] // Grey out when loading
                    : [const Color(0xFFD3A4F4), const Color(0xFF8A2BE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(
                Icons.cloud_upload_outlined, // Changed icon for clarity
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center the FAB
    );
  }

  Widget _buildImageInputCard(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFFEDE7F6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD1C4E9).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Dish Photo',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imageFile == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text(
                    'No Image Selected',
                    style: GoogleFonts.montserrat(color: Colors.grey.shade500),
                  ),
                ],
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: colorScheme.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Upload Photo'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.secondary, backgroundColor: Colors.white,
                      side: BorderSide(color: colorScheme.secondary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishNameInputCard(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFFEDE7F6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD1C4E9).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dish Name',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _dishNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Chicken Biryani, Caesar Salad',
                labelText: 'Name of your dish',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.5), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                prefixIcon: Icon(Icons.restaurant_menu, color: colorScheme.primary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87),
              cursorColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackendResponseCard(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFFEDE7F6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD1C4E9).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backend Response',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _backendResponse,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.black87,
                  fontStyle: _isLoading ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
