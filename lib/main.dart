import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/login.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Pantalla inicial (login)
      home: const Login(user: "Administrador"),

      // Rutas internas
      //routes: {
      //  "/main": (context) => const MainLayout(),     // <--- AQUÍ YA NO VA "child"
      //  "/login": (context) => const Login(user: "Administrador"),
      //},
    );
  }
}
