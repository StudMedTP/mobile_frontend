import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  double? _latitude;
  double? _longitude;
  String _status = 'Esperando acción';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo ubicación')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_status),
              const SizedBox(height: 12),
              if (_latitude != null && _longitude != null) ...[
                Text('Latitud: $_latitude'),
                Text('Longitud: $_longitude'),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: _getLocation,
                child: const Text('Obtener ubicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}