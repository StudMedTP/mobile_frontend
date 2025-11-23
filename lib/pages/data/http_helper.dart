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

  Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password) async {
      http.Response response = await http.post(
          Uri.parse('$urlBase/microservice-user/users'),
          headers: {
              'Content-Type': 'application/json',
          },
          body: json.encode({
              "firstName": firstName,
              "lastName": lastName,
              "email": email,
              "password": password
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
        Uri.parse('$urlBase/microservice-attendance/attendances/myObject'),
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
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-user/teachers/verifyDailyCode/$teacherId/$dailyCode')
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
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

  Future <Map<String, dynamic>> recordAttendance(int teacherId, int studentId, double latitud, double longitud) async {
    http.Response response = await http.post(
        Uri.parse('$urlBase/microservice-attendance/blockchains/$teacherId/$studentId/$latitud/$longitud')
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

  Future<Map<String, dynamic>> createAssitance(int studentId, int medicalCenterId, DateTime date) async {
    http.Response response = await http.post(
        Uri.parse('$urlBase/microservice-attendance/attendances'),
        headers: {
            'Content-Type': 'application/json',
        },
        body: json.encode({
            "studentId": studentId,
            "medicalCenterId": medicalCenterId,
            "date": date.toIso8601String(),
        })
    );
    try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
    } catch (e) {
        return { 'status': 'error', 'message': 'Error en la peticion' };
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
}