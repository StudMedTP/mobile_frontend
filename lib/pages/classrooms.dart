import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/classroom.dart';
import 'package:mobile_frontend/data/models/teacher.dart';
import 'package:mobile_frontend/data/models/user.dart';
import 'package:mobile_frontend/pages/classroom_students.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class ClassroomsPage extends StatefulWidget {
  const ClassroomsPage({super.key});

  @override
  State<ClassroomsPage> createState() => _ClassroomsPageState();
}

class _ClassroomsPageState extends State<ClassroomsPage> {
  static const Color primaryColor = Color(0xFF448AFF);
  static const Color accentColor = Color(0xFFFFC107);

  late HttpHelper _httpHelper;
  bool _isLoading = true;
  List<Classroom> _classrooms = [];
  User? _user;
  Teacher? _teacher;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    setState(() {
      _isLoading = true;
    });

    _httpHelper = HttpHelper();

    final response = await _httpHelper.getClassrooms();

    if (!mounted) return;

    if (response['status'] == 'error') {
      _showErrorSnackBar(response['message'] ?? 'Error desconocido');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final List classroomsJson = response['classrooms'] ?? [];
      _classrooms = classroomsJson
          .map((json) => Classroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _showErrorSnackBar('Error al procesar datos: $e');
      _classrooms = [];
    }

    final userResponse = await _httpHelper.getUser();

    if (!mounted) return;

    if (userResponse['status'] == 'error') {
      _showErrorSnackBar(userResponse['message'] ?? 'Error al cargar perfil');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _user = User.fromJson(userResponse['user']);
    _userRole = _user?.role;

    if (_userRole == "TEACHER" && _user != null) {
      await _loadTeacherData(_user!.id);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadTeacherData(int userId) async {
    final teacherResponse = await _httpHelper.getTeacherByUserId(userId);
    if (teacherResponse['status'] != 'error') {
      _teacher = Teacher.fromJson(teacherResponse['teacher']);
    }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  Future<void> _openClass() async {
    if (_teacher == null) return;

    _showLoadingSnackBar('Abriendo clase...');

    try {
      final response = await _httpHelper.openClass(_teacher!.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      if (response['status'] == 'error') {
        _showErrorSnackBar(response['error'] ?? 'Error al abrir clase');
        return;
      }

      setState(() {
        _teacher = Teacher.fromJson(response);
      });

      _showSuccessSnackBar('¡Clase abierta!');
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _closeClass() async {
    if (_teacher == null) return;

    _showLoadingSnackBar('Cerrando clase...');

    try {
      final response = await _httpHelper.closeClass(_teacher!.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      if (response['status'] == 'error') {
        _showErrorSnackBar(response['error'] ?? 'Error al cerrar clase');
        return;
      }

      setState(() {
        _teacher = Teacher.fromJson(response);
      });

      _showSuccessSnackBar('¡Clase cerrada!');
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    if (_userRole == "TEACHER") ...[
                      _buildTeacherSection(),
                      const SizedBox(height: 20),
                    ],
                    Expanded(
                      child: _classrooms.isEmpty
                          ? _buildEmptyState()
                          : _buildClassroomsList(),
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
        const Text(
          'Aulas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTeacherSection() {
    if (_teacher == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor, width: 1.5),
      ),
      child: Column(
        children: [
          _buildTeacherHeader(),
          const SizedBox(height: 16),
          _buildDailyCodeDisplay(),
          const SizedBox(height: 16),
          _buildTeacherActions(),
        ],
      ),
    );
  }

  Widget _buildTeacherHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.vpn_key, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Código de Clase',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Abre o cierra tu clase diaria',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A243F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyCodeDisplay() {
    if (_teacher?.dailyCode == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor, width: 2),
      ),
      child: Text(
        _teacher!.dailyCode!,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: accentColor,
          letterSpacing: 2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTeacherActions() {
    return Row(
      children: [
        Expanded(
          child: _buildTeacherButton(
            onPressed: _openClass,
            label: 'Abrir',
            icon: Icons.play_arrow,
            backgroundColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTeacherButton(
            onPressed: _closeClass,
            label: 'Cerrar',
            icon: Icons.stop_circle,
            backgroundColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.room, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay aulas disponibles',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomsList() {
    return ListView.builder(
      itemCount: _classrooms.length,
      itemBuilder: (context, index) {
        final classroom = _classrooms[index];
        return _buildClassroomCard(classroom);
      },
    );
  }

  Widget _buildClassroomCard(Classroom classroom) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassroomStudentsPage(classroom: classroom),
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
              _buildCardRow('Aula:', classroom.name),
              const SizedBox(height: 8),
              _buildCardRow('Centro Médico:', '${classroom.medicalCenter?.name}'),
            ],
          ),
        ),
      ),
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
