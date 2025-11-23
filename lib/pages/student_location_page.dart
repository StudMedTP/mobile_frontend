import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StudentLocationPage extends StatefulWidget {
  const StudentLocationPage({super.key});

  @override
  State<StudentLocationPage> createState() => _StudentLocationPageState();
}

class _StudentLocationPageState extends State<StudentLocationPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // Coordenadas 
    final LatLng center = LatLng(-12.078749, -77.040358);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --------- TÍTULO ----------
            const SizedBox(height: 20),
            const Text(
              "Asistencia del estudiante",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Se firmó la asistencia en el horario:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Fecha: 20/11/2025",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Hora: 08:00 am",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // --------- MAPA ----------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                      tileProvider: NetworkTileProvider(headers: {
                        'User-Agent': 'mi-app/1.0 (joserodrigolopez@icloud.com)',
                        'Referer': 'https://localhost',
                      }),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
