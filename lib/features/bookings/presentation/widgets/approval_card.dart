import 'package:flutter/material.dart';

class ApprovalCard extends StatelessWidget {
  final Map<String, dynamic> approval;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalCard({
    Key? key,
    required this.approval,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    approval['employee_name'] ?? 'Unknown Employee',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(approval['urgency']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    approval['urgency']?.toString().toUpperCase() ?? 'NORMAL',
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

            // Employee Details
            if (approval['employee_id'] != null) ...[
              Text(
                'Employee ID: ${approval['employee_id']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            if (approval['department'] != null) ...[
              Text(
                'Department: ${approval['department']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],

            const SizedBox(height: 12),

            // Trip Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    approval['trip_details']['route_name'] ?? 'Unknown Route',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${approval['trip_details']['pickup_stop']} → ${approval['trip_details']['dropoff_stop']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Departure: ${_formatDateTime(approval['trip_details']['departure_time'])}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Passengers: ${approval['passenger_count']} | Fare: TSh ${approval['fare_amount']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Requested At
            Text(
              'Requested: ${_formatDateTime(approval['requested_at'])}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(String? urgency) {
    switch (urgency) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
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
