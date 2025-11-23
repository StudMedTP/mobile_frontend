import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key, required this.role});
  final String role;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
                    "Notificaciones",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),


                const SizedBox(height: 25),


                // ===================== TARJETA 1 =====================
                _buildNotificationCard(
                  icon: Icons.chat_bubble_outline,
                  text: "Nuevo FeedBack Recibido",
                ),

                const SizedBox(height: 20),

                // ===================== TARJETA 2 =====================
                _buildNotificationCard(
                  icon: Icons.checklist_rtl_rounded,
                  text: "Práctica completada!",
                ),

                const SizedBox(height: 20),

                // ===================== TARJETA 3 =====================
                _buildNotificationCard(
                  icon: Icons.assignment_late_rounded,
                  text: "Nueva Práctica Pendiente",
                ),

              
              ],
            ),
          ),
        ),
      ),
    );


  }

  Widget _buildNotificationCard({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.lightBlue[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.black87),
          const SizedBox(width: 15),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}