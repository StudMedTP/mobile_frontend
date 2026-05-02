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
  static const Color primaryColor = Color(0xFF448AFF);
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
        _teacher?.dailyCode = response['dailyCode'];
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
        _teacher?.dailyCode = response['dailyCode'];
      });

      _showSuccessSnackBar('¡Clase cerrada!');
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
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
                      if (widget.role == "Teacher") ...[
                        _buildTeacherSection(),
                        const SizedBox(height: 24),
                      ],
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
              colors: [primaryColor, Color(0xFF1976D2)],
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

  Widget _buildTeacherSection() {
    if (_teacher == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                  color: secondaryColor,
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