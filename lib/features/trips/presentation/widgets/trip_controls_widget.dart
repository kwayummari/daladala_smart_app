
// lib/features/trip/presentation/widgets/trip_controls_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';

class TripControlsWidget extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripControlsWidget({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final status = trip['status'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (status == 'scheduled') ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: tripProvider.isLoading
                    ? null
                    : () => _startTrip(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          if (status == 'in_progress') ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: tripProvider.isLoading
                    ? null
                    : () => _endTrip(context),
                icon: const Icon(Icons.stop),
                label: const Text('End Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          if (status == 'completed') ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Trip Completed',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startTrip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Trip'),
        content: const Text('Are you ready to start this trip? This will notify all passengers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TripProvider>().startTrip(trip['trip_id']);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _endTrip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Trip'),
        content: const Text('Are you sure you want to end this trip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TripProvider>().endTrip(trip['trip_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
  }
}