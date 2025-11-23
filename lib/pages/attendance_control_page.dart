import 'package:flutter/material.dart';

class AttendanceControlPage extends StatefulWidget {
  const AttendanceControlPage({super.key, required this.role});
  final String role;

  @override
  State<AttendanceControlPage> createState() => _AttendanceControlPageState();
}

class _AttendanceControlPageState extends State<AttendanceControlPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("ATTENDANCE CONTROL PAGE - ${widget.role}"),
    );
  }
}