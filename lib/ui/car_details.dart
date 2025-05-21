import 'dart:async';
import 'package:fleet_monitoring_app/models/car_api_model.dart';
import 'package:fleet_monitoring_app/providers/car_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class CarDetailsScreen extends StatefulWidget {
  final int carId;

  const CarDetailsScreen({
    super.key,
    required this.carId,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  bool _isTracking = false;
  Timer? _trackingTimer;

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarProvider>(
      builder: (ctx, carProvider, _) {
        // Find the car by ID
        final car = carProvider.cars.firstWhere(
              (car) => car.id == widget.carId,
          orElse: () => Car(
            id: -1,
            name: 'Unknown Car',
            latitude: 0,
            longitude: 0,
            speed: 0,
            status: 'Unknown',
          ),
        );

        // If car not found
        if (car.id == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Car Details')),
            body: const Center(child: Text('Car not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(car.name),
          ),
          body: Column(
            children: [
              // Car details card
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            car.status == 'Moving' ? Icons.directions_car : Icons.car_rental,
                            size: 32,
                            color: car.status == 'Moving' ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(
                                'ID: ${car.id}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildDetailRow(Icons.speed, 'Current Speed', '${car.speed} km/h'),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          Icons.location_on,
                          'Location',
                          '${car.latitude.toStringAsFixed(5)}, ${car.longitude.toStringAsFixed(5)}'
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          car.status == 'Moving' ? Icons.play_circle_filled : Icons.pause_circle_filled,
                          'Status',
                          car.status,
                          iconColor: car.status == 'Moving' ? Colors.green : Colors.red
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                          label: Text(_isTracking ? 'Stop Tracking' : 'Track This Car'),
                          onPressed: () => _toggleTracking(car),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Map showing the car's location
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(car.latitude, car.longitude),
                        zoom: 17,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(car.id.toString()),
                          position: LatLng(car.latitude, car.longitude),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            car.status == 'Moving'
                                ? BitmapDescriptor.hueGreen
                                : BitmapDescriptor.hueRed,
                          ),
                        ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      IconData icon,
      String label,
      String value,
      {Color? iconColor}
      ) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleTracking(Car car) {
    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      // Start tracking updates
      _centerMapOnCar(car);

      _trackingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        final updatedCarProvider = Provider.of<CarProvider>(context, listen: false);
        final updatedCar = updatedCarProvider.cars.firstWhere(
              (c) => c.id == widget.carId,
          orElse: () => car,
        );

        _centerMapOnCar(updatedCar);
      });
    } else {
      // Stop tracking
      _trackingTimer?.cancel();
      _trackingTimer = null;
    }
  }

  Future<void> _centerMapOnCar(Car car) async {
    final controller = await _mapController.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(car.latitude, car.longitude),
          zoom: 17,
        ),
      ),
    );
  }
}