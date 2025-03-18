import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/booking.dart';
import 'package:daladala_smart_app/providers/booking_provider.dart';
import 'package:daladala_smart_app/screens/payment/payment_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final int bookingId;
  
  const BookingConfirmationScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        centerTitle: false,
        automaticallyImplyLeading: false,
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
              // Success Icon
              const Center(
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 80,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              
              // Success Message
              Text(
                'Booking Successful!',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.marginSmall),
              Text(
                'Your booking has been confirmed with the following details:',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.marginLarge),
              
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
                      // Booking Info Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking #${booking.bookingId}',
                            style: AppTextStyles.heading3,
                          ),
                          _buildStatusChip(booking.status),
                        ],
                      ),
                      const Divider(),
                      
                      // Trip Details
                      if (booking.trip != null && booking.trip!.route != null) ...[
                        const Text(
                          'Trip Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSizes.marginSmall),
                        
                        _buildInfoRow(
                          'Route:',
                          '${booking.trip!.route!.routeNumber} - ${booking.trip!.route!.routeName}',
                        ),
                        
                        _buildInfoRow(
                          'Date:',
                          DateFormat('EEE, MMM d, yyyy').format(
                            DateTime.parse(booking.trip!.startTime),
                          ),
                        ),
                        
                        _buildInfoRow(
                          'Time:',
                          DateFormat('hh:mm a').format(
                            DateTime.parse(booking.trip!.startTime),
                          ),
                        ),
                        
                        if (booking.trip!.vehicle != null)
                          _buildInfoRow(
                            'Vehicle:',
                            '${booking.trip!.vehicle!.plateNumber} (${booking.trip!.vehicle!.vehicleType})',
                          ),
                          
                        const SizedBox(height: AppSizes.marginMedium),
                      ],
                      
                      // Journey Details
                      const Text(
                        'Journey Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSizes.marginSmall),
                      
                      _buildInfoRow(
                        'From:',
                        booking.pickupStop?.stopName ?? 'Unknown Pickup',
                      ),
                      
                      _buildInfoRow(
                        'To:',
                        booking.dropoffStop?.stopName ?? 'Unknown Destination',
                      ),
                      
                      const SizedBox(height: AppSizes.marginMedium),
                      
                      // Payment Details
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSizes.marginSmall),
                      
                      _buildInfoRow(
                        'Passengers:',
                        '${booking.passengerCount}',
                      ),
                      
                      _buildInfoRow(
                        'Fare Amount:',
                        '${booking.fareAmount.toStringAsFixed(0)} TZS',
                        valueColor: AppColors.primary,
                        valueFontWeight: FontWeight.bold,
                      ),
                      
                      _buildInfoRow(
                        'Payment Status:',
                        _formatPaymentStatus(booking.paymentStatus),
                        valueColor: _getPaymentStatusColor(booking.paymentStatus),
                        valueFontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.marginLarge),
              
              // Payment Button (if not paid)
              if (booking.paymentStatus == 'pending')
                ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('PROCEED TO PAYMENT'),
                ),
              
              // View Bookings Button
              const SizedBox(height: AppSizes.marginMedium),
              TextButton(
                onPressed: () {
                  // Navigate to bookings screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushNamed(context, '/bookings');
                },
                child: const Text('VIEW ALL BOOKINGS'),
              ),
              
              // Back to Home Button
              TextButton(
                onPressed: () {
                  // Navigate back to home screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('BACK TO HOME'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoRow(
    String label,
    String value, {
    Color valueColor = AppColors.textPrimary,
    FontWeight valueFontWeight = FontWeight.normal,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueFontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;
    
    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'confirmed':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        displayText = 'Confirmed';
        break;
      case 'in_progress':
        backgroundColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        displayText = 'In Progress';
        break;
      case 'completed':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        displayText = 'Cancelled';
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
  
  String _formatPaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Not Paid';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Payment Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
  
  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}