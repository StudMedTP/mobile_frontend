import 'package:flutter/material.dart';
import 'package:mobile_frontend/layout/main_layout.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
    const Login({super.key, required this.user});
    final String user;

    @override
    State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
    late SharedPreferences _prefs;
    late HttpHelper httpHelper; 
    
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future initialize() async {
        _prefs = await SharedPreferences.getInstance();
    }

    @override
    void initState(){
        httpHelper = HttpHelper();
        initialize();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        bool isAdmin = widget.user == "Administrador";
        final size = MediaQuery.of(context).size;

        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text("Bienvenido ${widget.user}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 20),

                        Image.asset(
                          "images/StudMed.png",   // Usa el nombre de tu imagen
                          width: 150,
                          height: 150,
                          
                        ),

                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),

                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
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
                                    labelText: 'Usuario'
                                )
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        SizedBox(
                            width: size.width * 0.80,
                            child: TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Container()
                        ),
                        ElevatedButton(
                            onPressed: () async {
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Iniciando sesion...'),
                                            duration: Duration(seconds: 10)
                                        )
                                    );
                                }
                                final Map<String, dynamic> response = await httpHelper.login(usernameController.text, passwordController.text, widget.user);
                                if (context.mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    if (response['status'] == 'error') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(response['message']),
                                                duration: const Duration(seconds: 3),
                                            )
                                        );
                                    } else {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => const MainLayout()),
                                            (route) => false
                                        );
                                        print(response);
                                        
                                        await _prefs.setString('token', response['token']);
                                        //await _prefs.setString('role', response['user']['role']);
                                    }
                                }
                            },
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF50B1D8)),
                                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                            ),
                            child: const Text('Ingresar')
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container()
                        ),
                        if (!isAdmin)
                            ElevatedButton(
                                onPressed: () {
                                    //Navigator.push(
                                    //    context,
                                    //    MaterialPageRoute(
                                    //        builder: (context) => const Register()
                                    //    )
                                    //);
                                },
                                style: ButtonStyle(
                                    foregroundColor: WidgetStateProperty.all<Color>(const Color(0xFF50B1D8)),
                                    backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 255, 255, 255))
                                ),
                                child: const Text('Registrarse')
                            )
                    ]
                )
            ),
            //floatingActionButton: FloatingActionButton(
            //    onPressed: () {
            //        Navigator.pop(context);
            //    },
            //    backgroundColor: const Color.fromRGBO(176, 202, 51, 1),
            //    foregroundColor: const Color.fromRGBO(10, 36, 63, 1),
            //    child: const Icon(Icons.arrow_back)
            //)
        );
    }
}
