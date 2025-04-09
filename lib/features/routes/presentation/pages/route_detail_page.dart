import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/loading_indicator.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/error_view.dart';
import '../providers/route_provider.dart';
import '../../../trips/presentation/pages/trip_selection_page.dart';

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
          final route = routeProvider.routes?.firstWhere(
            (r) => r.id == widget.routeId,
            orElse: () => routeProvider.selectedRoute!,
          );

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
                                          decoration: BoxDecoration(
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
                                          decoration: BoxDecoration(
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
                        ],
                      ),
                    ),

                    // View trips button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomButton(
                        text: 'View Available Trips',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => TripSelectionPage(
                                    routeId: route.id,
                                    routeName: route.routeName,
                                    from: route.startPoint,
                                    to: route.endPoint,
                                  ),
                            ),
                          );
                        },
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
