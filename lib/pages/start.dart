import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/login.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {

  Color _backgroundColor = Colors.white;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/StudMed.png',
              height: 100
            ),
            Padding(
              padding: const EdgeInsets.all(64.0),
              child: Container()
            ),
            const Text(
              'Bienvenid@', 
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold
              )
            ),
            Padding(
              padding: const EdgeInsets.all(64.0),
              child: Container()
            ),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login()
                    )
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(30, 161, 210, 1)),
                  foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                ),
                child: const Text('Iniciar Sesión')
              )
            )
          ]
        )
      )
    );
  }
}