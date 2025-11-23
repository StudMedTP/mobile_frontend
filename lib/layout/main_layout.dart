import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/attendance_user_page.dart';
import 'package:mobile_frontend/pages/notification_page.dart';
import 'package:mobile_frontend/pages/practice_page.dart';
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

  int _bottomIndex = 1;   // navbar (1 = Home)
  int _pageIndex = 0;     // página real del stack

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(role: "Student"),            // 0
      const LocationPage(),                             // 1
      const NotificationPage(role: "Student"),    // 2
      const ProfilePage(role: "Student"),         // 3
      const AttendanceUserPage(),                 // 4
      const PracticePage()                        // 5
    ];
  }

  //ejemplo en teacher
  //      StudentsListPage(onNavegate: _goToPage),          // 3 
  //
  //Controlador para camnbiar pantallas desde un boton o a otra pagina 
  // desde una pagina del navbar y mantener el navbar y drawer funcionales
  void _goToPage(int index) {
    setState(() {
      _pageIndex = index;
      _bottomIndex = 1; // navbar se queda en HOME
    });
  }

  //---------------Lista original de paginas----------------
  //
  // -----------------------------------------
  //            PÁGINAS DE LA APP
  // -----------------------------------------
  //final List<Widget> _pages = const [
  //  HomePage(role: "Student"),            // 0
  //  LocationPage(),                       // 1
  //  NotificationPage(role: "Student"),    // 2
  //  ProfilePage(role: "Student"),         // 3
  //  AttendanceUserPage(),                 // 4
  //  PracticePage()                        // 5
  //];

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
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Location"),
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
            ),
            
            const SizedBox(height: 40),

            _drawerItem(Icons.checklist, "Control de Asistencia", () {
              Navigator.pop(context);
              setState(() {
                _pageIndex = 4;   // Ir a AttendanceUserPage()
                _bottomIndex = 1; // Mantener navbar en HOME
              });
            }),

            const SizedBox(height: 20),

            _drawerItem(Icons.assignment, "Evaluaciones", () {
              Navigator.pop(context);
              setState(() {
                _pageIndex = 5;   // Ir a PracticePage()
                _bottomIndex = 1; // navbar se queda en HOME
              });
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