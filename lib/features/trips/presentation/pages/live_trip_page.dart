// lib/features/trip/presentation/pages/live_trip_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/trip_provider.dart';
import '../widgets/passenger_list_widget.dart';
import '../widgets/trip_controls_widget.dart';

class LiveTripPage extends StatefulWidget {
  const LiveTripPage({Key? key}) : super(key: key);

  @override
  State<LiveTripPage> createState() => _LiveTripPageState();
}

class _LiveTripPageState extends State<LiveTripPage> {
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadActiveTripData();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLocationEnabled = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    setState(() {
      _isLocationEnabled = permission == LocationPermission.whileInUse || 
                          permission == LocationPermission.always;
    });

    if (_isLocationEnabled) {
      _startLocationTracking();
    }
  }

  void _startLocationTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      context.read<TripProvider>().updateDriverLocation(
        position.latitude,
        position.longitude,
      );
    });
  }

  void _loadActiveTripData() {
    context.read<TripProvider>().loadActiveTrip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Trip'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isLocationEnabled ? Icons.location_on : Icons.location_off),
            onPressed: _checkLocationPermission,
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeTrip = tripProvider.activeTrip;

          if (activeTrip == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bus, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Trip',
                    style: TextStyle(fontSize: 24, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a trip to see live tracking',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadActiveTripData,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Trip Info Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeTrip['route_name'] ?? 'Unknown Route',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vehicle: ${activeTrip['vehicle_plate'] ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(activeTrip['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            activeTrip['status']?.toUpperCase() ?? 'UNKNOWN',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Passengers: ${activeTrip['passenger_count'] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trip Controls
              TripControlsWidget(trip: activeTrip),

              // Passenger List
              Expanded(
                child: PassengerListWidget(
                  tripId: activeTrip['trip_id'],
                  passengers: activeTrip['passengers'] ?? [],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'scheduled':
        return Colors.orange;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}