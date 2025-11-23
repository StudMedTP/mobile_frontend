import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/student.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';
import 'package:mobile_frontend/pages/student_location_page.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({super.key, required this.onNavegate});

  final void Function(int pageIndex) onNavegate;


  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  late HttpHelper httpHelper;

  late Map<String, dynamic> studentsResponse;  

  List<Student>? classes;
  
  
  bool loading = true;
  
  //Future initialize() async {
  //    studentsResponse = await httpHelper.getAllMyStudents();
  //        if (studentsResponse['status'] == 'error') {
  //            if (!mounted) return;
  //            setState(() {
  //                loading = false;
  //            });
  //            ScaffoldMessenger.of(context).showSnackBar(
  //                SnackBar(
  //                    content: Text(studentsResponse['message']),
  //                    duration: const Duration(seconds: 3)
  //                )
  //            );
  //        } else {
  //            final List classesMap = studentsResponse['classes'];
  //            classes = classesMap.map((classJson) => classes.fromJson(classJson)).toList();
  //            setState(() {
  //                loading = false;
  //            });
  //    }
  //}


  @override
  void initState(){
    super.initState();
  }

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
                  child: const Text(
                    "Lista de Estudiantes",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),


                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("Nombre: ",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),

                      SizedBox(height: 10),

                      Text("Apellido:", 
                        style: TextStyle(fontSize: 18)),

                      SizedBox(height: 10),
                      
                      Align(
                        alignment: Alignment.centerRight ,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.blueAccent,
                            padding:
                              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            _showFirstPopup(context);
                          },
                          child: const Text(
                            "ver datos",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showFirstPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: const Text(
                "Alumno",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

            ),
            const SizedBox(height: 20),

            Text("Nombre: ", style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            Text("Apellido:", style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            Text("Centro Medico:", style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            Text("Hora:", style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            Text("Estado:", style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            // ---------------- Botones ----------------

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text("Regresar", style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //mostrar pantalla nueva
                    widget.onNavegate(5);

                  },
                  child: const Text("Siguiente", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }





}