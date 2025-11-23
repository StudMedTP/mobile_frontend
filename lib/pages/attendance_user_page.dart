import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_frontend/data/models/attendance.dart';
import 'package:mobile_frontend/pages/data/http_helper.dart';

class AttendanceUserPage extends StatefulWidget {
  const AttendanceUserPage({super.key});

  @override
  State<AttendanceUserPage> createState() => _AttendanceUserPageState();
}

class _AttendanceUserPageState extends State<AttendanceUserPage> {
  late HttpHelper httpHelper;

  late Map<String, dynamic> attendancesResponse;

  List<Attendance>? attendances;

  bool loading = true;

  Future initialize() async {
    httpHelper = HttpHelper();
    attendancesResponse = await httpHelper.getAllMyAttendances();
    if (attendancesResponse['status'] == 'error') {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendancesResponse['error']),
          duration: const Duration(seconds: 3),
        )
      );
    } else {
      final List attendancesMap = attendancesResponse['attendances'];
      attendances = attendancesMap.map((classJson) => Attendance.fromJson(classJson)).toList();
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
                const Text(
                  "Control de asistencia",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    _refreshAttendances();
                  },
                  child: const Text(
                    "Refrescar asistencias",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 25),

                // Caja azul con información
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attendances?.length,
                  itemBuilder: (context, index) {
                      return AttendanceItem(attendance: attendances![index], onAttendanceFirmado: ()  => _refreshAttendances());
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _refreshAttendances() async {
    setState(() {
      loading = true;
    });
    attendancesResponse = await httpHelper.getAllMyAttendances();
    if (attendancesResponse['status'] == 'error') {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendancesResponse['error']),
          duration: const Duration(seconds: 3),
        )
      );
    } else {
      final List attendancesMap = attendancesResponse['attendances'];
      attendances = attendancesMap.map((classJson) => Attendance.fromJson(classJson)).toList();
      setState(() {
        loading = false;
      });
    }
  }
}

class AttendanceItem extends StatefulWidget {
  const AttendanceItem({super.key, required this.attendance, required this.onAttendanceFirmado});
  final Attendance attendance;
  final Function() onAttendanceFirmado;

  @override
  State<AttendanceItem> createState() => _AttendanceItemState();
}

class _AttendanceItemState extends State<AttendanceItem> {
  late HttpHelper httpHelper;

  final TextEditingController _codigoController = TextEditingController();

  double? _latitude;
  double? _longitude;

  @override
  void initState(){
    httpHelper = HttpHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
                widget.attendance.medicalcenter.name,
                style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 10),
              const Text("Fecha: 20/11/2025", style: TextStyle(fontSize: 18)),
              const Text("Hora: 08:00 am", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                "Estado: ${widget.attendance.status == 'PENDIENTE' ? 'Pendiente de atención' : widget.attendance.status == 'FIRMADO' ? 'Firmado' : 'No asistió'}",
                style: const TextStyle(fontSize: 18)
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // Botón principal
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: _getLocation,
          child: const Text(
            "Firmar asistencia",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        )
      ]
    );
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showLocationErrorPopup(context);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showLocationErrorPopup(context);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showLocationErrorPopup(context);
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
      if (!mounted) return;
      _showFirstPopup(context);
    } catch (e) {
      if (!mounted) return;
      _showLocationErrorPopup(context);
    }
  }

  // ---------------------- POPUP 1 -------------------------
  void _showFirstPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Firmar Asistencia",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),
            
            const Text(
              "Se registrará tu asistencia con los siguientes datos:\n\n"
              "Tu Ubicación: Av. Edgardo Rebagliati 490, Jesús María 15072\n"
              "Fecha: 20/11/2025\n"
              "Hora: 7:58 am",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // ---------------- Ingresar Codigo Diario ----------------
            Align(
              alignment: Alignment.center,
              child: Text(
                "Código:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
  
            const SizedBox(height: 5),
  
            TextField(
              controller: _codigoController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Ingrese código para firmar su asistencia",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,                  
                ),      
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Si no se encuentra en la ubicación de su práctica, "
              "por favor intente más tarde cuando se encuentre en su ubicación para evitar una asistencia errónea.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            // ---------------- Botones ----------------
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Regresar", style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_codigoController.text == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor ingrese un código válido'),
                          duration: Duration(seconds: 3),
                        )
                      );
                      return;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verificando código...'),
                          duration: Duration(minutes: 1),
                        )
                      );
                      final Map<String, dynamic> response = await httpHelper.verifyTeacherDailyCode(widget.attendance.student.teacherId, _codigoController.text);
                      if (context.mounted) {
                        if (response['status'] == 'error') {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['error']),
                              duration: const Duration(seconds: 3),
                            )
                          );
                        } else {
                          final Map<String, dynamic> response = await httpHelper.updateAttendance(widget.attendance.id);
                          if (context.mounted) {
                            if (response['status'] == 'error') {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['error']),
                                  duration: const Duration(seconds: 3),
                                )
                              );
                            } else {
                              final Map<String, dynamic> response = await httpHelper.recordAttendance(widget.attendance.student.teacherId, widget.attendance.studentId, _latitude!, _longitude!);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                if (response['status'] == 'error') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['error']),
                                      duration: const Duration(seconds: 3),
                                    )
                                  );
                                } else {
                                  widget.onAttendanceFirmado();
                                  Navigator.pop(context);
                                  _showSecondPopup(context);
                                }
                              }
                            }
                          }
                        }
                      }
                    }
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

  // ---------------------- POPUP 2 -------------------------
  void _showSecondPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Firmar Asistencia",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Su asistencia ha sido registrada correctamente",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar", style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------- POPUP 3 -------------------------
  void _showLocationErrorPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Error de Ubicación",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "No se ha podido obtener su ubicación. Por favor, revise las configuraciones de su dispositivo y asegúrese de que los permisos de ubicación estén habilitados.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}