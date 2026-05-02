import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/classrooms.dart';
import 'package:mobile_frontend/pages/profile_page.dart';

class MainLayoutTeacher extends StatefulWidget {
  const MainLayoutTeacher({super.key});

  @override
  State<MainLayoutTeacher> createState() => _MainLayoutTeacherState();
}

class _MainLayoutTeacherState extends State<MainLayoutTeacher> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _pageIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ClassroomsPage(),
      const ProfilePage(role: "Teacher"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildNavbar(),
    );
  }

  // -----------------------------------------
  // NAVBAR
  // -----------------------------------------
  Widget _buildNavbar() {
    return BottomNavigationBar(
      backgroundColor: Colors.lightBlue[200],
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        setState(() {
          _pageIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.room), label: "Aulas"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}