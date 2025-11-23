import 'package:flutter/material.dart';

class AttendanceUserPage extends StatefulWidget {
  const AttendanceUserPage({super.key});

  @override
  State<AttendanceUserPage> createState() => _AttendanceUserPageState();
}

class _AttendanceUserPageState extends State<AttendanceUserPage> {

  final TextEditingController _codigoController = TextEditingController();


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
                const Text(
                  "Control de asistencia",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),

                // Caja azul con información
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Hospital Edgardo Rebagliati Martins",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Fecha: 20/11/2025", style: TextStyle(fontSize: 18)),
                      Text("Hora: 08:00 am", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Text("Estado: Pendiente de atención",
                          style: TextStyle(fontSize: 18)),
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
                  onPressed: () {
                    _showFirstPopup(context);
                  },
                  child: const Text(
                    "Firmar asistencia",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
                  child:
                      const Text("Regresar", style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSecondPopup(context);
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
}
