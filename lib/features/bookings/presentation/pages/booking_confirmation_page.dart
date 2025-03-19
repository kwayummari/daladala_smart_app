import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/utils/extensions.dart';
import '../../../payments/presentation/pages/payment_page.dart';

class BookingConfirmationPage extends StatefulWidget {
  final int tripId;
  final String routeName;
  final String from;
  final String to;
  final DateTime startTime;
  final double fare;
  final String vehiclePlate;

  const BookingConfirmationPage({
    Key? key,
    required this.tripId,
    required this.routeName,
    required this.from,
    required this.to,
    required this.startTime,
    required this.fare,
    required this.vehiclePlate,
  }) : super(key: key);

  @override
  State<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  int _passengerCount = 1;
  bool _isLoading = false;
  
  double get _totalFare => widget.fare * _passengerCount;
  
  void _incrementPassengers() {
    setState(() {
      if (_passengerCount < 5) {
        _passengerCount++;
      }
    });
  }
  
  void _decrementPassengers() {
    setState(() {
      if (_passengerCount > 1) {
        _passengerCount--;
      }
    });
  }
  
  Future<void> _confirmBooking() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentPage(
            bookingId: 123, // This would be returned from the API
            amount: _totalFare,
            tripId: widget.tripId,
            routeName: widget.routeName,
            from: widget.from,
            to: widget.to,
            startTime: widget.startTime,
            passengerCount: _passengerCount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(widget.startTime);
    final formattedTime = DateFormat('HH:mm').format(widget.startTime);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip details card
            Container(
              padding: const EdgeInsets.all(16),
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
                  // Route name
                  Text(
                    widget.routeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // From/To
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              widget.from,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.to,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Date and time
                  _DetailItem(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    value: formattedDate,
                  ),
                  const SizedBox(height: 16),
                  _DetailItem(
                    icon: Icons.access_time,
                    title: 'Departure Time',
                    value: formattedTime,
                  ),
                  const SizedBox(height: 16),
                  _DetailItem(
                    icon: Icons.directions_bus,
                    title: 'Vehicle',
                    value: widget.vehiclePlate,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Passenger count
            Container(
              padding: const EdgeInsets.all(16),
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
                  const Text(
                    'Number of Passengers',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _decrementPassengers,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.remove,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _passengerCount.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementPassengers,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Fare details
            Container(
              padding: const EdgeInsets.all(16),
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
                  const Text(
                    'Fare Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Base Fare'),
                      Text(widget.fare.toPrice),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Passengers'),
                      Text('× $_passengerCount'),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _totalFare.toPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontSize: 18,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Confirm & Pay',
          onPressed: _confirmBooking,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}