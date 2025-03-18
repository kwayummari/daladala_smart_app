import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/trip.dart';
import 'package:daladala_smart_app/providers/trip_provider.dart';
import 'package:daladala_smart_app/screens/booking/new_booking_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class TripDetailScreen extends StatefulWidget {
  final int tripId;
  
  const TripDetailScreen({
    Key? key,
    required this.tripId,
  }) : super(key: key);

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }
  
  Future<void> _loadTripDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      await tripProvider.fetchTripDetails(widget.tripId, startTracking: true);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load trip details: ${e.toString()}';
      });
    }
  }
  
  @override
  void dispose() {
    // Stop trip tracking when leaving the screen
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.stopTripTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _buildContent(),
      floatingActionButton: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          final trip = tripProvider.currentTrip;
          
          if (trip == null || !trip.isActive) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewBookingScreen(
                    routeId: trip.routeId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Book Trip'),
            backgroundColor: AppColors.primary,
          );
        },
      ),
    );
  }
  
  Widget _buildContent() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Text(
                'Error',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSizes.marginLarge),
              ElevatedButton(
                onPressed: _loadTripDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Consumer<TripProvider>(
      builder: (context, tripProvider, _) {
        final trip = tripProvider.currentTrip;
        
        if (trip == null) {
          return const Center(
            child: Text('Trip not found'),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Trip Status Card
              _buildTripStatusCard(trip),
              const SizedBox(height: AppSizes.marginMedium),
              
              // Trip Details Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip ID and Schedule
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trip #${trip.tripId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('EEE, MMM d').format(
                              DateTime.parse(trip.startTime),
                            ),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Trip Time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Departure: ${DateFormat('hh:mm a').format(
                              DateTime.parse(trip.startTime),
                            )}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 24),
                      
                      // Route Information
                      if (trip.route != null) ...[
                        const Text(
                          'Route Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Route Number and Name
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${trip.route!.routeNumber} - ${trip.route!.routeName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Start and End Points
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: AppColors.primary,
                                  size: 12,
                                ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.route!.startPoint,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    trip.route!.endPoint,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Distance and Duration
                        if (trip.route!.distanceKm != null || trip.route!.estimatedTimeMinutes != null)
                          Row(
                            children: [
                              if (trip.route!.distanceKm != null) ...[
                                const Icon(
                                  Icons.straighten,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${trip.route!.distanceKm!.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                              
                              if (trip.route!.estimatedTimeMinutes != null) ...[
                                const Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(trip.route!.estimatedTimeMinutes!),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                        const Divider(height: 24),
                      ],
                      
                      // Vehicle Information
                      if (trip.vehicle != null) ...[
                        const Text(
                          'Vehicle Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Vehicle Details
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                trip.vehicle!.plateNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Vehicle Type and Capacity
                        Row(
                          children: [
                            const SizedBox(width: 26),
                            Text(
                              '${trip.vehicle!.vehicleType.toUpperCase()} • ',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${trip.vehicle!.capacity} seats',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            
                            if (trip.vehicle!.isAirConditioned) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.ac_unit,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'AC',
                                style: TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Vehicle Color
                        if (trip.vehicle!.color != null)
                          Row(
                            children: [
                              const SizedBox(width: 26),
                              const Text(
                                'Color: ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                trip.vehicle!.color!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          
                        const Divider(height: 24),
                      ],
                      
                      // Driver Information
                      if (trip.driver != null && trip.driver!.user != null) ...[
                        const Text(
                          'Driver Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Driver Name
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                trip.driver!.user!.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Driver Rating
                        Row(
                          children: [
                            const SizedBox(width: 26),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${trip.driver!.rating} (${trip.driver!.totalRatings} ratings)',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.marginMedium),
              
              // Route Progress Card
              _buildTripProgressCard(trip),
              
              // Extra space for FAB
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTripStatusCard(Trip trip) {
    Color statusColor;
    String statusText;
    String statusDescription;
    IconData statusIcon;
    
    switch (trip.status) {
      case 'scheduled':
        statusColor = Colors.orange;
        statusText = 'Scheduled';
        statusDescription = 'This trip is scheduled to start soon.';
        statusIcon = Icons.schedule;
        break;
      case 'in_progress':
        statusColor = AppColors.primary;
        statusText = 'In Progress';
        statusDescription = 'This trip is currently in progress.';
        statusIcon = Icons.directions_bus;
        break;
      case 'completed':
        statusColor = AppColors.success;
        statusText = 'Completed';
        statusDescription = 'This trip has been completed.';
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        statusText = 'Cancelled';
        statusDescription = 'This trip has been cancelled.';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = trip.status.replaceAll('_', ' ').toUpperCase();
        statusDescription = '';
        statusIcon = Icons.info;
    }
    
    return Card(
      elevation: 2,
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusDescription,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTripProgressCard(Trip trip) {
    final tracking = trip.tracking;
    
    if (tracking == null || tracking.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Sort the tracking points by stop order
    final sortedTracking = List<RouteTracking>.from(tracking);
    sortedTracking.sort((a, b) {
      final aStop = a.stop;
      final bStop = b.stop;
      
      if (aStop == null || bStop == null) return 0;
      
      // You'd need to get the stop order from somewhere
      return 0; // Placeholder
    });
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Progress',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress Stepper
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedTracking.length,
              itemBuilder: (context, index) {
                final trackingItem = sortedTracking[index];
                final stop = trackingItem.stop;
                
                if (stop == null) {
                  return const SizedBox.shrink();
                }
                
                // Determine step state
                Widget stepIndicator;
                Color lineColor;
                
                switch (trackingItem.status) {
                  case 'departed':
                    stepIndicator = const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    );
                    lineColor = AppColors.success;
                    break;
                  case 'arrived':
                    stepIndicator = const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    );
                    lineColor = AppColors.primary;
                    break;
                  case 'pending':
                    stepIndicator = Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textSecondary,
                          width: 2,
                        ),
                      ),
                    );
                    lineColor = Colors.grey.shade300;
                    break;
                  default:
                    stepIndicator = Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    );
                    lineColor = Colors.grey.shade300;
                }
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        stepIndicator,
                        if (index < sortedTracking.length - 1)
                          Container(
                            width: 2,
                            height: 40,
                            color: lineColor,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.stopName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (trackingItem.arrivalTime != null)
                            Text(
                              'Arrived: ${DateFormat('hh:mm a').format(
                                DateTime.parse(trackingItem.arrivalTime!),
                              )}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          if (trackingItem.departureTime != null)
                            Text(
                              'Departed: ${DateFormat('hh:mm a').format(
                                DateTime.parse(trackingItem.departureTime!),
                              )}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      
      if (remainingMinutes == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $remainingMinutes min';
      }
    }
  }
}