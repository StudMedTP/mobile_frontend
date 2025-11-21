import 'package:flutter/material.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final HttpHelper httpHelper = HttpHelper();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/StudMed.png',
              height: 100
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container()
            ),
            const Text(
              'Regístrate', 
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold
              )
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 207, 207, 207)
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        filled: true,
                        fillColor: Color(0xFF50B1D8),
                        prefixIcon: Icon(
                          Icons.person
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30)
                          )
                        ),
                        labelText: 'Nombres'
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 0
                    )
                  ),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        filled: true,
                        fillColor: Color(0xFF50B1D8),
                        prefixIcon: Icon(
                          Icons.person
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30)
                          )
                        ),
                        labelText: 'Apellidos'
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 0
                    )
                  ),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        filled: true,
                        fillColor: Color(0xFF50B1D8),
                        prefixIcon: Icon(
                          Icons.mail
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30)
                          )
                        ),
                        labelText: 'Correo'
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 0
                    )
                  ),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        filled: true,
                        fillColor: Color(0xFF50B1D8),
                        prefixIcon: Icon(
                          Icons.lock
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30)
                          )
                        ),
                        labelText: 'Contraseña'
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 0
                    )
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Creando nuevo usuario...'),
                          )
                        );
                      }
                      final Map<String, dynamic> response = await httpHelper.register(nameController.text, lastNameController.text, emailController.text, passwordController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        if (response['status'] == 'error') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['error']),
                              duration: const Duration(seconds: 3)
                            )
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(30, 161, 210, 1)),
                  foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                ),
                    child: const Text('Guardar usuario')
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}