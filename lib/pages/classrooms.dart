import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/classroom.dart';
import 'package:mobile_frontend/pages/classroom_students.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class ClassroomsPage extends StatefulWidget {
  const ClassroomsPage({super.key});

  @override
  State<ClassroomsPage> createState() => _ClassroomsPageState();
}

class _ClassroomsPageState extends State<ClassroomsPage> {
  late HttpHelper _httpHelper;
  bool _isLoading = true;
  List<Classroom> _classrooms = [];

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
