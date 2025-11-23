import 'package:flutter/material.dart';

class AttendanceControlPage extends StatefulWidget {
  const AttendanceControlPage({super.key, required this.role});
  final String role;

  @override
  State<AttendanceControlPage> createState() => _AttendanceControlPageState();
}

class _AttendanceControlPageState extends State<AttendanceControlPage> {
  
  final List<String> _alumnos = ['Alumno 1', 'Alumno 2', 'Alumno 3'];
  final List<String> _centros = ['Centro 1', 'Centro 2', 'Centro 3'];

  // Valores seleccionados
  String? _selectedAlumno;
  String? _selectedCentro;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
                    "Control de Asistencia - ${widget.role}",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF448AFF),
                      padding:
                          const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      _showFirstPopup(context);
                    },
                    child: const Text(
                      "+",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
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
                      Center(
                        child: const Text(
                          "Practica de Cardiología",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),

                      SizedBox(height: 10),

                      Text("Nombre:", 
                        style: TextStyle(fontSize: 18)),

                      SizedBox(height: 10),
                      
                      Text("Apellido:", 
                        style: TextStyle(fontSize: 18)),

                      SizedBox(height: 5),
                      
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

  // ---------------------- POPUP 1 -------------------------
  void _showFirstPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.lightBlue[200],

        insetPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 24,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),

        content:StatefulBuilder(
          builder: (context, setStateDialog) {

            final screenWidth = MediaQuery.of(context).size.width;

            return SingleChildScrollView(

              child: SizedBox(
                width:  screenWidth * 0.9,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    Center(
                      child: const Text(
                        "Asignar Nueva Practica",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text( "Alumno",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF448AFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAlumno,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          dropdownColor: const Color(0xFF448AFF),

                          style: const TextStyle(
                            color: Colors.white,   // texto blanco cuando hay valor seleccionado
                            fontSize: 16,
                          ),

                          hint: const Text(
                            "Seleccione un alumno",
                            style: TextStyle(color: Colors.white),
                          ),
                          onChanged: (value) {
                            setStateDialog(() {
                              _selectedAlumno = value;
                            });
                          },
                          items: _alumnos
                              .map(
                                (alumno) => DropdownMenuItem<String>(
                                  value: alumno,
                                  child: Text(alumno),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text( "Centro Medico",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF448AFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCentro,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          dropdownColor: const Color(0xFF448AFF),
                          
                          style: const TextStyle(
                            color: Colors.white,   // texto blanco cuando hay valor seleccionado
                            fontSize: 16,
                          ),
                          
                          hint: const Text(
                            "Seleccione un centro médico",
                            style: TextStyle(color: Colors.white),
                          ),
                          onChanged: (value) {
                            setStateDialog(() {
                              _selectedCentro = value;
                            });
                          },
                          items: _centros
                              .map(
                                (centro) => DropdownMenuItem<String>(
                                  value: centro,
                                  child: Text(centro),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text( "Fecha",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () async {
                        final today = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? today,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF448AFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          _selectedDate != null
                              ? "${_selectedDate!.day.toString().padLeft(2, '0')}/"
                                "${_selectedDate!.month.toString().padLeft(2, '0')}/"
                                "${_selectedDate!.year}"
                              : "Seleccionar fecha",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text( "Hora",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              _selectedTime ?? TimeOfDay.fromDateTime(DateTime.now()),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF448AFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : "Seleccionar hora",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 25),            

                    // ---------------- Botones ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              const Text("Regresar", style: TextStyle(fontSize: 18)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSecondPopup(context);
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
              "Asignar Practica",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "La practica ha sido asginada correctamente",
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
}