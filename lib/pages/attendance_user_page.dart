import 'package:flutter/material.dart';

class AttendanceUserPage extends StatefulWidget {
  const AttendanceUserPage({super.key});

  @override
  State<AttendanceUserPage> createState() => _AttendanceUserPageState();
}

class _AttendanceUserPageState extends State<AttendanceUserPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Control de Asistencia Page"),
    );
  }
}