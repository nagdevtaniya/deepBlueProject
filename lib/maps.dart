import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSRM Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];
  double totalDistance = 0.0; // in kilometers
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  LatLng? sourceCoords;
  LatLng? destinationCoords;
  bool _isSidebarOpen = true;

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> fetchAndDisplayRoute() async {
    if (sourceCoords == null || destinationCoords == null) return;

    try {
      final routeData = await fetchRoute(
        sourceCoords!.latitude,
        sourceCoords!.longitude,
        destinationCoords!.latitude,
        destinationCoords!.longitude,
      );

      final geometry = routeData['routes'][0]['geometry'];
      final distance = routeData['routes'][0]['distance'];

      setState(() {
        routePoints = decodePolyline(geometry);
        totalDistance = distance / 1000; // Convert meters to kilometers
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchRoute(
      double sourceLat, double sourceLong, double destLat, double destLong) async {
    final response = await http.get(
      Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$sourceLong,$sourceLat;$destLong,$destLat?overview=full',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load route: ${response.statusCode}');
    }
  }

  Future<LatLng> getCoordinatesFromAddress(String address) async {
    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1',
      ),
      headers: {
        'User-Agent': 'YourAppName/1.0 (your@email.com)', // Add a custom user agent
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      } else {
        throw Exception('No coordinates found for the address: $address');
      }
    } else {
      throw Exception('Failed to load coordinates: ${response.statusCode}');
    }
  }

  List<LatLng> decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);
    return result.map((point) => LatLng(point.latitude, point.longitude)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(19.077878, 72.915728), // Default center (Mumbai)
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.osrm_map_demo',
                tileProvider: CancellableNetworkTileProvider(), // Use the cancellable tile provider
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    color: Colors.blue,
                    strokeWidth: 5.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (sourceCoords != null)
                    Marker(
                      point: sourceCoords!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  if (destinationCoords != null)
                    Marker(
                      point: destinationCoords!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_pin, color: Colors.green, size: 40),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 10,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSidebarOpen = !_isSidebarOpen;
                });
              },
              child: Icon(_isSidebarOpen ? Icons.close : Icons.menu),
            ),
          ),
          if (_isSidebarOpen)
            Positioned(
              top: 100,
              left: 10,
              child: Container(
                width: 300,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _sourceController,
                      decoration: InputDecoration(
                        labelText: 'Source Address',
                        hintText: 'e.g., New York, NY, USA',
                      ),
                    ),
                    TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        labelText: 'Destination Address',
                        hintText: 'e.g., Paris, France',
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_sourceController.text.isNotEmpty && _destinationController.text.isNotEmpty) {
                          try {
                            sourceCoords = await getCoordinatesFromAddress(_sourceController.text);
                            destinationCoords = await getCoordinatesFromAddress(_destinationController.text);
                            fetchAndDisplayRoute();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter both source and destination addresses')),
                          );
                        }
                      },
                      child: Text('Get Route'),
                    ),
                    SizedBox(height: 16),
                    Text('Distance: ${totalDistance.toStringAsFixed(2)} km'), // Only show distance
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}