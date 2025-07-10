import 'package:flutter/material.dart';

class BusinessReportsPage extends StatefulWidget {
  const BusinessReportsPage({Key? key}) : super(key: key);

  @override
  State<BusinessReportsPage> createState() => _BusinessReportsPageState();
}

class _BusinessReportsPageState extends State<BusinessReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Reports'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Business Reports Page\n(Under Development)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
