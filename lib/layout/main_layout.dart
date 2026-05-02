import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/clinic_histories.dart';
import 'package:mobile_frontend/pages/profile_page.dart';
import '../pages/location_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _pageIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const LocationPage(),                       // 0
      const ClinicHistoriesPage(),                // 1
      const ProfilePage(role: "Student"),         // 2
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
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Location"),
        BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: "Clinic"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}