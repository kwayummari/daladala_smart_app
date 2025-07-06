import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/constants.dart';
import '../../../bookings/presentation/pages/booking_confirmation_page.dart';
import '../widgets/trip_item.dart';

class TripSelectionPage extends StatefulWidget {
  final int routeId;
  final String routeName;
  final String from;
  final String to;
  final int pickupStopId;
  final int dropoffStopId;

  const TripSelectionPage({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.from,
    required this.to,
    required this.pickupStopId,
    required this.dropoffStopId,
  });

  @override
  State<TripSelectionPage> createState() => _TripSelectionPageState();
}

class _TripSelectionPageState extends State<TripSelectionPage> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _trips = [];
  Map<String, dynamic>? _fareInfo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load fare information and trips concurrently
      await Future.wait([_loadFareInfo(), _loadTrips()]);
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFareInfo() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.apiBaseUrl}${AppConstants.routesEndpoint}/fare?route_id=${widget.routeId}&start_stop_id=${widget.pickupStopId}&end_stop_id=${widget.dropoffStopId}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _fareInfo = data['data'];
          });
        }
      }
    } catch (e) {
      print('Error loading fare info: $e');
    }
  }

  Future<void> _loadTrips() async {
    try {
      final dateString = _selectedDate.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse(
          '${AppConstants.apiBaseUrl}${AppConstants.tripsEndpoint}/route/${widget.routeId}?date=$dateString',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _trips = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error loading trips: $e');
      // Fallback to sample data for demo
      setState(() {
        _trips = _getSampleTrips();
      });
    }
  }

  List<Map<String, dynamic>> _getSampleTrips() {
    return [
      {
        'trip_id': 1,
        'start_time':
            DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
        'Vehicle': {
          'vehicle_type': 'daladala',
          'plate_number': 'T123ABC',
          'capacity': 14,
          'is_air_conditioned': true,
        },
        'Driver': {
          'rating': 4.75,
          'total_ratings': 120,
          'User': {'first_name': 'David', 'last_name': 'Mwangi'},
        },
        'available_seats': 8,
        'status': 'scheduled',
      },
      {
        'trip_id': 2,
        'start_time':
            DateTime.now()
                .add(const Duration(hours: 1, minutes: 15))
                .toIso8601String(),
        'Vehicle': {
          'vehicle_type': 'daladala',
          'plate_number': 'T456DEF',
          'capacity': 14,
          'is_air_conditioned': false,
        },
        'Driver': {
          'rating': 4.60,
          'total_ratings': 95,
          'User': {'first_name': 'Daniel', 'last_name': 'Miller'},
        },
        'available_seats': 12,
        'status': 'scheduled',
      },
      {
        'trip_id': 3,
        'start_time':
            DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        'Vehicle': {
          'vehicle_type': 'daladala',
          'plate_number': 'T789GHI',
          'capacity': 14,
          'is_air_conditioned': true,
        },
        'Driver': {
          'rating': 4.85,
          'total_ratings': 200,
          'User': {'first_name': 'Grace', 'last_name': 'Kimani'},
        },
        'available_seats': 6,
        'status': 'scheduled',
      },
    ];
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });
      await _loadTrips();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _bookTrip(Map<String, dynamic> trip) {
    final vehicle = trip['Vehicle'] ?? {};

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingConfirmationPage(
              tripId: trip['trip_id'] ?? 0,
              routeName: widget.routeName,
              from: widget.from,
              to: widget.to,
              startTime:
                  DateTime.tryParse(trip['start_time'] ?? '') ?? DateTime.now(),
              fare: _fareInfo?['amount']?.toDouble() ?? 1500.0,
              vehiclePlate: vehicle['plate_number'] ?? 'Unknown',
              pickupStopId: widget.pickupStopId,
              dropoffStopId: widget.dropoffStopId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Trip'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Route Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.routeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(widget.from)),
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
                      Expanded(child: Text(widget.to)),
                    ],
                  ),
                  if (_fareInfo != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Fare: ${_fareInfo!['amount']} ${_fareInfo!['currency'] ?? 'TZS'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        if (_fareInfo!['is_estimated'] == true) ...[
                          const SizedBox(width: 8),
                          const Text(
                            '(Estimated)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Date Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Travel Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _selectedDate.formattedDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Trips List
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading available trips...'),
                        ],
                      ),
                    )
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : _trips.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_bus_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No trips available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting a different date',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _trips.length,
                      itemBuilder: (context, index) {
                        final trip = _trips[index];

                        // Extract trip data with null safety
                        final vehicle = trip['Vehicle'] ?? {};
                        final driver = trip['Driver'] ?? {};
                        final driverUser = driver['User'] ?? {};

                        // Build features list
                        List<String> features = [];
                        if (vehicle['is_air_conditioned'] == true) {
                          features.add('AC');
                        }
                        // Add more features as available in your data

                        return TripItem(
                          id: trip['trip_id'] ?? 0,
                          startTime:
                              DateTime.tryParse(trip['start_time'] ?? '') ??
                              DateTime.now(),
                          vehicleType: vehicle['vehicle_type'] ?? 'daladala',
                          vehiclePlate: vehicle['plate_number'] ?? 'Unknown',
                          driverName:
                              '${driverUser['first_name'] ?? ''} ${driverUser['last_name'] ?? ''}'
                                  .trim(),
                          driverRating: (driver['rating'] ?? 0.0).toDouble(),
                          availableSeats: trip['available_seats'] ?? 0,
                          fare: _fareInfo?['amount']?.toDouble() ?? 1500.0,
                          features: features,
                          onSelectTrip: () => _bookTrip(trip),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
