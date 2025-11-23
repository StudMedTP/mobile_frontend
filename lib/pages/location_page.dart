import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  double? _latitude;
  double? _longitude;
  String _status = 'Esperando acción';

  final MapController _mapController = MapController();

  Future<void> _getLocation() async {
    setState(() => _status = 'Comprobando permisos...');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _status = 'Servicio de localización deshabilitado');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _status = 'Permiso denegado');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _status = 'Permiso denegado permanentemente');
      return;
    }

    setState(() => _status = 'Obteniendo posición...');
    try {
      Position pos = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _status = 'Posición obtenida';
      });
      _mapController.move(LatLng(_latitude!, _longitude!), 15.0);
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _latitude != null && _longitude != null;
    final center = hasLocation ? LatLng(_latitude!, _longitude!) : LatLng(-12.078749, -77.040358);

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación')),
      body: Column(
        children: [
          Expanded(
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
                    'Referer': 'https://localhost'
                  }),
                ),
                if (hasLocation)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 80,
                        height: 80,
                        child: Icon(
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(_status),
                const SizedBox(height: 8),
                if (hasLocation) ...[
                  Text('Latitud: $_latitude'),
                  Text('Longitud: $_longitude'),
                ],
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _getLocation,
                  child: const Text('Obtener ubicación'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}