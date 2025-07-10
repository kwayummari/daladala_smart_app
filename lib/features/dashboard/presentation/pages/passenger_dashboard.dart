
import 'package:daladala_smart_app/features/bookings/presentation/pages/search_trips_page.dart';
import 'package:daladala_smart_app/features/dashboard/presentation/widgets/passenger_bottom_nav.dart';
import 'package:daladala_smart_app/features/passenger/presentation/pages/my_bookings_page.dart';
import 'package:daladala_smart_app/features/passenger/presentation/pages/on_demand_page.dart';
import 'package:daladala_smart_app/features/passenger/presentation/pages/passenger_profile_page.dart';
import 'package:daladala_smart_app/features/passenger/presentation/pages/pre_bookings_page.dart';
import 'package:flutter/material.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({Key? key}) : super(key: key);

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SearchTripsPage(),
    const MyBookingsPage(),
    const PreBookingsPage(),
    const OnDemandPage(),
    const PassengerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: PassengerBottomNav(
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