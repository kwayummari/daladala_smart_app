import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';

class PassengerListWidget extends StatelessWidget {
  final int tripId;
  final List<dynamic> passengers;

  const PassengerListWidget({
    Key? key,
    required this.tripId,
    required this.passengers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                const Text(
                  'Passengers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${passengers.length} passengers',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                passengers.isEmpty
                    ? const Center(
                      child: Text(
                        'No passengers for this trip',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: passengers.length,
                      itemBuilder: (context, index) {
                        final passenger = passengers[index];
                        return _buildPassengerTile(context, passenger);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerTile(
    BuildContext context,
    Map<String, dynamic> passenger,
  ) {
    final isBoarded = passenger['is_boarded'] ?? false;
    final hasAlighted = passenger['has_alighted'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPassengerStatusColor(isBoarded, hasAlighted),
          child: Icon(
            _getPassengerStatusIcon(isBoarded, hasAlighted),
            color: Colors.white,
          ),
        ),
        title: Text(
          passenger['passenger_name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${passenger['pickup_stop']} → ${passenger['dropoff_stop']}'),
            Text('Seat: ${passenger['seat_numbers'] ?? 'N/A'}'),
            Text('Phone: ${passenger['passenger_phone'] ?? 'N/A'}'),
          ],
        ),
        trailing: _buildPassengerActions(context, passenger),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildPassengerActions(
    BuildContext context,
    Map<String, dynamic> passenger,
  ) {
    final isBoarded = passenger['is_boarded'] ?? false;
    final hasAlighted = passenger['has_alighted'] ?? false;
    final seatId = passenger['seat_id'];

    if (hasAlighted) {
      return const Chip(
        label: Text('Alighted'),
        backgroundColor: Colors.blue,
        labelStyle: TextStyle(color: Colors.white),
      );
    }

    if (isBoarded) {
      return ElevatedButton(
        onPressed: () => _markPassengerAlighted(context, seatId),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        child: const Text('Alight', style: TextStyle(fontSize: 12)),
      );
    }

    return ElevatedButton(
      onPressed: () => _markPassengerBoarded(context, seatId),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Text('Board', style: TextStyle(fontSize: 12)),
    );
  }

  Color _getPassengerStatusColor(bool isBoarded, bool hasAlighted) {
    if (hasAlighted) return Colors.blue;
    if (isBoarded) return Colors.orange;
    return Colors.grey;
  }

  IconData _getPassengerStatusIcon(bool isBoarded, bool hasAlighted) {
    if (hasAlighted) return Icons.check_circle;
    if (isBoarded) return Icons.person;
    return Icons.person_outline;
  }

  void _markPassengerBoarded(BuildContext context, int seatId) {
    context.read<TripProvider>().markPassengerBoarded(tripId, seatId);
  }

  void _markPassengerAlighted(BuildContext context, int seatId) {
    context.read<TripProvider>().markPassengerAlighted(tripId, seatId);
  }
}
