import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/attendance.dart';
import 'package:mobile_frontend/data/models/medicalCenter.dart';
import 'package:mobile_frontend/data/models/student.dart';
import 'package:mobile_frontend/data/models/user.dart';
import 'package:mobile_frontend/pages/attendance_control_page.dart';
import 'package:mobile_frontend/pages/notification_page.dart';
import 'package:mobile_frontend/pages/profile_page.dart';
import 'package:mobile_frontend/pages/student_location_page.dart';
import 'package:mobile_frontend/pages/students_list_page.dart';
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

  late Attendance attendance;

  // -----------------------------------------
  // PÁGINAS DE LA APP
  // -----------------------------------------

  late final List<Widget> _pages;

  @override
  void initState() {
    attendance = Attendance(id: 0, studentId: 0, medicalCenterId: 0, student: Student(id: 0, studentCode: "", teacherId: 0, user: User(id: 0, firstName: "", lastName: "", email: "", role: "")), medicalcenter: MedicalCenter(id: 0, name: ""), status: '', date: DateTime.now(), latitude: 0.0, longitude: 0.0);
    super.initState();
    _pages = [
      const HomePage(role: "Teacher"),                    // 0
      const NotificationPage(role: "Teacher"),            // 1
      const ProfilePage(role: "Teacher"),                 // 2
      StudentsListPage(onNavegate: _goToPage),            // 3
      const AttendanceControlPage(),                      // 4
    ];
  }

  // Controlador para camnbiar pantallas desde un boton o a otra pagina 
  // desde una pagina del navbar y mantener el navbar y drawer funcionales
  void _goToPage(int index, Attendance newAttendance) {
    setState(() {
      _pageIndex = index;
      attendance = newAttendance;
      _bottomIndex = 1; // navbar se queda en HOME
    });
  }

  //---------------Lista original de paginas----------------
  //
  //final List<Widget> _pages = [
  //  const HomePage(role: "Teacher"),                // 0
  //  const NotificationPage(role: "Teacher"),        // 1
  //  const ProfilePage(role: "Teacher"),             // 2
  //  StudentsListPage(),       // 3
  //  const AttendanceControlPage(role:   "Teacher"), // 4
  //  const StudentLocationPage(),   // 5
  //  
  //];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSideBar(),
      body: IndexedStack(
        index: _pageIndex,
        children: [
          ..._pages,
          StudentLocationPage(attendance: attendance),
        ],
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
            ),

            const SizedBox(height: 40),

            _drawerItem(Icons.checklist, "Lista de Estudiantes", () {
              Navigator.pop(context);
              setState(() {
                _pageIndex = 3;   // Ir a AttendanceUserPage()
                _bottomIndex = 1; // Mantener navbar en HOME
              });
            }),

            const SizedBox(height: 20),

            _drawerItem(Icons.assignment, "Control de Asistencia", () {
              Navigator.pop(context);
              setState(() {
                _pageIndex = 4;   // Ir a PracticePage()
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