import 'package:flutter/material.dart';
import 'package:tappy/CreateProfileScreen.dart';
import 'package:flutter/services.dart';
import 'PulsingRing.dart';
import 'main.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      body: SafeArea(
        child: Stack(
          children: [
            // Title
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: Text(
                  'tappy',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Adjust color based on theme
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: // In the center of the Stack
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.5;
                      return PulsingRing(delay: delay);
                    }),
                  ),
                ),
              ),

            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Track anything with ease. Tap "→" to start counting and stay on top of your progress!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Material(
                      color: Colors.black87, // Button background
                      borderRadius: BorderRadius.circular(37),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(37), // Must match Material's radius
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
                          );
                        },
                        child: Container(
                          width: 103,
                          height: 70,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


