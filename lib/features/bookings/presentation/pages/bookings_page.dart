import 'package:daladala_smart_app/features/bookings/domain/entities/booking.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/loading_indicator.dart';
import '../../../../core/ui/widgets/empty_state.dart';
import '../../../../core/ui/widgets/error_view.dart';
import '../providers/booking_provider.dart';
import 'booking_detail_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;
  String _selectedFilter = 'all';
  
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _loadBookings();
      _isInitialized = true;
    }
  }
  
  Future<void> _loadBookings() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.getUserBookings();
  }
  
  Future<void> _refreshBookings() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.getUserBookings(
      status: _selectedFilter == 'all' ? null : _selectedFilter,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
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
                  _buildFilterTab('all', 'All'),
                  _buildFilterTab('pending', 'Pending'),
                  _buildFilterTab('confirmed', 'Confirmed'),
                  _buildFilterTab('in_progress', 'In Progress'),
                  _buildFilterTab('completed', 'Completed'),
                  _buildFilterTab('cancelled', 'Cancelled'),
                ],
              ),
            ),
          ),
          
          // Booking list
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                if (bookingProvider.isLoading) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                }
                
                if (bookingProvider.error != null) {
                  return GenericErrorView(
                    message: bookingProvider.error,
                    onRetry: _refreshBookings,
                  );
                }
                
                final bookings = bookingProvider.bookings;
                
                if (bookings == null || bookings.isEmpty) {
                  return EmptyState(
                    title: 'No Bookings Found',
                    message: _selectedFilter == 'all'
                        ? 'You don\'t have any bookings yet.'
                        : 'You don\'t have any ${_selectedFilter.replaceAll('_', ' ')} bookings.',
                    lottieAsset: 'assets/animations/empty_bookings.json',
                    buttonText: 'Book a Trip',
                    onButtonPressed: () {
                      // Navigate to route search or home
                      Navigator.pop(context);
                    },
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: _refreshBookings,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _BookingCard(
                        booking: booking,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDetailPage(bookingId: booking.id),
                            ),
                          );
                        },
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
  
  Widget _buildFilterTab(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
          // Reload bookings with filter
          final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
          bookingProvider.getUserBookings(
            status: filter == 'all' ? null : filter,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingCard({
    Key? key,
    required this.booking,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(booking.bookingTime);
    
    // Define status color
    Color statusColor;
    IconData statusIcon;
    
    switch (booking.status) {
      case 'pending':
        statusColor = AppTheme.pendingColor;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'confirmed':
        statusColor = AppTheme.confirmedColor;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'in_progress':
        statusColor = AppTheme.inProgressColor;
        statusIcon = Icons.directions_bus;
        break;
      case 'completed':
        statusColor = AppTheme.completedColor;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = AppTheme.cancelledColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.pendingColor;
        statusIcon = Icons.hourglass_empty;
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
            // Booking header with status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    statusIcon,
                    size: 18,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Booking #${booking.id}',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Booking details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Trip info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From/To
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // This would normally come from the trip details
                            // Here we're just displaying the stop IDs as placeholders
                            Text(
                              'From: Stop #${booking.pickupStopId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'To: Stop #${booking.dropoffStopId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Passenger count and fare
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${booking.passengerCount} ${booking.passengerCount > 1 ? 'Passengers' : 'Passenger'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TZS ${booking.fareAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Payment status and view button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: booking.paymentStatus == 'paid'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.paymentStatus.toUpperCase(),
                          style: TextStyle(
                            color: booking.paymentStatus == 'paid'
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
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
}