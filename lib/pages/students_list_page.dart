import 'package:flutter/material.dart';
import 'package:mobile_frontend/data/models/attendance.dart';
import 'package:mobile_frontend/data/models/student.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({super.key, required this.onNavegate});

  final void Function(int pageIndex, Attendance attendance) onNavegate;

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  late HttpHelper httpHelper;

  late Map<String, dynamic> studentsResponse;  

  List<Student>? students;

  bool loading = true;
  
  Future initialize() async {
    httpHelper = HttpHelper();
    studentsResponse = await httpHelper.getAllMyStudents();
    if (studentsResponse['status'] == 'error') {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(studentsResponse['error']),
          duration: const Duration(seconds: 3),
        )
      );
    } else {
      final List studentsMap = studentsResponse['students'];
      students = studentsMap.map((classJson) => Student.fromJson(classJson)).toList();
      setState(() {
          loading = false;
      });
    }
  }

  @override
  void initState(){
    initialize();
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
              children: loading ? [
                Center(
                  child: const CircularProgressIndicator(),
                ),
              ] : [
                Align(
                  alignment: Alignment.center,
                  child: const Text(
                    "Lista de Estudiantes",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 25),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students?.length,
                  itemBuilder: (context, index) {
                      return StudentItem(student: students![index], onNavegate: widget.onNavegate);
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentItem extends StatefulWidget {
  const StudentItem({super.key, required this.student, required this.onNavegate});
  final Student student;
  final void Function(int pageIndex, Attendance attendance) onNavegate;

  @override
  State<StudentItem> createState() => _StudentItemState();
}

class _StudentItemState extends State<StudentItem> {
  late HttpHelper httpHelper;

  late Map<String, dynamic> attendanceResponse;

  Attendance? attendance;

  @override
  void initState(){
    httpHelper = HttpHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              Text(
                "Nombre: ${widget.student.user.firstName}",
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold
                )
              ),

              SizedBox(height: 10),

              Text(
                "Apellido: ${widget.student.user.lastName}", 
                style: TextStyle(fontSize: 18)
              ),

              SizedBox(height: 10),
              
              Align(
                alignment: Alignment.centerRight ,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                  ),
                  onPressed: _getLastAttendance,
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
        const SizedBox(height: 15),
      ],
    );
  }

  Future<void> _getLastAttendance() async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Obteniendo datos...'),
        )
    );
    
    attendanceResponse = await httpHelper.getLastAttendanceByStudentId(widget.student.id);

    print(attendanceResponse);

    if (attendanceResponse['status'] == 'error') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendanceResponse['error']),
          duration: const Duration(seconds: 3),
        )
      );
    } else {
     attendance = Attendance.fromJson(attendanceResponse['attendance']);
      if (!mounted) return;
      _showFirstPopup(context);
    }
  }

  void _showFirstPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          backgroundColor: Colors.lightBlue[200],
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SizedBox(
            width: screenWidth * 0.9,
            child: Column(
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
  
                Text("Nombre: ${widget.student.user.firstName}", style: TextStyle(fontSize: 18)),
  
                SizedBox(height: 10),
  
                Text("Apellido: ${widget.student.user.lastName}", style: TextStyle(fontSize: 18)),
  
                SizedBox(height: 10),
  
                Text("Centro Medico: ${attendance?.medicalcenter.name}", style: TextStyle(fontSize: 18)),
  
                SizedBox(height: 10),
  
                Text("Hora: ${TimeOfDay.fromDateTime(attendance!.date).format(context)}", style: TextStyle(fontSize: 18)),
  
                SizedBox(height: 10),
  
                Text("Estado: ${attendance?.status == 'PENDIENTE' ? 'Pendiente de atención' : attendance?.status == 'FIRMADO' ? 'Firmado' : 'No asistió'}", style: TextStyle(fontSize: 18)),
  
                SizedBox(height: 10),
  
                // ---------------- Botones ----------------
                const SizedBox(height: 20),
  
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Regresar", style: TextStyle(fontSize: 18)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        //mostrar pantalla nueva
                        widget.onNavegate(5, attendance!);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF448AFF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Siguiente", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),    
          ),
        );
      },
    );
  }
}