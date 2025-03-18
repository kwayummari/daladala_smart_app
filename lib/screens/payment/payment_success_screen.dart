import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/booking.dart';
import 'package:daladala_smart_app/providers/booking_provider.dart';
import 'package:daladala_smart_app/providers/payment_provider.dart';
import 'package:daladala_smart_app/screens/booking/booking_details_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final int bookingId;
  
  const PaymentSuccessScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      
      // Load booking and payment details
      await bookingProvider.fetchBookingDetails(widget.bookingId);
      await paymentProvider.getPaymentForBooking(widget.bookingId);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load payment details: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
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
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Consumer2<BookingProvider, PaymentProvider>(
      builder: (context, bookingProvider, paymentProvider, _) {
        final booking = bookingProvider.currentBooking;
        final payment = paymentProvider.currentPayment;
        
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
              // Success Icon and Message
              const Center(
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 80,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Text(
                'Payment Successful!',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.marginSmall),
              Text(
                'Your payment has been processed successfully.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.marginLarge),
              
              // Payment Receipt Card
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
                      // Receipt Header
                      const Center(
                        child: Text(
                          'PAYMENT RECEIPT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.marginSmall),
                      Center(
                        child: Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Divider(height: 32),
                      
                      // Payment Details
                      _buildInfoRow(
                        'Amount Paid:',
                        '${booking.fareAmount.toStringAsFixed(0)} TZS',
                        valueColor: AppColors.primary,
                        valueFontWeight: FontWeight.bold,
                        valueFontSize: 18,
                      ),
                      
                      if (payment != null) ...[
                        _buildInfoRow(
                          'Payment ID:',
                          '#${payment.paymentId}',
                        ),
                        
                        _buildInfoRow(
                          'Payment Method:',
                          _formatPaymentMethod(payment.paymentMethod),
                        ),
                        
                        if (payment.transactionId != null)
                          _buildInfoRow(
                            'Transaction ID:',
                            payment.transactionId!,
                          ),
                          
                        _buildInfoRow(
                          'Payment Time:',
                          DateFormat('dd MMM yyyy, hh:mm a').format(
                            DateTime.parse(payment.paymentTime),
                          ),
                        ),
                      ],
                      
                      const Divider(height: 32),
                      
                      // Booking Details
                      _buildInfoRow(
                        'Booking ID:',
                        '#${booking.bookingId}',
                      ),
                      
                      if (booking.trip != null && booking.trip!.route != null)
                        _buildInfoRow(
                          'Route:',
                          '${booking.trip!.route!.routeNumber} - ${booking.trip!.route!.routeName}',
                        ),
                        
                      if (booking.pickupStop != null && booking.dropoffStop != null)
                        _buildInfoRow(
                          'Journey:',
                          '${booking.pickupStop!.stopName} to ${booking.dropoffStop!.stopName}',
                        ),
                        
                      _buildInfoRow(
                        'Passengers:',
                        '${booking.passengerCount}',
                      ),
                      
                      if (booking.trip != null)
                        _buildInfoRow(
                          'Trip Time:',
                          DateFormat('dd MMM yyyy, hh:mm a').format(
                            DateTime.parse(booking.trip!.startTime),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.marginLarge),
              
              // Actions
              const Text(
                'Keep this receipt for your records. You may need to show it to the driver before boarding.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.marginLarge),
              
              // View Booking Details Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailsScreen(
                        bookingId: booking.bookingId,
                      ),
                    ),
                  );
                },
                child: const Text('VIEW BOOKING DETAILS'),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              
              // Back to Home Button
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                ),
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
    double valueFontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueFontWeight,
                fontSize: valueFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'mobile_money':
        return 'Mobile Money';
      case 'cash':
        return 'Cash';
      case 'wallet':
        return 'Wallet';
      case 'card':
        return 'Card';
      default:
        return method.replaceAll('_', ' ').toUpperCase();
    }
  }
}