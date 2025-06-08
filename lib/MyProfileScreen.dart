import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String userName = '';
  Color selectedColor = Colors.teal;
  ImageProvider? profileImage;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getName();
    _nameController.text = userName;
  }

  Future<void> getName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('username');
    if (storedName != null && storedName.isNotEmpty) {
      setState(() {
        userName = storedName;
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _nameController.text);
    setState(() {
      userName = _nameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 0.0),
              child: Column(
                children: [
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Adjust color based on theme
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.black87,
              backgroundImage: profileImage,
              child: profileImage == null
            ? Text(
            userName.isNotEmpty ? userName[0] : "?",
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
                : null,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: TextField(
              controller: _nameController,
              maxLength: 20,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: userName.isNotEmpty ? userName : "?",
                hintStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bottom button and text
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _saveProfile();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile Updated')),
                        );
                      },
                      child: Container(
                        width: 103,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(37),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
