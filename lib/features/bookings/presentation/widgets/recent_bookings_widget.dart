
import 'package:flutter/material.dart';

class RecentBookingsWidget extends StatelessWidget {
  final List<dynamic> bookings;
  final bool isLoading;

  const RecentBookingsWidget({
    Key? key,
    required this.bookings,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  'Recent Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to all bookings page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (bookings.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recent bookings',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length > 5 ? 5 : bookings.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _buildBookingItem(booking);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(booking['approval_status']),
        child: Icon(
          _getStatusIcon(booking['approval_status']),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        booking['employee_name'] ?? 'Unknown Employee',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${booking['trip_info']?['pickup_stop'] ?? 'N/A'} → ${booking['trip_info']?['dropoff_stop'] ?? 'N/A'}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            'Departure: ${_formatDateTime(booking['trip_info']?['departure_time'])}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'TSh ${booking['fare_amount'] ?? '0'}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(booking['approval_status']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getStatusDisplayName(booking['approval_status']),
              style: TextStyle(
                color: _getStatusColor(booking['approval_status']),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'approved':
        return Icons.check;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.help;
    }
  }

  String _getStatusDisplayName(String? status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
}