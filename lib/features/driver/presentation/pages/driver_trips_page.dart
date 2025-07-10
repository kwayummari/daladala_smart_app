import 'package:flutter/material.dart';

Widget TripDetailsPage({required Map<String, dynamic> trip}) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Trip Details'),
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip ID: ${trip['trip_id']}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Route: ${trip['route_name'] ?? 'Unknown'}'),
          Text('Status: ${trip['status'] ?? 'Unknown'}'),
          Text('Start Time: ${trip['start_time'] ?? 'Unknown'}'),
          // Add more trip details as needed
        ],
      ),
    ),
  );
}
