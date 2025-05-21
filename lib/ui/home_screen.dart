import 'dart:async';
import 'package:fleet_monitoring_app/models/car_api_model.dart';
import 'package:fleet_monitoring_app/providers/car_provider.dart';
import 'package:fleet_monitoring_app/ui/car_details.dart';
import 'package:fleet_monitoring_app/ui/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Map<int, Marker> _markers = {};


  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(-1.950, 30.059),
    zoom: 16,
  );

  @override
  void initState() {
    super.initState();
    // Initial marker update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      _updateMarkers(carProvider.filteredCars);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final carProvider = Provider.of<CarProvider>(context);
    _updateMarkers(carProvider.filteredCars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(context),
          ),
        ],
      ),
      body: Consumer<CarProvider>(
        builder: (ctx, carProvider, _) {
          // If data is still loading and we have no cached data
          if (carProvider.isLoading && carProvider.cars.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's an error and we have no cached data
          if (carProvider.error != null && carProvider.cars.isEmpty) {
            return _buildErrorWidget(carProvider.error!);
          }

          // We have data to display (either fresh or cached)
          return Stack(
            children: [
              // Google Map
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _defaultLocation,
                markers: Set<Marker>.of(_markers.values),
                onMapCreated: (GoogleMapController controller) {
                  _mapController.complete(controller);
                },
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                compassEnabled: true,
                zoomControlsEnabled: false,
              ),

              // Search and filter controls
              Positioned(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                child: Column(
                  children: [
                    FleetSearchBar(
                      onChanged:
                          (query) => carProvider.updateSearchQuery(query),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusFilter(carProvider),
                  ],
                ),
              ),

              // Loading indicator or error for refreshes
              if (carProvider.isLoading && carProvider.cars.isNotEmpty)
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),

              // Display error if any while having cached data
              if (carProvider.error != null && carProvider.cars.isNotEmpty)
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error refreshing: ${carProvider.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Failed to load car data',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () => _refreshData(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(CarProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_list, size: 18),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: provider.statusFilter,
            underline: const SizedBox(),
            isDense: true,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Cars')),
              DropdownMenuItem(value: 'Moving', child: Text('Moving Only')),
              DropdownMenuItem(value: 'Parked', child: Text('Parked Only')),
            ],
            onChanged: (value) {
              if (value != null) {
                provider.updateStatusFilter(value);
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateMarkers(List<Car> cars) {
    final Map<int, Marker> markers = {};

    for (final car in cars) {
      markers[car.id] = Marker(
        markerId: MarkerId(car.id.toString()),
        position: LatLng(car.latitude, car.longitude),
        infoWindow: InfoWindow(
          title: car.name,
          snippet: '${car.speed} km/h | ${car.status}',
          onTap: () => _navigateToCarDetails(car.id),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          car.status == 'Moving'
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _navigateToCarDetails(int carId) {
    Provider.of<CarProvider>(context, listen: false).selectCar(carId);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarDetailsScreen(carId: carId)),
    );
  }

  void _refreshData(BuildContext context) {
    Provider.of<CarProvider>(context, listen: false).fetchCars();
  }
}
