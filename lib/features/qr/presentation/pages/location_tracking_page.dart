import 'package:daladala_smart_app/features/location/presentation/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({Key? key}) : super(key: key);

  @override
  State<LocationTrackingPage> createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
  }

  Future<void> _checkLocationPermissions() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.checkLocationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              return IconButton(
                icon: Icon(
                  locationProvider.isTracking
                      ? Icons.location_on
                      : Icons.location_off,
                  color:
                      locationProvider.isTracking
                          ? Colors.green[200]
                          : Colors.white,
                ),
                onPressed: () {
                  if (locationProvider.isTracking) {
                    locationProvider.stopTracking();
                  } else {
                    locationProvider.startTracking();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Status
                LocationStatusCard(
                  isPermissionGranted: locationProvider.isPermissionGranted,
                  isServiceEnabled: locationProvider.isServiceEnabled,
                  isTracking: locationProvider.isTracking,
                  currentLocation: locationProvider.currentLocation,
                  lastUpdate: locationProvider.lastUpdate,
                ),

                const SizedBox(height: 24),

                // Tracking Controls
                TrackingControls(
                  isTracking: locationProvider.isTracking,
                  onStartTracking: () => locationProvider.startTracking(),
                  onStopTracking: () => locationProvider.stopTracking(),
                  onRequestPermission:
                      () => locationProvider.requestLocationPermission(),
                ),

                const SizedBox(height: 24),

                // Tracking Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tracking Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        SwitchListTile(
                          title: const Text('High Accuracy Mode'),
                          subtitle: const Text(
                            'Uses GPS for better accuracy (higher battery usage)',
                          ),
                          value: locationProvider.highAccuracyMode,
                          onChanged: (value) {
                            locationProvider.setHighAccuracyMode(value);
                          },
                        ),

                        const Divider(),

                        ListTile(
                          title: const Text('Update Frequency'),
                          subtitle: Text(
                            '${locationProvider.updateInterval} seconds',
                          ),
                          trailing: DropdownButton<int>(
                            value: locationProvider.updateInterval,
                            items: const [
                              DropdownMenuItem(value: 5, child: Text('5 sec')),
                              DropdownMenuItem(
                                value: 10,
                                child: Text('10 sec'),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text('30 sec'),
                              ),
                              DropdownMenuItem(value: 60, child: Text('1 min')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                locationProvider.setUpdateInterval(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Driver Status (for drivers only)
                if (locationProvider.isDriver) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Driver Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          SwitchListTile(
                            title: const Text('Available for Trips'),
                            subtitle: const Text(
                              'Allow passengers to see and book your trips',
                            ),
                            value: locationProvider.isAvailable,
                            onChanged: (value) {
                              locationProvider.setAvailability(value);
                            },
                          ),

                          const Divider(),

                          ListTile(
                            title: const Text('Current Status'),
                            subtitle: Text(locationProvider.driverStatus),
                            trailing: Chip(
                              label: Text(
                                locationProvider.driverStatus.toUpperCase(),
                              ),
                              backgroundColor: _getStatusColor(
                                locationProvider.driverStatus,
                              ),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Location History (last 10 updates)
                if (locationProvider.locationHistory.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Location Updates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ...locationProvider.locationHistory.take(5).map((
                            location,
                          ) {
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '${location['latitude'].toStringAsFixed(6)}, ${location['longitude'].toStringAsFixed(6)}',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                              subtitle: Text(
                                _formatDateTime(location['timestamp']),
                              ),
                              dense: true,
                            );
                          }).toList(),

                          if (locationProvider.locationHistory.length > 5) ...[
                            const Divider(),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  // Show full location history
                                  _showLocationHistory(
                                    context,
                                    locationProvider.locationHistory,
                                  );
                                },
                                child: Text(
                                  'View all ${locationProvider.locationHistory.length} updates',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'offline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _showLocationHistory(
    BuildContext context,
    List<Map<String, dynamic>> history,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final location = history[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          '${location['latitude'].toStringAsFixed(6)}, ${location['longitude'].toStringAsFixed(6)}',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                        subtitle: Text(_formatDateTime(location['timestamp'])),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
