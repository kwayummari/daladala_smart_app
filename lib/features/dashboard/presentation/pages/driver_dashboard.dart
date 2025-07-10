
import 'package:daladala_smart_app/features/dashboard/presentation/widgets/driver_bottom_nav.dart';
import 'package:daladala_smart_app/features/qr/presentation/pages/location_tracking_page.dart';
import 'package:daladala_smart_app/features/trips/presentation/pages/driver_trips_page.dart';
import 'package:daladala_smart_app/features/trips/presentation/pages/live_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DriverTripsPage(),
    const LocationTrackingPage(),
    const LiveTripPage(),
    const DriverProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: DriverBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
