import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/classroom.dart';
import 'package:mobile_frontend/data/models/classroom_student.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class ClassroomStudentsPage extends StatefulWidget {
  final Classroom classroom;

  const ClassroomStudentsPage({
    super.key,
    required this.classroom,
  });

  @override
  State<ClassroomStudentsPage> createState() => _ClassroomStudentsPageState();
}

class _ClassroomStudentsPageState extends State<ClassroomStudentsPage> {
  late HttpHelper _httpHelper;
  bool _isLoading = true;
  List<ClassroomStudent> _classroomStudents = [];

  @override
  void initState() {
    super.initState();
    _loadClassroomStudents();
  }

  Future<void> _loadClassroomStudents() async {
    setState(() {
      _isLoading = true;
    });

    _httpHelper = HttpHelper();

    final response = await _httpHelper.getClassroomStudentsByClassroomId(widget.classroom.id);

    if (!mounted) return;

    if (response['status'] == 'error') {
      _showErrorSnackBar(response['message'] ?? 'Error desconocido');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final List classroomStudentsJson = response['classrooms-students'] ?? [];
      _classroomStudents = classroomStudentsJson
          .map((json) => ClassroomStudent.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _showErrorSnackBar('Error al procesar datos: $e');
      _classroomStudents = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes - ${widget.classroom.name}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _classroomStudents.isEmpty
                          ? _buildEmptyState()
                          : _buildStudentsList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Estudiantes (${_classroomStudents.length})',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay estudiantes en esta aula',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return ListView.builder(
      itemCount: _classroomStudents.length,
      itemBuilder: (context, index) {
        final classroomStudent = _classroomStudents[index];
        return _buildStudentCard(classroomStudent);
      },
    );
  }

  Widget _buildStudentCard(ClassroomStudent classroomStudent) {
    final student = classroomStudent.student;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetailPage(classroomStudent: classroomStudent),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardRow('Código:', student!.studentCode),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
