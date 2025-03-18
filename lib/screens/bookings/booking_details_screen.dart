import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/booking.dart';
import 'package:daladala_smart_app/providers/booking_provider.dart';
import 'package:daladala_smart_app/providers/payment_provider.dart';
import 'package:daladala_smart_app/screens/payment/payment_screen.dart';
import 'package:daladala_smart_app/screens/trips/trip_detail_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class BookingDetailsScreen extends StatefulWidget {
  final int bookingId;
  
  const BookingDetailsScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }
  
  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.fetchBookingDetails(widget.bookingId);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load booking details: ${e.toString()}';
      });
    }
  }
  
  Future<void> _cancelBooking() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              
              try {
                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                final success = await bookingProvider.cancelBooking(widget.bookingId);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  
                  await _loadBookingDetails();
                } else {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = bookingProvider.processingError;
                  });
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Failed to cancel booking: ${e.toString()}';
                });
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('YES, CANCEL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _buildContent(),
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
                onPressed: _loadBookingDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        final booking = bookingProvider.currentBooking;
        
        if (booking == null) {
          return const Center(
            child: Text('Booking not found'),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Booking Status Header
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStatusIcon(booking.status),
                          color: _getStatusColor(booking.status),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatStatus(booking.status),
                          style: TextStyle(
                            color: _getStatusColor(booking.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusDescription(booking.status),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              
              // Booking Details Card
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
                      // Booking ID and Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking #${booking.bookingId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(
                              DateTime.parse(booking.bookingTime),
                            ),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booked on ${DateFormat('hh:mm a').format(
                          DateTime.parse(booking.bookingTime),
                        )}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Divider(height: 24),
                      
                      // Trip Details
                      if (booking.trip != null && booking.trip!.route != null) ...[
                        const Text(
                          'Trip Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Route info
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_bus_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${booking.trip!.route!.routeNumber} - ${booking.trip!.route!.routeName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripDetailScreen(
                                      tripId: booking.trip!.tripId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Trip Details'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Trip time
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${DateFormat('EEE, MMM d').format(DateTime.parse(booking.trip!.startTime))} at ${DateFormat('hh:mm a').format(DateTime.parse(booking.trip!.startTime))}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Vehicle info if available
                        if (booking.trip!.vehicle != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${booking.trip!.vehicle!.plateNumber} (${booking.trip!.vehicle!.vehicleType})',
                              ),
                            ],
                          ),
                          
                        const Divider(height: 24),
                      ],
                      
                      // Journey Details
                      const Text(
                        'Journey Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Pickup and Dropoff
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
                                  booking.pickupStop?.stopName ?? 'Unknown Pickup',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  booking.dropoffStop?.stopName ?? 'Unknown Destination',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Passenger Info
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${booking.passengerCount} ${booking.passengerCount > 1 ? 'passengers' : 'passenger'}',
                          ),
                        ],
                      ),
                      
                      const Divider(height: 24),
                      
                      // Payment Details
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Fare Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fare Amount:'),
                          Text(
                            '${booking.fareAmount.toStringAsFixed(0)} TZS',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Payment Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Status:'),
                          _buildPaymentStatusChip(booking.paymentStatus),
                        ],
                      ),
                      
                      // Payment Button if not paid
                      if (booking.isPaymentPending && (booking.isPending || booking.isConfirmed)) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                    bookingId: booking.bookingId,
                                  ),
                                ),
                              );
                            },
                            child: const Text('PROCEED TO PAYMENT'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              
              // Actions
              if (booking.isPending || booking.isConfirmed)
                ElevatedButton(
                  onPressed: _cancelBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('CANCEL BOOKING'),
                ),
                
              const SizedBox(height: AppSizes.marginMedium),
            ],
          ),
        );
      },
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.directions_bus;
      case 'completed':
        return Icons.flag;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }
  
  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Confirmation';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }
  
  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'Your booking is waiting for confirmation from the system.';
      case 'confirmed':
        return 'Your booking has been confirmed. You can proceed with payment if not already paid.';
      case 'in_progress':
        return 'Your trip is currently in progress.';
      case 'completed':
        return 'Your trip has been completed successfully.';
      case 'cancelled':
        return 'This booking has been cancelled.';
      default:
        return '';
    }
  }
  
  Widget _buildPaymentStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;
    
    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        displayText = 'Not Paid';
        break;
      case 'paid':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        displayText = 'Paid';
        break;
      case 'failed':
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        displayText = 'Failed';
        break;
      case 'refunded':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        displayText = 'Refunded';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        displayText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}