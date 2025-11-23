import 'package:flutter/material.dart';
import 'package:mobile_frontend/layout/main_layout.dart';
import 'package:mobile_frontend/layout/main_layout_teacher.dart';
import 'package:mobile_frontend/pages/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          final SharedPreferences prefs = snapshot.data!;
          String? authToken = prefs.getString('token');
          String? role = prefs.getString('role');

          Widget initialScreen = authToken != null ? role == 'TEACHER' ? const MainLayoutTeacher() : const MainLayout() : const Start();

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: initialScreen
          );
        }
      }
    );
  }
}