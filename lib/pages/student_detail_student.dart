import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocode/geocode.dart';
import 'package:mobile_frontend/data/models/attendance.dart';
import 'package:mobile_frontend/data/models/classroom_student.dart';
import 'package:mobile_frontend/data/models/grade.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class StudentDetailStudentPage extends StatefulWidget {
  final ClassroomStudent classroomStudent;

  const StudentDetailStudentPage({
    super.key,
    required this.classroomStudent,
  });

  @override
  State<StudentDetailStudentPage> createState() => _StudentDetailStudentPageState();
}

class _StudentDetailStudentPageState extends State<StudentDetailStudentPage>
    with TickerProviderStateMixin {
  late HttpHelper _httpHelper;
  late TabController _tabController;
  bool _isLoading = true;
  bool _attendancesExpanded = true;
  List<Attendance> _attendances = [];
  List<Grade> _grades = [];
  
  // Variables para crear asistencia
  double? _latitude;
  double? _longitude;
  late DateTime _attendanceDateTime;
  String _addressString = 'Cargando ubicación...';
  final TextEditingController _attendanceCodeController = TextEditingController();
  bool _isSubmittingAttendance = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _attendanceCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _httpHelper = HttpHelper();

    await Future.wait([
      _loadAttendances(false),
      _loadGrades(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadAttendances(bool refresh) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
      });
    }
    final response =
        await _httpHelper.getMyAttendancesByClassroom(widget.classroomStudent.classroom!.id);

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
    if (refresh) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGrades() async {
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

  void _showErrorPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAttendanceDialog() {
    _attendanceCodeController.clear();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showLocationErrorPopup();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showLocationErrorPopup();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showLocationErrorPopup();
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _attendanceDateTime = DateTime.now();
      });

      await _getAddressFromCoordinates(pos.latitude, pos.longitude);

      if (!mounted) return;
      _showAttendanceConfirmationPopup();
    } catch (e) {
      if (!mounted) return;
      _showLocationErrorPopup();
    }
  }

  Future<void> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final currentAddress = await GeoCode(
        apiKey: '955629831226981577056x78046',
      ).reverseGeocoding(
        latitude: latitude,
        longitude: longitude,
      );

      setState(() {
        _addressString =
            '${currentAddress.streetAddress}, ${currentAddress.city}, ${currentAddress.countryName}, ${currentAddress.postal}';
      });
    } catch (e) {
      setState(() {
        _addressString = '$latitude, $longitude';
      });
    }
  }

  void _showAttendanceConfirmationPopup() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Registrar Asistencia',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                'Se registrará tu asistencia con los siguientes datos:\n\n'
                'Tu Ubicación: $_addressString\n'
                'Fecha: ${_attendanceDateTime.day}/${_attendanceDateTime.month}/${_attendanceDateTime.year}\n'
                'Hora: ${TimeOfDay.fromDateTime(_attendanceDateTime).format(context)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Código:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _attendanceCodeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Ingrese código para registrar asistencia',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Si no se encuentra en la ubicación correcta, '
                'por favor intente más tarde para evitar un registro erróneo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmittingAttendance
                        ? null
                        : () => _createAttendance(
                          _attendanceCodeController.text,
                          setState,
                        ),
                    child: _isSubmittingAttendance
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Registrar', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAttendance(String code, StateSetter setState) async {
    if (code.isEmpty) {
      _showErrorPopup('Error', 'Por favor ingrese un código válido');
      return;
    }

    setState(() {
      _isSubmittingAttendance = true;
    });

    try {
      final verifyResponse =
          await _httpHelper.verifyTeacherDailyCode(
            widget.classroomStudent.classroom!.teacherId,
            code,
          );

      if (!mounted) {
        setState(() {
          _isSubmittingAttendance = false;
        });
        return;
      }

      if (verifyResponse['status'] == 'error') {
        setState(() {
          _isSubmittingAttendance = false;
        });
        _showErrorPopup('Error', verifyResponse['message'] ?? 'Código inválido');
        return;
      }

      final attendanceResponse =
          await _httpHelper.createAssitance(
            studentId: widget.classroomStudent.student!.id,
            teacherId: widget.classroomStudent.classroom!.teacherId,
            classroomId: widget.classroomStudent.classroom!.id,
            latitude: _latitude!,
            longitude: _longitude!,
          );

      if (!mounted) {
        setState(() {
          _isSubmittingAttendance = false;
        });
        return;
      }

      if (attendanceResponse['status'] == 'error') {
        setState(() {
          _isSubmittingAttendance = false;
        });
        _showErrorPopup('Error', attendanceResponse['message'] ?? 'Error al registrar asistencia');
        return;
      }

      Navigator.pop(context);
      await _loadAttendances(true);
      _showAttendanceSuccessPopup();
      setState(() {
        _isSubmittingAttendance = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingAttendance = false;
        });
        _showErrorPopup('Error', 'Error al registrar asistencia: $e');
      }
    }
  }

  void _showLocationErrorPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Error de Ubicación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'No se ha podido obtener su ubicación. Por favor, '
              'revise las configuraciones de su dispositivo y '
              'asegúrese de que los permisos de ubicación estén habilitados.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendanceSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Asistencia Registrada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Su asistencia ha sido registrada correctamente',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiante'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
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
        onPressed: _showAddAttendanceDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.fact_check),
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
            color: Colors.blue,
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
            _buildInfoRow('Profesor:', '${attendance.teacher.user!.firstName} ${attendance.teacher.user!.lastName}'),
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
                    color: Colors.blue,
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
