import 'package:flutter/material.dart';

class PreBookingsPage extends StatefulWidget {
  const PreBookingsPage({Key? key}) : super(key: key);

  @override
  State<PreBookingsPage> createState() => _PreBookingsPageState();
}

class _PreBookingsPageState extends State<PreBookingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Bookings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Pre-Bookings Page\n(Under Development)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
