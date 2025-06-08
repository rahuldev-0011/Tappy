import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappy/DashboardScreen.dart';

import 'AnimatedPopup.dart';
import 'main.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  bool showCheckmark = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showErrorNotification(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    final duration = Duration(milliseconds: 300);

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: AnimatedPopup(
                message: message,
                duration: duration,
                onDismissed: () => overlayEntry.remove(),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3), // or #121212 for near-black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Title
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: Column(
                  children: [
                    Text(
                      'Create Profile',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Adjust color based on theme
                      ),
                    ),
                    Text(
                      'Profile Time – Make It Snazzy!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 250,
                child: TextField(
                  controller: _nameController,
                  maxLength: 20,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black87.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              ),
            ),

            // Bottom button and text
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Material(
                  color: Colors.black87, // Button background
                  borderRadius: BorderRadius.circular(37),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(37),
                    onTap: () async {
                      HapticFeedback.heavyImpact();
                      FocusScope.of(context).unfocus();
                      final name = _nameController.text.trim();

                      if (name.isEmpty) {
                        _showErrorNotification("Please enter your name.");
                        return;
                      }

                      await Future.delayed(const Duration(milliseconds: 100));

                      // Save onboarding flag
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('username', name);
                      await prefs.setBool('hasOnboarded', true);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardScreen()),
                            (Route<dynamic> route) => false, // Remove all previous routes
                      );
                    },
                    child: Container(
                      width: 103,
                      height: 70,
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
