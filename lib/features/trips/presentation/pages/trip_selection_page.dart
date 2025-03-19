import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/utils/extensions.dart';
import '../../../bookings/presentation/pages/booking_confirmation_page.dart';
import '../widgets/trip_item.dart';

class TripSelectionPage extends StatefulWidget {
  final int routeId;
  final String routeName;
  final String from;
  final String to;

  const TripSelectionPage({
    Key? key,
    required this.routeId,
    required this.routeName,
    required this.from,
    required this.to,
  }) : super(key: key);

  @override
  State<TripSelectionPage> createState() => _TripSelectionPageState();
}

class _TripSelectionPageState extends State<TripSelectionPage> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  
  // Sample trip data
  final List<Map<String, dynamic>> _trips = [
    {
      'id': 1,
      'start_time': DateTime.now().add(const Duration(minutes: 30)),
      'vehicle_type': 'daladala',
      'vehicle_plate': 'T123ABC',
      'driver_name': 'David Driver',
      'driver_rating': 4.75,
      'available_seats': 8,
      'fare': 1500.0,
      'features': ['AC', 'WiFi'],
    },
    {
      'id': 2,
      'start_time': DateTime.now().add(const Duration(hours: 1, minutes: 30)),
      'vehicle_type': 'daladala',
      'vehicle_plate': 'T456DEF',
      'driver_name': 'Daniel Miller',
      'driver_rating': 4.5,
      'available_seats': 12,
      'fare': 1500.0,
      'features': [],
    },
    {
      'id': 3,
      'start_time': DateTime.now().add(const Duration(hours: 2, minutes: 45)),
      'vehicle_type': 'minibus',
      'vehicle_plate': 'T789GHI',
      'driver_name': 'Michael Wilson',
      'driver_rating': 4.8,
      'available_seats': 5,
      'fare': 1500.0,
      'features': ['AC'],
    },
  ];
  
  List<DateTime> _availableDates = [];
  
  @override
  void initState() {
    super.initState();
    _loadTrips();
    _generateAvailableDates();
  }
  
  void _generateAvailableDates() {
    final now = DateTime.now();
    _availableDates = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day + index);
    });
  }
  
  Future<void> _loadTrips() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }
  
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    
    // Reload trips for the selected date
    setState(() {
      _isLoading = true;
    });
    
    _loadTrips();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
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
                      Icons.circle_outlined,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.from,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.to,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Date selection
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: _availableDates.map((date) {
                  final isSelected = date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;
                  
                  return GestureDetector(
                    onTap: () => _selectDate(date),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            date.shortDayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white70
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.shortMonthName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white70
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Trips list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                    ? _buildNoTripsView()
                    : _buildTripsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoTripsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No trips available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no trips available for the selected date. Please try another date.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Try Another Date',
              icon: Icons.calendar_today,
              onPressed: () {
                // Scroll to date selection
              },
              isFullWidth: false,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTripsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final trip = _trips[index];
        return TripItem(
          id: trip['id'],
          startTime: trip['start_time'],
          vehicleType: trip['vehicle_type'],
          vehiclePlate: trip['vehicle_plate'],
          driverName: trip['driver_name'],
          driverRating: trip['driver_rating'],
          availableSeats: trip['available_seats'],
          fare: trip['fare'],
          features: List<String>.from(trip['features']),
          onSelectTrip: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingConfirmationPage(
                  tripId: trip['id'],
                  routeName: widget.routeName,
                  from: widget.from,
                  to: widget.to,
                  startTime: trip['start_time'],
                  fare: trip['fare'],
                  vehiclePlate: trip['vehicle_plate'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}