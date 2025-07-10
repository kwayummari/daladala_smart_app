import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class RouteSelector extends StatefulWidget {
  final Function(int) onRouteSelected;
  final Function(int) onPickupStopSelected;
  final Function(int) onDropoffStopSelected;

  const RouteSelector({
    Key? key,
    required this.onRouteSelected,
    required this.onPickupStopSelected,
    required this.onDropoffStopSelected,
  }) : super(key: key);

  @override
  State<RouteSelector> createState() => _RouteSelectorState();
}

class _RouteSelectorState extends State<RouteSelector> {
  int? selectedRouteId;
  int? selectedPickupStopId;
  int? selectedDropoffStopId;

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final routes = bookingProvider.routes;
        final stops = bookingProvider.stops;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Selection
            const Text(
              'Select Route',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedRouteId,
                  hint: const Text('Choose a route'),
                  isExpanded: true,
                  items: routes.map<DropdownMenuItem<int>>((route) {
                    return DropdownMenuItem<int>(
                      value: route['route_id'],
                      child: Text(
                        '${route['route_number']} - ${route['route_name']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRouteId = value;
                      selectedPickupStopId = null;
                      selectedDropoffStopId = null;
                    });
                    if (value != null) {
                      widget.onRouteSelected(value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pickup Stop Selection
            const Text(
              'Pickup Stop',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedPickupStopId,
                  hint: const Text('Choose pickup stop'),
                  isExpanded: true,
                  items: _getRouteStops(stops, selectedRouteId)
                      .map<DropdownMenuItem<int>>((stop) {
                    return DropdownMenuItem<int>(
                      value: stop['stop_id'],
                      child: Text(
                        stop['stop_name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: selectedRouteId == null
                      ? null
                      : (value) {
                          setState(() {
                            selectedPickupStopId = value;
                            // Clear dropoff if it's the same as pickup
                            if (selectedDropoffStopId == value) {
                              selectedDropoffStopId = null;
                            }
                          });
                          if (value != null) {
                            widget.onPickupStopSelected(value);
                          }
                        },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Dropoff Stop Selection
            const Text(
              'Dropoff Stop',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedDropoffStopId,
                  hint: const Text('Choose dropoff stop'),
                  isExpanded: true,
                  items: _getRouteStops(stops, selectedRouteId)
                      .where((stop) => stop['stop_id'] != selectedPickupStopId)
                      .map<DropdownMenuItem<int>>((stop) {
                    return DropdownMenuItem<int>(
                      value: stop['stop_id'],
                      child: Text(
                        stop['stop_name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: selectedRouteId == null || selectedPickupStopId == null
                      ? null
                      : (value) {
                          setState(() {
                            selectedDropoffStopId = value;
                          });
                          if (value != null) {
                            widget.onDropoffStopSelected(value);
                          }
                        },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _getRouteStops(List<dynamic> stops, int? routeId) {
    if (routeId == null) return [];
    
    // Filter stops by route - you might need to adjust this based on your data structure
    return stops.where((stop) {
      // Assuming stops have a routes array or route_id field
      return stop['route_id'] == routeId || 
             (stop['routes'] != null && 
              stop['routes'].any((r) => r['route_id'] == routeId));
    }).toList();
  }
}