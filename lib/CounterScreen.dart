import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DashboardScreen.dart';
import 'main.dart';

class CounterScreen extends StatefulWidget {
  final String? counterName;

  const CounterScreen({super.key, this.counterName});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  late var _gradientColors;
  final _lightGradients = Color(0xFFFFFFFF);

   final _darkGradients = Colors.black87;

  void _incrementCounter() {
    HapticFeedback.heavyImpact();
    setState(() {
      _counter++;
    });
  }

  Future<void> saveCounter(String name, int value) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, int> counters = {};

    // Load existing
    final keys = prefs.getKeys();
    for (var key in keys) {
      final value = prefs.get(key);
      if (value is int) {
        counters[key] = prefs.getInt(key) ?? 0;
      }
    }

    // Add/Update
    counters[name] = value;

    // Save individually (SharedPreferences has no Map storage)
    for (var entry in counters.entries) {
      await prefs.setInt(entry.key, entry.value);
    }
  }

  Future<void> promptAndSave() async {
    String counterName = "";
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          title: const Row(
            children: [
              Icon(Icons.save, color: Colors.black87),
              SizedBox(width: 8),
              Text("Save Counter", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            onChanged: (val) => counterName = val,
            decoration: InputDecoration(
              hintText: "Enter counter name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.black87),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(color: Colors.black87, width: 2), // Focused border
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 12, bottom: 8),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await saveCounter(name, _counter);
                  Navigator.pop(context); // Close dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => DashboardScreen()),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    final isDark = themeNotifier.value == ThemeMode.dark;
    setState(() {
      _counter = 0;
    });
  }

  void _toggleTheme() {
    themeNotifier.value = themeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    // Update background when switching theme
    final isDark = themeNotifier.value == ThemeMode.dark;
    setState(() {
      _gradientColors = isDark
          ? _darkGradients
          : _lightGradients;
    });
  }

  @override
  void initState() {
    super.initState();
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (widget.counterName != null) {
      loadCounter(widget.counterName!);
    }
    _gradientColors = isDark
        ? Colors.black87
        : Color(0xFFFFFFFF);
  }

  Future<void> loadCounter(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(name) ?? 0;
    });
  }

  Future<bool> _onWillPop() async {
    bool confirmExit = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.black87),
            SizedBox(width: 8),
            Text("Discard Changes?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Do you want to leave without saving your counter?",
          style: TextStyle(fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Stay
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () {
              confirmExit = true;
              Navigator.of(context).pop(); // Leave
            },
            child: const Text("Leave"),
          ),
        ],
      ),
    );


    return confirmExit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = themeNotifier.value == ThemeMode.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: _incrementCounter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            color: _gradientColors
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.save),
                  tooltip: 'Save Counter',
                  onPressed: () async {
                    if (widget.counterName != null) {
                      await saveCounter(widget.counterName!, _counter);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => DashboardScreen()),
                      );
                    } else {
                      await promptAndSave();
                    }
                  },
                )
              ],
            ),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tap Anywhere to Count!',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeOutBack,
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                  opacity: animation, child: child),
                            ),
                        child: Text(
                          '$_counter',
                          key: ValueKey<int>(_counter),
                          style: theme.textTheme.headlineMedium!.copyWith(
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 3,
                                color:
                                isDark ? Colors.black26 : Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TweenAnimationBuilder(
                        tween: Tween<double>(
                            begin: 1.0, end: _counter == 0 ? 1.0 : 1.1),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: ElevatedButton.icon(
                          onPressed: _resetCounter,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Reset Counter"),
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