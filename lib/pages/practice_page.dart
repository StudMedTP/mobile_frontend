import 'package:flutter/material.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  bool accepted = false; // checkbox

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
                Center(
                  child: const Text(
                    "Prácticas Clínicas",
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


                      Center(
                        child: const Text(
                          "Práctica de Cardiología",
                          style: TextStyle(

                            fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),


                      const SizedBox(height: 15),


                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.blueAccent,
                            padding:
                              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            _showUploadPopup();
                          },
                          child: const Text(
                            "Subir Caso Atendido",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),),
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

  // ===========================
  // POPUP 1: SUBIR INFORME
  // ===========================
  void _showUploadPopup() {
    accepted = false; // reset checkbox

    showDialog(
      context: context,
      barrierDismissible: false, // evitar cerrar tocando afuera
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Subir informe",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Estas por subir tu informe de casos atendidos.",
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),

                    // Botón estético (no hace nada)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {},
                      child: const Text("Subir informe"),
                    ),

                    const SizedBox(height: 10),

                    // Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: accepted,
                          onChanged: (value) {
                            setStatePopup(() {
                              accepted = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            "Acepto que los datos enviados son anónimos y no comprometen la identidad de los pacientes.",
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Botones inferiores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Regresar"),
                        ),
                        TextButton(
                          onPressed: accepted
                              ? () {
                                  Navigator.pop(context);
                                  _showSuccessPopup();
                                }
                              : null,
                          child: const Text("Enviar"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================
  // POPUP 2: REPORTE ENVIADO
  // ===========================
  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Reporte enviado correctamente",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                const Text(
                  "Se ha enviado de manera exitosa el reporte de su caso atendido.\n\n"
                  "Su docente encargado se encargará de proporcionarle el feedback correspondiente.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Aceptar"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
