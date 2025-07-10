import 'package:daladala_smart_app/features/bookings/presentation/providers/booking_provider.dart';
import 'package:daladala_smart_app/features/bookings/presentation/widgets/route_selector.dart';
import 'package:daladala_smart_app/features/bookings/presentation/widgets/trip_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'seat_selection_page.dart';

class SearchTripsPage extends StatefulWidget {
  const SearchTripsPage({Key? key}) : super(key: key);

  @override
  State<SearchTripsPage> createState() => _SearchTripsPageState();
}

class _SearchTripsPageState extends State<SearchTripsPage> {
  int? selectedRouteId;
  int? selectedPickupStopId;
  int? selectedDropoffStopId;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadRoutes();
      context.read<BookingProvider>().loadStops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Trips'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plan Your Journey',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                RouteSelector(
                  onRouteSelected: (routeId) {
                    setState(() {
                      selectedRouteId = routeId;
                      selectedPickupStopId = null;
                      selectedDropoffStopId = null;
                    });
                  },
                  onPickupStopSelected: (stopId) {
                    setState(() {
                      selectedPickupStopId = stopId;
                    });
                  },
                  onDropoffStopSelected: (stopId) {
                    setState(() {
                      selectedDropoffStopId = stopId;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _canSearch() ? _searchTrips : null,
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                return TripList(
                  trips: bookingProvider.availableTrips,
                  isLoading: bookingProvider.isLoading,
                  error: bookingProvider.error,
                  onTripSelected: (trip) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SeatSelectionPage(
                              trip: trip,
                              pickupStopId: selectedPickupStopId!,
                              dropoffStopId: selectedDropoffStopId!,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _canSearch() {
    return selectedRouteId != null &&
        selectedPickupStopId != null &&
        selectedDropoffStopId != null;
  }

  void _searchTrips() {
    context.read<BookingProvider>().searchTrips(
      routeId: selectedRouteId!,
      date: selectedDate,
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
