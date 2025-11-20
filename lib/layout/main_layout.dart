import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/attendance_user_page.dart';
import 'package:mobile_frontend/pages/notification_page.dart';
import 'package:mobile_frontend/pages/profile_page.dart';
import '../pages/home_page.dart';
import '../pages/location_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0; 
  // Empezamos en HOME (que estará en el index 1)

  // --------------------------
  // PÁGINAS DE LA APP
  // --------------------------
  final List<Widget> _pages = const [
    HomePage(),         // index 0
    LocationPage(),     // index 1
    NotificationPage(), // index 2
    ProfilePage(),      // index 3
    AttendanceUserPage(), // index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSideBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildNavbar(),
    );
  }

  // --------------------------
  // NAVBAR INFERIOR
  // --------------------------
  Widget _buildNavbar() {
    return BottomNavigationBar(
      backgroundColor: Colors.lightBlue[200],
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 0) {
          _scaffoldKey.currentState?.openDrawer();
          return;
        }

        setState(() {
          _currentIndex = index - 1; 
          // Como agregamos el menú al inicio, restamos 1
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Location"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }

  // --------------------------
  // SIDEBAR (DRAWER)
  // --------------------------
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
            ),
            const SizedBox(height: 40),

            _drawerItem(Icons.checklist, "Control de Asistencia", () {
              Navigator.pop(context);
              setState(() => _currentIndex = 4);
            }),

            const SizedBox(height: 20),

            _drawerItem(Icons.assignment, "Evaluaciones", () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}

