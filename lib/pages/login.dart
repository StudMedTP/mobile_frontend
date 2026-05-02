import 'package:flutter/material.dart';
import 'package:mobile_frontend/layout/main_layout.dart';
import 'package:mobile_frontend/layout/main_layout_teacher.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static const Color _primaryColor = Color(0xFF50B1D8);
  static const Color _darkColor = Color.fromRGBO(10, 36, 63, 1);
  static const double _inputWidth = 0.80;
  static const double _logoSize = 150.0;

  late HttpHelper _httpHelper;
  bool _isLoading = false;
  late SharedPreferences _prefs;

  // Form controllers
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadPreferences();
  }

  void _initializeControllers() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _httpHelper = HttpHelper();
  }

  Future<void> _handleLogin() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    _showLoadingSnackBar('Iniciando sesión...');

    try {
      final response = await _httpHelper.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();

      if (response['status'] == 'error') {
        _showErrorSnackBar(response['error'] ?? 'Error en la autenticación');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Successful login
      final String token = response['token'] ?? '';
      final String role = response['role'] ?? '';

      if (token.isEmpty || role.isEmpty) {
        _showErrorSnackBar('Respuesta inválida del servidor');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Save credentials
      await _prefs.setString('token', token);
      await _prefs.setString('role', role);

      // Navigate based on role
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => role == 'STUDENT' 
                ? const MainLayout() 
                : const MainLayoutTeacher(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error inesperado: ${e.toString()}');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_emailController.text.isEmpty) {
      _showErrorSnackBar('El email es requerido');
      return false;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showErrorSnackBar('Ingresa un email válido');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('La contraseña es requerida');
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showErrorSnackBar('La contraseña debe tener al menos 6 caracteres');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 30),
      ),
    );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: _buildLoginForm(),
              ),
            ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWelcomeSection(),
        const SizedBox(height: 30),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 30),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const Text(
          'Bienvenido',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Image.asset(
          'assets/StudMed.png',
          width: _logoSize,
          height: _logoSize,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * _inputWidth,
      child: TextField(
        controller: _emailController,
        enabled: !_isLoading,
        keyboardType: TextInputType.emailAddress,
        decoration: _buildInputDecoration(
          label: 'Email',
          icon: Icons.email,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * _inputWidth,
      child: TextField(
        controller: _passwordController,
        enabled: !_isLoading,
        obscureText: true,
        decoration: _buildInputDecoration(
          label: 'Contraseña',
          icon: Icons.lock,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: _primaryColor,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      labelText: label,
      labelStyle: const TextStyle(color: _darkColor),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        disabledBackgroundColor: Colors.grey[400],
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        _isLoading ? 'Iniciando sesión...' : 'Ingresar',
        style: const TextStyle(
          color: _darkColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
