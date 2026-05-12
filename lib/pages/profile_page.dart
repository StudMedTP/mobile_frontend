import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/student.dart';
import 'package:mobile_frontend/data/models/teacher.dart';
import 'package:mobile_frontend/data/models/user.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';
import 'package:mobile_frontend/pages/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.role});

  final String role;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryColor = Color(0xFF00897B);
  static const Color secondaryColor = Color(0xFF0A243F);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  late HttpHelper _httpHelper;
  bool _isLoading = true;
  late SharedPreferences _prefs;
  User? _user;
  Teacher? _teacher;
  Student? _student;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    _prefs = await SharedPreferences.getInstance();
    _httpHelper = HttpHelper();

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

    if (widget.role == "Teacher" && _user != null) {
      await _loadTeacherData(_user!.id);
    } else if (widget.role == "Student" && _user != null) {
      await _loadStudentData(_user!.id);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTeacherData(int userId) async {
    final teacherResponse = await _httpHelper.getTeacherByUserId(userId);
    if (teacherResponse['status'] != 'error') {
      _teacher = Teacher.fromJson(teacherResponse['teacher']);
    }
  }

  Future<void> _loadStudentData(int userId) async {
    final studentResponse = await _httpHelper.getStudentByUserId(userId);
    if (studentResponse['status'] != 'error') {
      _student = Student.fromJson(studentResponse['student']);
    }
  }

  Future<void> _handleLogout() async {
    await _prefs.remove('token');
    await _prefs.remove('role');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Start()),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _getInitials(String? firstName, String? lastName) {
    String initials = '';
    if (firstName != null && firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials.isNotEmpty ? initials : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  strokeWidth: 4,
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildProfileAvatar(),
                      const SizedBox(height: 32),
                      _buildUserInfoCard(),
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Mi Perfil',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: secondaryColor,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryColor, Color(0xFF00695C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getInitials(_user?.firstName, _user?.lastName),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_user?.firstName ?? ''} ${_user?.lastName ?? ''}'.trim(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor),
          ),
          child: Text(
            _user?.role ?? 'Usuario',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: secondaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.person_outline,
              'Nombre',
              _user?.firstName ?? '-',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.badge_outlined,
              'Apellido',
              _user?.lastName ?? '-',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.email_outlined,
              'Email',
              _user?.email ?? '-',
            ),
            if (widget.role == "Student") ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.class_outlined,
                'Código de estudiante',
                _student?.studentCode ?? '-',
              ),
            ],
            if (widget.role == "Teacher") ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.school_outlined,
                'Código de profesor',
                _teacher?.teacherCode ?? '-',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5252),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout, size: 20),
          label: const Text(
            'Cerrar Sesión',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}