import 'package:flutter/material.dart';

class BookingSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> trip;
  final List<String> selectedSeats;
  final int passengerCount;
  final VoidCallback? onContinue;

  const BookingSummaryWidget({
    Key? key,
    required this.trip,
    required this.selectedSeats,
    required this.passengerCount,
    this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fareAmount = _calculateFare();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Passengers:'),
              Text('$passengerCount'),
            ],
          ),
          
          if (selectedSeats.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Selected Seats:'),
                Text(selectedSeats.join(', ')),
              ],
            ),
          ],
          
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fare per person:'),
              Text('TSh ${fareAmount.toStringAsFixed(0)}'),
            ],
          ),
          
          const Divider(),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'TSh ${(fareAmount * passengerCount).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue to Payment'),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateFare() {
    // Use fare from trip data or default calculation
    if (trip['fare_amount'] != null) {
      return double.tryParse(trip['fare_amount'].toString()) ?? 2000.0;
    }
    return 2000.0; // Default fare
  }
}