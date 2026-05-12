import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpHelper {

  final String urlBase = 'https://studmed.aurumtech.site/api-gateway';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Map<String, dynamic>> login(String email, String password) async {
      http.Response response = await http.post(
          Uri.parse('$urlBase/microservice-user/users/login'),
          headers: {
              'Content-Type': 'application/json',
          },
          body: json.encode({
              "email": email,
              "password": password,
          })
      );
      try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          return jsonResponse;
      } catch (e) {
          return { 'status': 'error', 'message': 'Error en la peticion' };
      }
  }

  Future <Map<String, dynamic>> getAllMyAttendances() async {
    final pref = await _prefs; 
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-attendance/attendances/myObject/classroom/1'),
        headers: {'Authorization': '${pref.getString('token')}'},
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future <Map<String, dynamic>> verifyTeacherDailyCode(int teacherId, String dailyCode) async {
    try {
      http.Response response = await http.get(
          Uri.parse('$urlBase/microservice-user/teachers/verifyDailyCode/$teacherId/$dailyCode')
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['error'] ?? 'Error al obtener estudiantes del aula'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateAttendance(int id) async {
    http.Response response = await http.put(
        Uri.parse('$urlBase/microservice-attendance/attendances/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "status": "FIRMADO"
        })
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future <Map<String, dynamic>> recordAttendance(int attendanceId, int teacherId, int studentId, double latitud, double longitud) async {
    http.Response response = await http.post(
        Uri.parse('$urlBase/microservice-attendance/blockchains/$attendanceId/$teacherId/$studentId/$latitud/$longitud')
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future <Map<String, dynamic>> getAllMyStudents() async {
    final pref = await _prefs; 
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-user/students/teacher/myObject'),
        headers: {'Authorization': '${pref.getString('token')}'},
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future <Map<String, dynamic>> getAllMedicalCenters() async {
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-user/medical-centers')
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future<Map<String, dynamic>> createAssitance({
    required int studentId,
    required int teacherId,
    required int classroomId,
    required double latitude,
    required double longitude,
    required bool isPartial
  }) async {
    try {
      http.Response response = await http.post(
          Uri.parse('$urlBase/microservice-attendance/attendances'),
          headers: {
              'Content-Type': 'application/json',
          },
          body: json.encode({
              "studentId": studentId,
              "teacherId": teacherId,
              "classroomId": classroomId,
              "latitude": latitude,
              "longitude": longitude,
              "isPartial": isPartial
          })
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['error'] ?? 'Error al crear historial clínico'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future <Map<String, dynamic>> getLastAttendanceByStudentId(int studentId) async {
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-attendance/attendances/lastByStudentId/$studentId')
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future <Map<String, dynamic>> getUser() async {
    final pref = await _prefs;

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': '${pref.getString('token')}'
    };

    http.Response response = await http.get(
      Uri.parse('$urlBase/microservice-user/users/myObject'), 
      headers: requestHeaders
    );

    try {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    } catch (e) {
      return { 'status': 'error', 'message': 'Error en la peticion' };
    }

  }

  Future <Map<String, dynamic>> openClass(int teacherId) async {
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-user/teachers/openClass/$teacherId')
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future <Map<String, dynamic>> closeClass(int teacherId) async {
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-user/teachers/closeClass/$teacherId')
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future <Map<String, dynamic>> getTeacherByUserId(int userId) async {
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-user/teachers/user/$userId')
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future <Map<String, dynamic>> getStudentByUserId(int userId) async {
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-user/students/user/$userId')
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
    }
  }

  Future<Map<String, dynamic>> getClinicHistories() async {
    final pref = await _prefs;
    final token = pref.getString('token');
    
    if (token == null || token.isEmpty) {
      return {'status': 'error', 'message': 'Token no disponible'};
    }

    try {
      http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-evaluation/clinic-histories/myObject'),
        headers: {'Authorization': token},
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al obtener historias clínicas'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getClassrooms() async {
    final pref = await _prefs;
    final token = pref.getString('token');
    
    if (token == null || token.isEmpty) {
      return {'status': 'error', 'message': 'Token no disponible'};
    }

    try {
      http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-evaluation/classrooms/myObject'),
        headers: {'Authorization': token},
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al obtener aulas'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getClassroomStudents() async {
    final pref = await _prefs;
    final token = pref.getString('token');
    
    if (token == null || token.isEmpty) {
      return {'status': 'error', 'message': 'Token no disponible'};
    }

    try {
      http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-evaluation/classroom-students/myObject'),
        headers: {'Authorization': token},
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al obtener estudiantes del aula'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getClassroomStudentsByClassroomId(int classroomId) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-evaluation/classroom-students/classroom/$classroomId'),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al obtener estudiantes del aula'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createClinicHistory({
    required String medicalHistoryNumber,
    required int age,
    required String sex,
    required String mainDiagnosis,
    required String treatment,
    required String analysis,
    required int studentId,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$urlBase/microservice-evaluation/clinic-histories'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'medicalHistoryNumber': medicalHistoryNumber,
          'age': age,
          'sex': sex,
          'mainDiagnosis': mainDiagnosis,
          'treatment': treatment,
          'analysis': analysis,
          'studentId': studentId,
        }),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al crear historial clínico'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getAttendancesByStudentAndClassroom(
    int studentId,
    int classroomId,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          '$urlBase/microservice-attendance/attendances/student/$studentId/classroom/$classroomId',
        ),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al obtener asistencias'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getMyAttendancesByClassroom(int classroomId) async {
    final pref = await _prefs;
    final token = pref.getString('token');
    
    if (token == null || token.isEmpty) {
      return {'status': 'error', 'message': 'Token no disponible'};
    }

    try {
      http.Response response = await http.get(
        Uri.parse(
          '$urlBase/microservice-attendance/attendances/myObject/classroom/$classroomId',
        ),
        headers: {'Authorization': token},
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al obtener asistencias'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getGradesByClassroomStudent(int classroomStudentId) async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          '$urlBase/microservice-evaluation/grades/classroom-student/$classroomStudentId',
        ),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al obtener calificaciones'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createGrade({
    required int classroomStudentId,
    required int value,
    required String description,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$urlBase/microservice-evaluation/grades'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'value': value,
          'description': description,
          'classroomStudentId': classroomStudentId,
        }),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        return {
          'status': 'error',
          'message': jsonResponse['message'] ?? 'Error al crear calificación'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error en la petición: ${e.toString()}'};
    }
  }
}