import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Color primaryColor = Color(0xFF4A90E2);
  final Color backgroundColor = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Counter',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF2C2C2C),
        // Dark grey background
        primaryColor: Color(0xFFBB86FC),
        // Keep the button color
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            backgroundColor: Color(0xFFBB86FC),
            foregroundColor: Colors.white,
            elevation: 6,
            textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double buttonSize = 60.0;
  double offsetX = 0.0;
  double offsetY = 0.0;
  int counter = 0;

  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _controller.addListener(() {
      setState(() {
        offsetX = _animation.value.dx;
        offsetY = _animation.value.dy;
      });
    });
  }

  void resetPosition() {
    _animation = Tween<Offset>(
      begin: Offset(offsetX, offsetY),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleDrag(
      DragUpdateDetails details, double maxWidth, double maxHeight) {
    setState(() {
      offsetX += details.delta.dx;
      offsetY += details.delta.dy;

      // Clamp to boundaries
      offsetX = offsetX.clamp(
        -(maxWidth / 2 - buttonSize / 2),
        (maxWidth / 2 - buttonSize / 2),
      );
      offsetY = offsetY.clamp(
          0.0,
          0.0
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = 250;
    double containerHeight = 100;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          // Padding added
          child: Container(
            width: containerWidth,
            height: containerHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF202020), // Light grey container
              borderRadius: BorderRadius.circular(containerHeight / 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ➖ Button (Left Side)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.remove, size: 30),
                    onPressed: () {
                      if (counter > 0) {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          counter--;
                        });
                      }
                    },
                  ),
                ),

                // ➕ Button (Right Side)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.add, size: 30),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        counter++;
                      });
                    },
                  ),
                ),

                // 🔘 Draggable Counter Button
                Transform.translate(
                  offset: Offset(offsetX, offsetY),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      handleDrag(details, containerWidth, containerHeight);
                    },
                    onPanEnd: (details) {
                      if (offsetY > 30) {
                        setState(() {
                          counter = 0;
                        });
                      } else if (offsetX > 20) {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          counter++;
                        });
                      } else if (offsetX < -20) {
                        if (counter > 0) {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            counter--;
                          });
                        }
                      }

                      resetPosition();
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          counter++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Color(0xFF3B3B3B),
                        // Button background color
                        foregroundColor: Colors.white, // Button text color
                      ),
                      child: Text(
                        '$counter',
                        style: const TextStyle(
                            fontSize: 45, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
