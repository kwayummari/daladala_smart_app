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

  // Stop selection state
  Stop? _selectedPickupStop;
  Stop? _selectedDropoffStop;
  bool _isSelectingStops = false;

  @override
  void initState() {
    super.initState();
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
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    // Try to find the route manually instead of using firstWhere()
    if (routeProvider.routes != null) {
      for (var route in routeProvider.routes!) {
        if (route.id == widget.routeId) {
          setState(() {
            _currentRoute = route;
          });
          break;
        }
      }
    }

    // If we didn't find the route, use selectedRoute as fallback
    if (_currentRoute == null && routeProvider.selectedRoute != null) {
      setState(() {
        _currentRoute = routeProvider.selectedRoute;
      });
    }

    // Load route stops
    await routeProvider.getRouteStops(widget.routeId);
    _setupMapMarkersAndPolylines();
  }

  void _setupMapMarkersAndPolylines() {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final stops = routeProvider.stops;

    if (stops == null || stops.isEmpty) return;

    // Create markers for each stop
    final markerSet = <Marker>{};
    final polylinePoints = <LatLng>[];

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final position = LatLng(stop.latitude, stop.longitude);
      polylinePoints.add(position);

      // Use different marker color for start, end and intermediate stops
      BitmapDescriptor markerIcon;
      if (i == 0) {
        markerIcon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        );
      } else if (i == stops.length - 1) {
        markerIcon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
      } else {
        markerIcon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        );
      }

      markerSet.add(
        Marker(
          markerId: MarkerId('stop_${stop.id}'),
          position: position,
          infoWindow: InfoWindow(
            title: stop.stopName,
            snippet: stop.isMajor ? 'Major Terminal' : 'Regular Stop',
          ),
          icon: markerIcon,
          onTap: _isSelectingStops ? () => _onStopTapped(stop) : null,
        ),
      );
    }

    // Create polyline for the route
    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylinePoints,
        color: AppTheme.primaryColor,
        width: 5,
      ),
    };

    setState(() {
      _markers = markerSet;
      _polylines = polylines;
    });
  }

  void _onStopTapped(Stop stop) {
    if (!_isSelectingStops) return;

    setState(() {
      if (_selectedPickupStop == null) {
        _selectedPickupStop = stop;
      } else if (_selectedDropoffStop == null &&
          stop.id != _selectedPickupStop!.id) {
        _selectedDropoffStop = stop;
        _isSelectingStops = false;
      }
    });
  }

  void _startStopSelection() {
    setState(() {
      _isSelectingStops = true;
      _selectedPickupStop = null;
      _selectedDropoffStop = null;
    });

    _setupMapMarkersAndPolylines(); // Refresh markers to enable tap handling

    // Show instructions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tap on the map to select pickup stop, then dropoff stop',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showStopSelectionBottomSheet() {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final stops = routeProvider.stops;

    if (stops == null || stops.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Select Stops',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Selected stops display
                      if (_selectedPickupStop != null ||
                          _selectedDropoffStop != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedPickupStop != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'From: ${_selectedPickupStop!.stopName}',
                                    ),
                                  ],
                                ),
                              if (_selectedPickupStop != null &&
                                  _selectedDropoffStop != null)
                                const SizedBox(height: 4),
                              if (_selectedDropoffStop != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'To: ${_selectedDropoffStop!.stopName}',
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Stops list
                      Expanded(
                        child: ListView.builder(
                          itemCount: stops.length,
                          itemBuilder: (context, index) {
                            final stop = stops[index];
                            final isPickupSelected =
                                _selectedPickupStop?.id == stop.id;
                            final isDropoffSelected =
                                _selectedDropoffStop?.id == stop.id;
                            final isSelected =
                                isPickupSelected || isDropoffSelected;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    isPickupSelected
                                        ? Colors.green
                                        : isDropoffSelected
                                        ? Colors.red
                                        : Colors.grey.shade300,
                                child: Icon(
                                  isPickupSelected
                                      ? Icons.circle
                                      : isDropoffSelected
                                      ? Icons.location_on
                                      : Icons.place,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                stop.stopName,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                stop.isMajor
                                    ? 'Major Terminal'
                                    : 'Regular Stop',
                              ),
                              trailing:
                                  isSelected
                                      ? Icon(
                                        Icons.check_circle,
                                        color:
                                            isPickupSelected
                                                ? Colors.green
                                                : Colors.red,
                                      )
                                      : null,
                              onTap: () {
                                setModalState(() {
                                  if (_selectedPickupStop == null) {
                                    _selectedPickupStop = stop;
                                  } else if (_selectedDropoffStop == null &&
                                      stop.id != _selectedPickupStop!.id) {
                                    _selectedDropoffStop = stop;
                                  } else {
                                    // Reset selection
                                    _selectedPickupStop = stop;
                                    _selectedDropoffStop = null;
                                  }
                                });

                                // Update main state
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPickupStop = null;
                                  _selectedDropoffStop = null;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: CustomButton(
                              text: 'Continue',
                              onPressed:
                                  _selectedPickupStop != null &&
                                          _selectedDropoffStop != null
                                      ? () {
                                        Navigator.pop(context);
                                        _navigateToTripSelection();
                                      }
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _navigateToTripSelection() {
    if (_selectedPickupStop == null ||
        _selectedDropoffStop == null ||
        _currentRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both pickup and dropoff stops'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TripSelectionPage(
              routeId: _currentRoute!.id,
              routeName: _currentRoute!.routeName,
              from: _selectedPickupStop!.stopName,
              to: _selectedDropoffStop!.stopName,
              pickupStopId: _selectedPickupStop!.id, // ✅ Now provided
              dropoffStopId: _selectedDropoffStop!.id, // ✅ Now provided
            ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Fit map to show all markers
    _fitMapToMarkers();
  }

  void _fitMapToMarkers() {
    if (_markers.isEmpty || _mapController == null) return;

    final bounds = _getBounds(_markers);
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
  }

  LatLngBounds _getBounds(Set<Marker> markers) {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          // Use the route we stored in state
          final route = _currentRoute;

          if (routeProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (routeProvider.error != null) {
            return GenericErrorView(
              message: routeProvider.error,
              onRetry: _loadRouteDetails,
            );
          }

          if (route == null) {
            return const GenericErrorView(message: 'Route not found');
          }

          final stops = routeProvider.stops;

          return Column(
            children: [
              // Map view (upper half)
              Expanded(
                child: Stack(
                  children: [
                    // Google Map
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(
                          -6.8025,
                          39.2599,
                        ), // Dar es Salaam city center
                        zoom: 13.0,
                      ),
                      onMapCreated: _onMapCreated,
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),

                    // App bar
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // Back button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  route.routeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            // Center map button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.center_focus_strong),
                                onPressed: _fitMapToMarkers,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stop selection indicator
                    if (_isSelectingStops)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Container(
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
                          child: Text(
                            _selectedPickupStop == null
                                ? 'Tap on a stop to select pickup location'
                                : _selectedDropoffStop == null
                                ? 'Now tap on a stop to select dropoff location'
                                : 'Both stops selected!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Route details (bottom sheet)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),

                    // Route info
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Route title and fare
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      route.routeName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (route.description != null)
                                      Text(
                                        route.description!,
                                        style: TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      route.status == 'active'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  route.status,
                                  style: TextStyle(
                                    color:
                                        route.status == 'active'
                                            ? Colors.green
                                            : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Route details
                          Row(
                            children: [
                              // From/To
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.circle,
                                            color: Colors.white,
                                            size: 8,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            route.startPoint,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 20,
                                      width: 1,
                                      margin: const EdgeInsets.only(left: 8),
                                      color: Colors.grey.shade300,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.circle,
                                            color: Colors.white,
                                            size: 8,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            route.endPoint,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Distance and time
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (route.distanceKm != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.straighten,
                                          size: 16,
                                          color: AppTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${route.distanceKm} km',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  if (route.estimatedTimeMinutes != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: AppTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${route.estimatedTimeMinutes} min',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Stops count
                          if (stops != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${stops.length} stops',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                          // Selected stops display
                          if (_selectedPickupStop != null ||
                              _selectedDropoffStop != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selected Journey:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_selectedPickupStop != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          color: Colors.green,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'From: ${_selectedPickupStop!.stopName}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (_selectedPickupStop != null &&
                                      _selectedDropoffStop != null)
                                    const SizedBox(height: 4),
                                  if (_selectedDropoffStop != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'To: ${_selectedDropoffStop!.stopName}',
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child:
                          _selectedPickupStop != null &&
                                  _selectedDropoffStop != null
                              ? CustomButton(
                                text: 'View Available Trips',
                                onPressed: _navigateToTripSelection,
                              )
                              : CustomButton(
                                text: 'Select Pickup & Dropoff Stops',
                                onPressed: _showStopSelectionBottomSheet,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
