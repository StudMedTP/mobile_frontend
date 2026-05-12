import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/attendance.dart';
import 'package:mobile_frontend/data/models/classroom_student.dart';
import 'package:mobile_frontend/data/models/grade.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class StudentDetailPage extends StatefulWidget {
  final ClassroomStudent classroomStudent;

  const StudentDetailPage({
    super.key,
    required this.classroomStudent,
  });

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage>
    with TickerProviderStateMixin {
  late HttpHelper _httpHelper;
  late TabController _tabController;
  bool _isLoading = true;
  bool _attendancesExpanded = true;
  List<Attendance> _attendances = [];
  List<Grade> _grades = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _httpHelper = HttpHelper();

    await Future.wait([
      _loadAttendances(),
      _loadGrades(false),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadAttendances() async {
    final response =
        await _httpHelper.getAttendancesByStudentAndClassroom(
      widget.classroomStudent.student!.id,
      widget.classroomStudent.classroom!.id,
    );

    if (!mounted) return;

    if (response['status'] == 'error') {
      _showErrorSnackBar(response['message'] ?? 'Error desconocido');
      return;
    }

    try {
      final List attendancesJson = response['attendances'] ?? [];
      _attendances = attendancesJson
          .map((json) => Attendance.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _showErrorSnackBar('Error al procesar asistencias: $e');
      _attendances = [];
    }
  }

  Future<void> _loadGrades(bool refresh) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
      });
    }
    final response =
        await _httpHelper.getGradesByClassroomStudent(
      widget.classroomStudent.id,
    );

    if (!mounted) return;

    if (response['status'] == 'error') {
      _showErrorSnackBar(response['message'] ?? 'Error desconocido');
      return;
    }

    try {
      final List gradesJson = response['grades'] ?? [];
      _grades = gradesJson
          .map((json) => Grade.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _showErrorSnackBar('Error al procesar calificaciones: $e');
      _grades = [];
    }
    if (refresh) {
      setState(() {
        _isLoading = false;
      });
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

  void _showAddGradeDialog() {
    final valueController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Calificación'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calificación',
                  hintText: 'Ej: 90',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Descripción de la calificación',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _createGrade(
              valueController.text,
              descriptionController.text,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _createGrade(String value, String description) async {
    if (value.isEmpty || description.isEmpty) {
      _showErrorSnackBar('Por favor completa todos los campos');
      return;
    }

    try {
      final gradeValue = int.parse(value);

      final response = await _httpHelper.createGrade(
        classroomStudentId: widget.classroomStudent.id,
        value: gradeValue,
        description: description,
      );

      if (!mounted) return;

      if (response['status'] == 'error') {
        _showErrorSnackBar(response['message'] ?? 'Error al crear calificación');
        return;
      }

      Navigator.pop(context);
      await _loadGrades(true);
    } catch (e) {
      _showErrorSnackBar('Error al crear calificación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiante'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        bottom: TabBar(
          labelColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Asistencias'),
            Tab(text: 'Calificaciones'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStudentInfo(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAttendancesTab(),
                      _buildGradesTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGradeDialog,
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStudentInfo() {
    final student = widget.classroomStudent.student;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Código del estudiante:', student!.studentCode),
            const SizedBox(height: 8),
            _buildInfoRow('Nombre:', '${student.user.firstName} ${student.user.lastName}'),
            const SizedBox(height: 8),
            _buildInfoRow('Aula:', widget.classroomStudent.classroom!.name),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildAttendancesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _attendances.isEmpty
          ? _buildEmptyState(
              'No hay asistencias registradas',
              Icons.event_busy,
            )
          : Column(
              children: [
                _buildAttendancesHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: _attendancesExpanded
                      ? _buildAttendancesList()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
    );
  }

  Widget _buildAttendancesHeader() {
    return Material(
      child: InkWell(
        onTap: () {
          setState(() {
            _attendancesExpanded = !_attendancesExpanded;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asistencias (${_attendances.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                _attendancesExpanded
                    ? Icons.expand_less
                    : Icons.expand_more,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendancesList() {
    return ListView.builder(
      itemCount: _attendances.length,
      itemBuilder: (context, index) {
        final attendance = _attendances[index];
        return _buildAttendanceCard(attendance);
      },
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Fecha:', _formatDate(attendance.createdAt)),
            const SizedBox(height: 4),
            _buildInfoRow('Profesor:', attendance.teacher.teacherCode),
            const SizedBox(height: 4),
            _buildInfoRow('Tipo:', attendance.isPartial ? 'Parcial' : 'Completa'),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _grades.isEmpty
          ? _buildEmptyState(
              'No hay calificaciones',
              Icons.grade,
            )
          : _buildGradesList(),
    );
  }

  Widget _buildGradesList() {
    return ListView.builder(
      itemCount: _grades.length,
      itemBuilder: (context, index) {
        final grade = _grades[index];
        return _buildGradeCard(grade);
      },
    );
  }

  Widget _buildGradeCard(Grade grade) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calificación: ${grade.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Descripción:', grade.description),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
