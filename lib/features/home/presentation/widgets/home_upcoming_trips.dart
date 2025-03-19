import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/pages/trip_detail_page.dart';

class HomeUpcomingTrips extends StatefulWidget {
  const HomeUpcomingTrips({Key? key}) : super(key: key);

  @override
  State<HomeUpcomingTrips> createState() => _HomeUpcomingTripsState();
}

class _HomeUpcomingTripsState extends State<HomeUpcomingTrips> {
  bool _isLoading = true;
  bool _hasTrips = true;
  
  // Sample data for demonstration
  final List<Map<String, dynamic>> _trips = [
    {
      'id': 1,
      'route_name': 'Mbezi - CBD',
      'start_point': 'Mbezi Mwisho',
      'end_point': 'Posta CBD',
      'start_time': DateTime.now().add(const Duration(minutes: 30)),
      'status': 'scheduled',
      'vehicle_type': 'daladala',
      'seat_number': 'A12',
      'fare_amount': 1500,
    },
    {
      'id': 2,
      'route_name': 'Kimara - CBD',
      'start_point': 'Kimara Mwisho',
      'end_point': 'Posta CBD',
      'start_time': DateTime.now().add(const Duration(hours: 2)),
      'status': 'scheduled',
      'vehicle_type': 'daladala',
      'seat_number': 'B5',
      'fare_amount': 1500,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadUpcomingTrips();
  }
  
  Future<void> _loadUpcomingTrips() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Trips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to see all trips
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (!_hasTrips)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_bus_outlined,
                      size: 48,
                      color: AppTheme.textTertiaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming trips',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book a trip to get started',
                      style: TextStyle(
                        color: AppTheme.textTertiaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to search routes
                      },
                      child: const Text('Book a Trip'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];
                return _UpcomingTripItem(
                  id: trip['id'],
                  routeName: trip['route_name'],
                  startPoint: trip['start_point'],
                  endPoint: trip['end_point'],
                  startTime: trip['start_time'],
                  status: trip['status'],
                  vehicleType: trip['vehicle_type'],
                  seatNumber: trip['seat_number'],
                  fareAmount: trip['fare_amount'].toDouble(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailPage(tripId: trip['id']),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _UpcomingTripItem extends StatelessWidget {
  final int id;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final DateTime startTime;
  final String status;
  final String vehicleType;
  final String seatNumber;
  final double fareAmount;
  final VoidCallback onTap;

  const _UpcomingTripItem({
    Key? key,
    required this.id,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    required this.startTime,
    required this.status,
    required this.vehicleType,
    required this.seatNumber,
    required this.fareAmount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format time
    final formattedTime = DateFormat('HH:mm').format(startTime);
    
    // Determine how to display the time (today, tomorrow, or date)
    final timeDisplay = startTime.isToday
        ? 'Today, $formattedTime'
        : startTime.isTomorrow
            ? 'Tomorrow, $formattedTime'
            : '${DateFormat('EEE, d MMM').format(startTime)}, $formattedTime';
            
    // Time remaining
    final now = DateTime.now();
    final difference = startTime.difference(now);
    final hoursRemaining = difference.inHours;
    final minutesRemaining = difference.inMinutes % 60;
    
    String timeRemaining;
    if (hoursRemaining > 0) {
      timeRemaining = '$hoursRemaining h ${minutesRemaining > 0 ? '$minutesRemaining min' : ''} left';
    } else {
      timeRemaining = '$minutesRemaining min left';
    }
    
    Color statusColor;
    switch (status) {
      case 'scheduled':
        statusColor = AppTheme.confirmedColor;
        break;
      case 'in_progress':
        statusColor = AppTheme.inProgressColor;
        break;
      case 'completed':
        statusColor = AppTheme.completedColor;
        break;
      case 'cancelled':
        statusColor = AppTheme.cancelledColor;
        break;
      default:
        statusColor = AppTheme.pendingColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top part with route and status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    vehicleType == 'daladala'
                        ? Icons.directions_bus
                        : Icons.directions_bus_filled,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      routeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.replaceAll('_', ' ').capitalize,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Trip details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route details
                  Row(
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle_outlined, size: 14, color: Colors.green),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.grey.shade300,
                          ),
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.red),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              startPoint,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              endPoint,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 24),
                  
                  // Trip info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeDisplay,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              timeRemaining,
                              style: TextStyle(
                                color: AppTheme.warningColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Fare and details button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            fareAmount.toPrice,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          OutlinedButton(
                            onPressed: onTap,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}