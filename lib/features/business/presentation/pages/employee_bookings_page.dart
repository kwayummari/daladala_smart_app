import 'package:flutter/material.dart';

class EmployeeBookingsPage extends StatefulWidget {
  const EmployeeBookingsPage({Key? key}) : super(key: key);

  @override
  State<EmployeeBookingsPage> createState() => _EmployeeBookingsPageState();
}

class _EmployeeBookingsPageState extends State<EmployeeBookingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Bookings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Employee Bookings Page\n(Under Development)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
