import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/booking.dart';
import 'package:daladala_smart_app/models/trip.dart';
import 'package:daladala_smart_app/providers/auth_provider.dart';
import 'package:daladala_smart_app/providers/booking_provider.dart';
import 'package:daladala_smart_app/providers/trip_provider.dart';
import 'package:daladala_smart_app/providers/user_provider.dart';
import 'package:daladala_smart_app/screens/bookings/booking_details_screen.dart';
import 'package:daladala_smart_app/screens/routes/route_search_screen.dart';
import 'package:daladala_smart_app/screens/trips/trip_detail_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';
import 'package:daladala_smart_app/widgets/trip/trip_card.dart';
import 'package:daladala_smart_app/widgets/booking/booking_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    await Future.wait([
      tripProvider.fetchUpcomingTrips(),
      bookingProvider.fetchBookings(),
    ]);
  }
  
  Future<void> _onRefresh() async {
    await _loadDashboardData();
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user ?? authProvider.currentUser;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar with Greeting and Profile
                _buildAppBar(user?.firstName ?? ''),
                
                // Main Content
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      _buildSearchBar(),
                      const SizedBox(height: AppSizes.marginLarge),
                      
                      // Active Bookings
                      _buildActiveBookings(),
                      const SizedBox(height: AppSizes.marginLarge),
                      
                      // Upcoming Trips
                      _buildUpcomingTrips(),
                      const SizedBox(height: AppSizes.marginLarge),
                      
                      // Quick Actions
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar(String firstName) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $firstName',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Where are you going today?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    final user = userProvider.user;
                    
                    if (user?.profilePicture != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          user!.profilePicture!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 30,
                            );
                          },
                        ),
                      );
                    }
                    
                    return const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 30,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RouteSearchScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.marginSmall),
            const Text(
              'Search routes, stops or destinations',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActiveBookings() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        if (bookingProvider.bookingsLoading) {
          return const Center(
            child: LoadingIndicator(size: 40),
          );
        }
        
        final activeBookings = bookingProvider.activeBookings;
        
        if (activeBookings.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Bookings',
                    style: AppTextStyles.heading3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/bookings');
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.marginSmall),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    child: Text(
                      'No active bookings',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Bookings',
                  style: AppTextStyles.heading3,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/bookings');
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.marginSmall),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeBookings.length > 2 ? 2 : activeBookings.length,
              itemBuilder: (context, index) {
                final booking = activeBookings[index];
                return BookingCard(
                  booking: booking,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsScreen(
                          bookingId: booking.bookingId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildUpcomingTrips() {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, _) {
        if (tripProvider.upcomingTripsLoading) {
          return const Center(
            child: LoadingIndicator(size: 40),
          );
        }
        
        final upcomingTrips = tripProvider.upcomingTrips;
        
        if (upcomingTrips.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Trips',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSizes.marginSmall),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    child: Text(
                      'No upcoming trips',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Trips',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.marginSmall),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: upcomingTrips.length,
                itemBuilder: (context, index) {
                  final trip = upcomingTrips[index];
                  return TripCard(
                    trip: trip,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripDetailScreen(
                            tripId: trip.tripId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSizes.marginSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(
              icon: Icons.map,
              label: 'Routes',
              onTap: () {
                Navigator.pushNamed(context, '/routes');
              },
            ),
            _buildActionItem(
              icon: Icons.history,
              label: 'History',
              onTap: () {
                Navigator.pushNamed(context, '/bookings');
              },
            ),
            _buildActionItem(
              icon: Icons.payments,
              label: 'Payments',
              onTap: () {
                Navigator.pushNamed(context, '/payments');
              },
            ),
            _buildActionItem(
              icon: Icons.help,
              label: 'Help',
              onTap: () {
                Navigator.pushNamed(context, '/help');
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}