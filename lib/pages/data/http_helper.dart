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

  Future <Map<String, dynamic>> register(String firstName, String lastName, String email, String password) async {
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

  Future <Map<String, dynamic>> getStudents() async {
    http.Response response = await http.get(
        Uri.parse('$urlBase/microservice-user/users'),
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


}