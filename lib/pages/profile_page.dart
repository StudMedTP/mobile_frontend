import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/user.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';
import 'package:mobile_frontend/pages/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.role});

  final String role;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool loading = true;
  late SharedPreferences _prefs;

  final HttpHelper httpHelper = HttpHelper();
  
  late Map<String, dynamic> userResponse;

  User? user;

  Future initialize() async {

    _prefs = await SharedPreferences.getInstance();

    userResponse = await httpHelper.getUser();

    print(userResponse);
    if (userResponse['status'] == 'error') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userResponse['message']),
          duration: const Duration(seconds: 3)
        )
      );
    } else {
      user = User.fromJson(userResponse['user']);
    }
    
    setState(() {
      loading = false;
    });

    
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  //@override
  //Widget build(BuildContext context) {
  //  return Scaffold(
  //    body: Center(
  //      child: Column(
  //        mainAxisAlignment: MainAxisAlignment.center,
  //        children: [
  //          Text("Profile Page ${widget.role}"),
//
//
  //          ElevatedButton(
  //            onPressed: () async {
  //              Navigator.pushReplacement(
  //                context,
  //                MaterialPageRoute(
  //                  builder: (context) => const Start()
  //                )
  //              );
  //              await _prefs.remove('token');
  //              await _prefs.remove('role');
  //            },
  //            style: ButtonStyle(
  //              backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF448AFF)),
  //              foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
  //            ),
  //            child: const Text('Cerrar Sesión')
  //          )
//
//
  //          
  //        ]
  //      ),
  //    ),
  //  );
  //}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Profile Page ${widget.role}",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                                
                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Start()
                      )
                    );
                    await _prefs.remove('token');
                    await _prefs.remove('role');
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF448AFF)),
                    foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(10, 36, 63, 1))
                  ),
                  child: const Text('Cerrar Sesión')
                )

              ],
            ),
          ),
        ),
      ),
    );
  }


}