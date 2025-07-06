import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/loading_indicator.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/error_view.dart';
import '../providers/route_provider.dart';
import '../../../trips/presentation/pages/trip_selection_page.dart';
import '../../domain/entities/transport_route.dart';
import '../../domain/entities/stop.dart';

class RouteDetailPage extends StatefulWidget {
  final int routeId;

  const RouteDetailPage({super.key, required this.routeId});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  TransportRoute? _currentRoute;
  List<Stop> _routeStops = [];

  // Stop selection state
  Stop? _selectedPickupStop;
  Stop? _selectedDropoffStop;
  bool _isSelectingStops = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🔍 RouteDetailPage initialized with routeId: ${widget.routeId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRouteDetails();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadRouteDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('📡 Loading route details for route ${widget.routeId}');

      final routeProvider = Provider.of<RouteProvider>(context, listen: false);

      // Try to find the route in already loaded routes first
      TransportRoute? foundRoute;
      if (routeProvider.routes != null) {
        try {
          foundRoute = routeProvider.routes!.firstWhere(
            (route) => route.id == widget.routeId,
          );
          print('✅ Found route in cache: ${foundRoute.routeName}');
        } catch (e) {
          print('⚠️ Route not found in cache, will fetch from API');
        }
      }

      // If route not found in cache, try to load all routes first
      if (foundRoute == null) {
        print('🔄 Loading all routes first...');
        await routeProvider.getAllRoutes();

        if (routeProvider.routes != null) {
          try {
            foundRoute = routeProvider.routes!.firstWhere(
              (route) => route.id == widget.routeId,
            );
            print('✅ Found route after loading: ${foundRoute.routeName}');
          } catch (e) {
            print(
              '❌ Route ${widget.routeId} not found even after loading all routes',
            );
          }
        }
      }

      if (foundRoute != null) {
        setState(() {
          _currentRoute = foundRoute;
        });

        // Load route stops
        print('🏪 Loading stops for route ${widget.routeId}');
        final stopsResult = await routeProvider.getRouteStops(widget.routeId);

        stopsResult.fold(
          (failure) {
            print('❌ Failed to load route stops: ${failure.message}');
            setState(() {
              _error = 'Failed to load route stops: ${failure.message}';
            });
          },
          (stops) {
            print('✅ Loaded ${stops.length} stops for route');
            setState(() {
              _routeStops = stops;
            });
            _updateMapMarkers(stops);
          },
        );
      } else {
        setState(() {
          _error = 'Route not found (ID: ${widget.routeId})';
        });
      }
    } catch (e) {
      print('💥 Error in _loadRouteDetails: $e');
      setState(() {
        _error = 'Failed to load route details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMapMarkers(List<Stop> stops) {
    try {
      final markers = <Marker>{};

      for (int i = 0; i < stops.length; i++) {
        final stop = stops[i];
        if (stop.latitude != 0.0 && stop.longitude != 0.0) {
          markers.add(
            Marker(
              markerId: MarkerId('stop_${stop.id}'),
              position: LatLng(stop.latitude, stop.longitude),
              infoWindow: InfoWindow(
                title: stop.stopName,
                snippet: stop.isMajor ? 'Major Stop' : 'Regular Stop',
              ),
              icon: _getMarkerIcon(stop),
            ),
          );
        }
      }

      setState(() {
        _markers = markers;
      });

      // Move camera to show all markers
      if (markers.isNotEmpty && _mapController != null) {
        _fitMarkersOnMap();
      }
    } catch (e) {
      print('⚠️ Error updating map markers: $e');
    }
  }

  BitmapDescriptor _getMarkerIcon(Stop stop) {
    // Change marker color based on selection
    if (_selectedPickupStop?.id == stop.id) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (_selectedDropoffStop?.id == stop.id) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (stop.isMajor) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  void _fitMarkersOnMap() async {
    if (_markers.isEmpty || _mapController == null) return;

    try {
      final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    } catch (e) {
      print('⚠️ Error fitting markers on map: $e');
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      minLat = minLat < pos.latitude ? minLat : pos.latitude;
      maxLat = maxLat > pos.latitude ? maxLat : pos.latitude;
      minLng = minLng < pos.longitude ? minLng : pos.longitude;
      maxLng = maxLng > pos.longitude ? maxLng : pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _showStopSelectionDialog() {
    if (_routeStops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No stops available for this route'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Sort stops by some order if available, otherwise use the list order
    final sortedStops = List<Stop>.from(_routeStops);

    int? selectedPickupId;
    int? selectedDropoffId;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Select Pickup & Drop-off Stops'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 500,
                    child: Column(
                      children: [
                        Text(
                          'Route: ${_currentRoute?.routeName ?? 'Unknown Route'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        // Pickup Stop Selection
                        Text(
                          '1. Select Pickup Stop:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: sortedStops.length,
                            itemBuilder: (context, index) {
                              final stop = sortedStops[index];
                              final isSelected = selectedPickupId == stop.id;

                              return Card(
                                margin: EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 8,
                                ),
                                color:
                                    isSelected
                                        ? Colors.green.withOpacity(0.1)
                                        : null,
                                child: ListTile(
                                  title: Text(
                                    stop.stopName,
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected ? FontWeight.bold : null,
                                      color: isSelected ? Colors.green : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    stop.address ?? 'Stop ${index + 1}',
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.green
                                              : stop.isMajor
                                              ? Colors.orange
                                              : Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  trailing:
                                      isSelected
                                          ? Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          )
                                          : null,
                                  onTap: () {
                                    setDialogState(() {
                                      selectedPickupId = stop.id;
                                      // Clear dropoff if it's before pickup
                                      if (selectedDropoffId != null) {
                                        final dropoffIndex = sortedStops
                                            .indexWhere(
                                              (s) => s.id == selectedDropoffId,
                                            );
                                        if (dropoffIndex <= index) {
                                          selectedDropoffId = null;
                                        }
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 16),

                        // Dropoff Stop Selection
                        Text(
                          '2. Select Drop-off Stop:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: sortedStops.length,
                            itemBuilder: (context, index) {
                              final stop = sortedStops[index];
                              final isSelected = selectedDropoffId == stop.id;

                              // Disable stops that are before or same as pickup
                              final pickupIndex =
                                  selectedPickupId != null
                                      ? sortedStops.indexWhere(
                                        (s) => s.id == selectedPickupId,
                                      )
                                      : -1;
                              final isDisabled =
                                  selectedPickupId == null ||
                                  index <= pickupIndex;

                              return Card(
                                margin: EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 8,
                                ),
                                color:
                                    isSelected
                                        ? Colors.red.withOpacity(0.1)
                                        : isDisabled
                                        ? Colors.grey.withOpacity(0.1)
                                        : null,
                                child: ListTile(
                                  title: Text(
                                    stop.stopName,
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected ? FontWeight.bold : null,
                                      color:
                                          isSelected
                                              ? Colors.red
                                              : isDisabled
                                              ? Colors.grey
                                              : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    stop.address ?? 'Stop ${index + 1}',
                                    style: TextStyle(
                                      color: isDisabled ? Colors.grey : null,
                                    ),
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.red
                                              : isDisabled
                                              ? Colors.grey
                                              : stop.isMajor
                                              ? Colors.orange
                                              : Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  trailing:
                                      isSelected
                                          ? Icon(Icons.check, color: Colors.red)
                                          : null,
                                  enabled: !isDisabled,
                                  onTap:
                                      isDisabled
                                          ? null
                                          : () {
                                            setDialogState(() {
                                              selectedDropoffId = stop.id;
                                            });
                                          },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          selectedPickupId != null && selectedDropoffId != null
                              ? () {
                                Navigator.pop(context);

                                // Get stop details
                                final pickupStop = sortedStops.firstWhere(
                                  (stop) => stop.id == selectedPickupId,
                                );
                                final dropoffStop = sortedStops.firstWhere(
                                  (stop) => stop.id == selectedDropoffId,
                                );

                                // Update map markers
                                setState(() {
                                  _selectedPickupStop = pickupStop;
                                  _selectedDropoffStop = dropoffStop;
                                });
                                _updateMapMarkers(_routeStops);

                                print('🚀 Navigating to trip selection:');
                                print(
                                  '   Pickup: ${pickupStop.stopName} (ID: $selectedPickupId)',
                                );
                                print(
                                  '   Dropoff: ${dropoffStop.stopName} (ID: $selectedDropoffId)',
                                );

                                // Navigate to trip selection
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TripSelectionPage(
                                          routeId: widget.routeId,
                                          routeName:
                                              _currentRoute?.routeName ??
                                              'Unknown Route',
                                          from: pickupStop.stopName,
                                          to: dropoffStop.stopName,
                                          pickupStopId: selectedPickupId!,
                                          dropoffStopId: selectedDropoffId!,
                                        ),
                                  ),
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Find Trips'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRoute?.routeName ?? 'Route Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading && _currentRoute != null && _routeStops.isNotEmpty)
            IconButton(
              icon: Icon(Icons.list),
              onPressed: _showStopSelectionDialog,
              tooltip: 'Select Stops',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: LoadingIndicator())
              : _error != null
              ? ErrorView(message: _error!, onRetry: _loadRouteDetails)
              : _currentRoute == null
              ? const Center(child: Text('Route not found'))
              : Column(
                children: [
                  // Route Info Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _currentRoute!.routeNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentRoute!.routeName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentRoute!.startPoint,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentRoute!.endPoint,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        if (_currentRoute!.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _currentRoute!.description!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (_currentRoute!.distanceKm != null) ...[
                              Icon(
                                Icons.straighten,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_currentRoute!.distanceKm!.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (_currentRoute!.estimatedTimeMinutes !=
                                null) ...[
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_currentRoute!.estimatedTimeMinutes} min',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              '${_routeStops.length} stops',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Selected Stops Display
                  if (_selectedPickupStop != null ||
                      _selectedDropoffStop != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Selected Stops',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '🟢 Pickup: ${_selectedPickupStop?.stopName ?? 'Not selected'}',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '🔴 Drop-off: ${_selectedDropoffStop?.stopName ?? 'Not selected'}',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Map
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            _routeStops.isNotEmpty
                                ? GoogleMap(
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                    _fitMarkersOnMap();
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      _routeStops.first.latitude != 0.0
                                          ? _routeStops.first.latitude
                                          : -6.7924,
                                      _routeStops.first.longitude != 0.0
                                          ? _routeStops.first.longitude
                                          : 39.2083,
                                    ),
                                    zoom: 12,
                                  ),
                                  markers: _markers,
                                  polylines: _polylines,
                                )
                                : const Center(
                                  child: Text(
                                    'No location data available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Select Pickup & Drop-off Stops',
                          onPressed:
                              _routeStops.isNotEmpty
                                  ? _showStopSelectionDialog
                                  : null,
                          icon: Icons.list,
                        ),
                        if (_selectedPickupStop != null &&
                            _selectedDropoffStop != null) ...[
                          const SizedBox(height: 8),
                          CustomButton(
                            text: 'Find Trips',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => TripSelectionPage(
                                        routeId: widget.routeId,
                                        routeName:
                                            _currentRoute?.routeName ??
                                            'Unknown Route',
                                        from: _selectedPickupStop!.stopName,
                                        to: _selectedDropoffStop!.stopName,
                                        pickupStopId: _selectedPickupStop!.id,
                                        dropoffStopId: _selectedDropoffStop!.id,
                                      ),
                                ),
                              );
                            },
                            icon: Icons.search,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
