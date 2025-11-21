import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/notification_page.dart';
import 'package:mobile_frontend/pages/profile_page.dart';
import '../pages/home_page.dart';

class MainLayoutTeacher extends StatefulWidget {
  const MainLayoutTeacher({super.key});

  @override
  State<MainLayoutTeacher> createState() => _MainLayoutTeacherState();
}

class _MainLayoutTeacherState extends State<MainLayoutTeacher> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _bottomIndex = 1;   // navbar (1 = Home)
  int _pageIndex = 0;     // página real del stack

  // -----------------------------------------
  // PÁGINAS DE LA APP
  // -----------------------------------------
  final List<Widget> _pages = const [
    HomePage(role: "Teacher"),           // 0
    NotificationPage(role: "Teacher"),   // 2
    ProfilePage(role: "Teacher"),        // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSideBar(),
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
      currentIndex: _bottomIndex,
      onTap: (index) {
        if (index == 0) {
          _scaffoldKey.currentState?.openDrawer();
          return;
        }

        setState(() {
          _bottomIndex = index;
          _pageIndex = index - 1; // 1=Home->0, 2->1, etc.
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }

  // -----------------------------------------
  // DRAWER
  // -----------------------------------------
  Widget _buildSideBar() {
    return Drawer(
      child: Container(
        color: Colors.lightBlue[200],
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            const Text(
              "StudMed",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}


