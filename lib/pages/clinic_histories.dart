import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/clinic_history.dart';
import 'package:mobile_frontend/data/models/student.dart';
import 'package:mobile_frontend/data/models/user.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class ClinicHistoriesPage extends StatefulWidget {
  const ClinicHistoriesPage({super.key});

  @override
  State<ClinicHistoriesPage> createState() => _ClinicHistoriesPageState();
}

class _ClinicHistoriesPageState extends State<ClinicHistoriesPage> {
  late HttpHelper _httpHelper;
  bool _isLoading = true;
  List<ClinicHistory> _clinicHistories = [];
  Student? _student;
  User? _user;

  // Form controllers
  late TextEditingController _medicalHistoryNumberController;
  late TextEditingController _ageController;
  late TextEditingController _sexController;
  late TextEditingController _mainDiagnosisController;
  late TextEditingController _treatmentController;
  late TextEditingController _analysisController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadClinicHistories();
  }

  void _initializeControllers() {
    _medicalHistoryNumberController = TextEditingController();
    _ageController = TextEditingController();
    _sexController = TextEditingController();
    _mainDiagnosisController = TextEditingController();
    _treatmentController = TextEditingController();
    _analysisController = TextEditingController();
  }

  Future<void> _loadClinicHistories() async {
    setState(() {
      _isLoading = true;
    });

    _httpHelper = HttpHelper();

    final response = await _httpHelper.getClinicHistories();

    if (!mounted) return;

    if (response['status'] == 'error') {
      _showErrorSnackBar(response['message'] ?? 'Error desconocido');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final List historiesJson = response['clinic-histories'] ?? [];
      _clinicHistories = historiesJson
          .map((json) => ClinicHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _showErrorSnackBar('Error al procesar datos: $e');
      _clinicHistories = [];
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

    await _loadStudentData(_user!.id);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadStudentData(int userId) async {
    final studentResponse = await _httpHelper.getStudentByUserId(userId);
    if (studentResponse['status'] != 'error') {
      _student = Student.fromJson(studentResponse['student']);
    }
  }

  Future<void> _createClinicHistory() async {
    if (!_validateForm()) return;

    try {
      final int age = int.parse(_ageController.text);

      final response = await _httpHelper.createClinicHistory(
        medicalHistoryNumber: _medicalHistoryNumberController.text.trim(),
        age: age,
        sex: _sexController.text.trim(),
        mainDiagnosis: _mainDiagnosisController.text.trim(),
        treatment: _treatmentController.text.trim(),
        analysis: _analysisController.text.trim(),
        studentId: _student?.id ?? 0,
      );

      if (!mounted) return;

      if (response['status'] == 'error') {
        _showErrorSnackBar(response['message'] ?? 'Error al crear historial');
        return;
      }

      _showSuccessSnackBar('Historial clínico creado exitosamente');
      Navigator.pop(context);
      _clearFormControllers();
      await _loadClinicHistories();
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  bool _validateForm() {
    if (_medicalHistoryNumberController.text.isEmpty) {
      _showErrorSnackBar('El número de historial médico es requerido');
      return false;
    }
    if (_ageController.text.isEmpty) {
      _showErrorSnackBar('La edad es requerida');
      return false;
    }
    if (int.tryParse(_ageController.text) == null) {
      _showErrorSnackBar('La edad debe ser un número válido');
      return false;
    }
    if (_sexController.text.isEmpty) {
      _showErrorSnackBar('El sexo es requerido');
      return false;
    }
    if (_mainDiagnosisController.text.isEmpty) {
      _showErrorSnackBar('El diagnóstico principal es requerido');
      return false;
    }
    if (_treatmentController.text.isEmpty) {
      _showErrorSnackBar('El tratamiento es requerido');
      return false;
    }
    if (_analysisController.text.isEmpty) {
      _showErrorSnackBar('El análisis es requerido');
      return false;
    }
    return true;
  }

  void _clearFormControllers() {
    _medicalHistoryNumberController.clear();
    _ageController.clear();
    _sexController.clear();
    _mainDiagnosisController.clear();
    _treatmentController.clear();
    _analysisController.clear();
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAddClinicHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF00897B),
        insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Nuevo Historial Clínico',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFormField('Número de Historial Médico', _medicalHistoryNumberController),
                    const SizedBox(height: 15),
                    _buildFormField('Edad', _ageController, keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildFormField('Sexo', _sexController, hintText: 'Ej: M, F'),
                    const SizedBox(height: 15),
                    _buildFormField('Diagnóstico Principal', _mainDiagnosisController, maxLines: 2),
                    const SizedBox(height: 15),
                    _buildFormField('Tratamiento', _treatmentController, maxLines: 2),
                    const SizedBox(height: 15),
                    _buildFormField('Análisis', _analysisController, maxLines: 2),
                    const SizedBox(height: 25),
                    _buildFormActions(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String hintText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: maxLines == 1 ? 1 : null,
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Regresar',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        ElevatedButton(
          onPressed: _createClinicHistory,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00897B),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Guardar',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
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
                      child: _clinicHistories.isEmpty
                          ? _buildEmptyState()
                          : _buildClinicHistoriesList(),
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
          'Historias Clínicas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: _showAddClinicHistoryDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00897B),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            '+',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_present_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay historias clínicas',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para crear una',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicHistoriesList() {
    return ListView.builder(
      itemCount: _clinicHistories.length,
      itemBuilder: (context, index) {
        final history = _clinicHistories[index];
        return _buildClinicHistoryCard(history);
      },
    );
  }

  Widget _buildClinicHistoryCard(ClinicHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardRow('Historial:', history.medicalHistoryNumber),
            const SizedBox(height: 8),
            _buildCardRow('Edad:', '${history.age} años'),
            const SizedBox(height: 8),
            _buildCardRow('Sexo:', history.sex),
            const SizedBox(height: 12),
            _buildCardSection('Diagnóstico:', history.mainDiagnosis),
            const SizedBox(height: 12),
            _buildCardSection('Tratamiento:', history.treatment),
            const SizedBox(height: 12),
            _buildCardSection('Análisis:', history.analysis),
          ],
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

  Widget _buildCardSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _medicalHistoryNumberController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _mainDiagnosisController.dispose();
    _treatmentController.dispose();
    _analysisController.dispose();
    super.dispose();
  }
}
