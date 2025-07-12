// lib/features/home/presentation/pages/home_page.dart
import 'package:daladala_smart_app/features/bookings/presentation/pages/business_overview_page.dart';
import 'package:daladala_smart_app/features/bookings/presentation/pages/pending_approvals_page.dart';
import 'package:daladala_smart_app/features/bookings/presentation/pages/search_trips_page.dart';
import 'package:daladala_smart_app/features/business/presentation/pages/business_profile_page.dart';
import 'package:daladala_smart_app/features/business/presentation/pages/business_reports_page.dart';
import 'package:daladala_smart_app/features/business/presentation/pages/employee_bookings_page.dart';
import 'package:daladala_smart_app/features/driver/presentation/pages/driver_profile_page.dart';
import 'package:daladala_smart_app/features/passenger/presentation/pages/my_bookings_page.dart';
import 'package:daladala_smart_app/features/passenger/presentation/pages/on_demand_page.dart';
import 'package:daladala_smart_app/features/passenger/presentation/pages/pre_bookings_page.dart';
import 'package:daladala_smart_app/features/profile/presentation/pages/profile_page.dart';
import 'package:daladala_smart_app/features/qr/presentation/pages/location_tracking_page.dart';
import 'package:daladala_smart_app/features/trips/presentation/pages/driver_trips_page.dart';
import 'package:daladala_smart_app/features/trips/presentation/pages/live_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../../routes/presentation/providers/route_provider.dart';

class HomePage extends StatefulWidget {
  static final GlobalKey<_HomePageState> homeKey = GlobalKey<_HomePageState>();

  HomePage({Key? key}) : super(key: homeKey);

  static void navigateToRoutes() {
    homeKey.currentState?.navigateToTab(1);
  }

  static void navigateToTab(int index) {
    homeKey.currentState?.navigateToTab(index);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  GoogleMapController? _mapController;
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    _mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final tripProvider = context.read<TripProvider>();
    final routeProvider = context.read<RouteProvider>();

    await Future.wait([
      tripProvider.getUpcomingTrips(),
      routeProvider.getAllRoutes(),
    ]);
  }

  // Future<void> _refreshData() async {
  //   _refreshAnimationController.repeat();
  //   try {
  //     await _initializeData();
  //   } finally {
  //     _refreshAnimationController.stop();
  //     _refreshAnimationController.reset();
  //   }
  // }

  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Get navigation items based on user role
  List<BottomNavigationBarItem> _getNavigationItems(String userRole) {
    switch (userRole) {
      case 'driver':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Passengers',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      case 'operator':
      case 'admin':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Fleet',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Drivers'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      case 'business':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Employees'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      default: // passenger
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Routes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
    }
  }

  // Get pages based on user role
  List<Widget> _getPages(String userRole) {
    switch (userRole) {
      case 'driver':
        return [
          const DriverTripsPage(),
          const LocationTrackingPage(),
          const LiveTripPage(),
          const ProfilePage(),
        ];
      // case 'operator':
      // case 'admin':
      //   return [
      //     _buildOperatorDashboard(),
      //     _buildFleetManagement(),
      //     _buildDriverManagement(),
      //     _buildReports(),
      //     const ProfilePage(),
      //   ];
      case 'business':
        return [
          const BusinessOverviewPage(),
          const EmployeeBookingsPage(),
          const PendingApprovalsPage(),
          const BusinessReportsPage(),
          const BusinessProfilePage(),
          const ProfilePage(),
        ];
      default: // passenger
        return [
          const SearchTripsPage(),
          const MyBookingsPage(),
          const PreBookingsPage(),
          const OnDemandPage(),
          const ProfilePage(),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userRole = user.role;
        final navigationItems = _getNavigationItems(userRole);
        final pages = _getPages(userRole);

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: navigateToTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: navigationItems,
          ),
        );
      },
    );
  }
}
