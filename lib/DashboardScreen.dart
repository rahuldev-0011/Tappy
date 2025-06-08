import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappy/CounterScreen.dart';
import 'package:tappy/MyProfileScreen.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  String name = "";

  Map<String, int> counters = {};

  Future<void> loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    Map<String, int> loaded = {};
    for (String key in keys) {
      final value = prefs.get(key);
      if (value is int) {
        loaded[key] = value;
      }
    }

    setState(() {
      counters = loaded;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName();
    loadCounters();
  }

  Future<void> getName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('username');
    if (storedName != null && storedName.isNotEmpty) {
      setState(() {
        name = storedName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'tappy',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black87),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () async {
              HapticFeedback.heavyImpact();
              // Action on tap
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CounterScreen()),
              );
              await loadCounters(); // Refresh after coming back
            },
          ),
          const SizedBox(width: 10,),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProfileScreen()),
                );
                await getName(); // Refresh name after returning

              },
              child: CircleAvatar(
                backgroundColor: Colors.black87,
                radius: 18,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              Expanded(
                child: Scrollbar(
                  thumbVisibility: false,
                  // Always show the scrollbar
                  thickness: 6,
                  radius: const Radius.circular(8),
                  interactive: true,
                  trackVisibility: false,
                  scrollbarOrientation: ScrollbarOrientation.right,
                  child: SlideToDeleteList(
                    counters: counters,
                    reload: loadCounters,
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for sticky footer
            ],
          ),
        ],
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final int count;
  final int total;

  const ProgressCard({
    super.key,
    required this.title,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = count / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              Text(
                "$count/$total",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: count,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.black87],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: total - count,
                    child: Container(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleCounterItem extends StatelessWidget {
  final String title;
  final int count;

  const SimpleCounterItem({
    Key? key,
    required this.title,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class SlideToDeleteList extends StatefulWidget {
  final Map<String, int> counters;
  final Future<void> Function() reload;

  const SlideToDeleteList({
    Key? key,
    required this.counters,
    required this.reload,
  }) : super(key: key);

  @override
  State<SlideToDeleteList> createState() => _SlideToDeleteListState();
}

class _SlideToDeleteListState extends State<SlideToDeleteList> {
  late Map<String, int> _displayedCounters;

  @override
  void initState() {
    super.initState();
    _displayedCounters = Map.from(widget.counters);
  }

  @override
  void didUpdateWidget(covariant SlideToDeleteList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.counters != widget.counters) {
      _displayedCounters = Map.from(widget.counters);
    }
  }

  Future<void> deleteCounter(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(name);
    await widget.reload(); // This triggers parent's loadCounters
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedCounters.isEmpty) {
      return const Center(
        child: Text(
          'No counters yet. Tap + to add one.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      itemCount: _displayedCounters.length,
      itemBuilder: (context, index) {
        final key = _displayedCounters.keys.elementAt(index);
        final value = _displayedCounters[key]!;

        return Dismissible(
          key: Key(key),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            deleteCounter(key);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$key deleted'),duration: const Duration(milliseconds: 500),),
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.black87,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CounterScreen(counterName: key),
                ),
              );
              await widget.reload(); // Refresh after return
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    key,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$value',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

