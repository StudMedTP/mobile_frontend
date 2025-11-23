import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.role});
  final String role;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences _prefs;

  Future initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Profile Page ${widget.role}"),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Start()
                  )
                );
                await _prefs.remove('token');
                await _prefs.remove('role');
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF448AFF)),
                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
              ),
              child: const Text('Cerrar Sesión')
            )
          ]
        ),
      ),
    );
  }
}