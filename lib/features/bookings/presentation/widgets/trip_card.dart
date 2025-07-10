
import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onTap;

  const TripCard({
    Key? key,
    required this.trip,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with route and time
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip['route_name'] ?? 'Unknown Route',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trip['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Departure time and vehicle info
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Departure: ${_formatTime(trip['start_time'])}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.directions_bus, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Vehicle: ${trip['vehicle_plate'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Capacity and pricing
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.airline_seat_recline_normal, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${trip['available_seats'] ?? 0} seats available',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (trip['base_fare'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        'TSh ${trip['base_fare']}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Driver info if available
              if (trip['driver_name'] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Driver: ${trip['driver_name']}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (trip['driver_rating'] != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        ' ${trip['driver_rating'].toStringAsFixed(1)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Select Trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
}