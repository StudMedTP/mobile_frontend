import 'dart:convert';

import 'package:http/http.dart' as http;


class HttpHelper {

  final String urlBase = 'https://studmed.aurumtech.site/api-gateway';
  

  Future<Map<String, dynamic>> login(String email, String password, String role) async {
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

  Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password, String userImg) async {
      http.Response response = await http.post(
          Uri.parse('$urlBase/microservice-user/users'), body: {
              "firstName": firstName,
              "lastName": lastName,
              "email": email,
              "password": password,
              "userImg": userImg
          }
      );
      try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          return jsonResponse;
      } catch (e) {
          return { 'status': 'error', 'message': 'Error en la peticion' };
      }
  }




}