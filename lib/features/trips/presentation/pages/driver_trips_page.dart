// lib/features/trips/presentation/pages/driver_trips_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/loading_indicator.dart';
import '../../../../core/ui/widgets/empty_state.dart';
import '../../../../core/ui/widgets/error_view.dart';
import '../providers/trip_provider.dart';
import 'trip_detail_page.dart';

class DriverTripsPage extends StatefulWidget {
  const DriverTripsPage({Key? key}) : super(key: key);

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage>
    with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;
  String _selectedFilter = 'all';

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDriverTrips();
      });
      _isInitialized = true;
    }
  }

  Future<void> _loadDriverTrips() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.loadDriverTrips();
  }

  Future<void> _refreshTrips() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.loadDriverTrips();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Trips'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshTrips),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: Consumer<TripProvider>(
              builder: (context, tripProvider, child) {
                if (tripProvider.isLoading) {
                  return const Center(child: LoadingIndicator());
                }

                if (tripProvider.error != null) {
                  return ErrorView(
                    message: tripProvider.error!,
                    onRetry: _refreshTrips,
                  );
                }

                final trips = _filterTrips(tripProvider.driverTrips);

                if (trips.isEmpty) {
                  return EmptyState(
                    title: 'No Trips Found',
                    message: _getEmptyStateMessage(),
                    // icon: Icons.directions_bus,
                    // actionText: 'Refresh',
                    // onAction: _refreshTrips,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshTrips,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return _DriverTripCard(
                        trip: trip,
                        onTap: () => _navigateToTripDetail(trip),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('scheduled', 'Scheduled'),
            const SizedBox(width: 8),
            _buildFilterChip('in_progress', 'In Progress'),
            const SizedBox(width: 8),
            _buildFilterChip('completed', 'Completed'),
            const SizedBox(width: 8),
            _buildFilterChip('cancelled', 'Cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<dynamic> _filterTrips(List<dynamic> trips) {
    if (_selectedFilter == 'all') return trips;
    return trips.where((trip) => trip['status'] == _selectedFilter).toList();
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'scheduled':
        return 'No scheduled trips at the moment.';
      case 'in_progress':
        return 'No trips are currently in progress.';
      case 'completed':
        return 'No completed trips found.';
      case 'cancelled':
        return 'No cancelled trips found.';
      default:
        return 'Your assigned trips will appear here.';
    }
  }

  void _navigateToTripDetail(Map<String, dynamic> trip) {
    // For now, we'll show trip details in a dialog
    // You can implement a proper TripDetailPage later
    showDialog(
      context: context,
      builder: (context) => _TripDetailDialog(trip: trip),
    );
  }
}

class _DriverTripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onTap;

  const _DriverTripCard({Key? key, required this.trip, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract trip data safely
    final tripId = trip['trip_id'] ?? 0;
    final status = trip['status'] ?? 'unknown';
    final startTime = trip['start_time'];
    final endTime = trip['end_time'];
    final route = trip['Route'] ?? {};
    final vehicle = trip['Vehicle'] ?? {};
    final routeName = route['route_name'] ?? 'Unknown Route';
    final routeNumber = route['route_number'] ?? 'N/A';
    final vehiclePlate = vehicle['plate_number'] ?? 'Unknown';
    final passengerCount = trip['passenger_count'] ?? 0;

    // Format dates
    String formattedDate = 'N/A';
    String formattedTime = 'N/A';
    if (startTime != null) {
      try {
        final dateTime = DateTime.parse(startTime);
        formattedDate = DateFormat('EEE, d MMM').format(dateTime);
        formattedTime = DateFormat('HH:mm').format(dateTime);
      } catch (e) {
        // Keep default values if parsing fails
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Trip header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Route $routeNumber • $vehiclePlate',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
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
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Trip details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$formattedDate at $formattedTime',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$passengerCount passengers',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Trip #$tripId',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppTheme.confirmedColor;
      case 'in_progress':
        return AppTheme.inProgressColor;
      case 'completed':
        return AppTheme.completedColor;
      case 'cancelled':
        return AppTheme.cancelledColor;
      default:
        return AppTheme.pendingColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}

class _TripDetailDialog extends StatelessWidget {
  final Map<String, dynamic> trip;

  const _TripDetailDialog({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final route = trip['Route'] ?? {};
    final vehicle = trip['Vehicle'] ?? {};
    final status = trip['status'] ?? 'unknown';
    final tripId = trip['trip_id'] ?? 0;

    return AlertDialog(
      title: Text('Trip #$tripId Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Route', route['route_name'] ?? 'Unknown'),
          _buildDetailRow('Vehicle', vehicle['plate_number'] ?? 'Unknown'),
          _buildDetailRow('Status', status.toUpperCase()),
          _buildDetailRow('Start Time', trip['start_time'] ?? 'N/A'),
          if (trip['end_time'] != null)
            _buildDetailRow('End Time', trip['end_time']),
          _buildDetailRow('Passengers', '${trip['passenger_count'] ?? 0}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (status.toLowerCase() == 'scheduled')
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTrip(context, tripId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Start Trip'),
          ),
        if (status.toLowerCase() == 'in_progress')
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endTrip(context, tripId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.completedColor,
            ),
            child: const Text('End Trip'),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _startTrip(BuildContext context, int tripId) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final success = await tripProvider.startTrip(tripId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip started successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripProvider.error ?? 'Failed to start trip'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _endTrip(BuildContext context, int tripId) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final success = await tripProvider.endTrip(tripId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip ended successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripProvider.error ?? 'Failed to end trip'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
