import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/route.dart' as app_route;
import 'package:daladala_smart_app/models/trip.dart';
import 'package:daladala_smart_app/providers/trip_provider.dart';
import 'package:daladala_smart_app/screens/bookings/new_booking_screen.dart';
import 'package:daladala_smart_app/screens/trips/trip_detail_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';
import 'package:daladala_smart_app/widgets/trip/trip_card.dart';

class RouteDetailScreen extends StatefulWidget {
  final int routeId;
  
  const RouteDetailScreen({
    Key? key,
    required this.routeId,
  }) : super(key: key);

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRouteDetails();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRouteDetails() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.selectRoute(widget.routeId);
    await tripProvider.fetchUpcomingTrips(routeId: widget.routeId);
  }
  
  Future<void> _onRefresh() async {
    await _loadRouteDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          if (tripProvider.routeDetailsLoading) {
            return const Center(child: LoadingIndicator());
          }
          
          if (tripProvider.routeDetailsError.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  Text(
                    'Error: ${tripProvider.routeDetailsError}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final route = tripProvider.selectedRoute;
          if (route == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.route,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  const Text(
                    'Route not found',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Route ${route.routeNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: AppColors.primary,
                        ),
                        Positioned(
                          bottom: 60,
                          left: 16,
                          right: 16,
                          child: Text(
                            route.routeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildRouteHeader(route),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'DETAILS'),
                        Tab(text: 'STOPS'),
                        Tab(text: 'TRIPS'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Details Tab
                _buildDetailsTab(route),
                
                // Stops Tab
                _buildStopsTab(tripProvider.routeStops),
                
                // Trips Tab
                _buildTripsTab(tripProvider.upcomingTrips),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewBookingScreen(
                routeId: widget.routeId,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Trip'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
  
  Widget _buildRouteHeader(app_route.Route route) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Path with Start and End Points
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(
                    Icons.circle,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  Container(
                    height: 30,
                    width: 2,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const Icon(
                    Icons.location_on,
                    color: AppColors.error,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.startPoint,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      route.endPoint,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.marginMedium),
          
          // Route Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.straighten,
                label: 'Distance',
                value: route.distanceKm != null
                    ? '${route.distanceKm!.toStringAsFixed(1)} km'
                    : 'N/A',
              ),
              _buildStatItem(
                icon: Icons.timer,
                label: 'Duration',
                value: route.estimatedTimeMinutes != null
                    ? _formatDuration(route.estimatedTimeMinutes!)
                    : 'N/A',
              ),
              _buildStatItem(
                icon: Icons.location_on,
                label: 'Stops',
                value: '${route.routeStops?.length ?? 0}',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailsTab(app_route.Route route) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          // Route Description
          const Text(
            'Description',
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
            child: Text(
              route.description ?? 'No description available for this route.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSizes.marginLarge),
          
          // Route Fares
          const Text(
            'Fares',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Standard Fares:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Full Route: TZS 1,500 - 2,000'),
                const Text('Partial Routes: TZS 1,000 - 1,500'),
                const SizedBox(height: 12),
                const Text(
                  'Student Fares:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Full Route: TZS 1,000 - 1,500'),
                const Text('Partial Routes: TZS 700 - 1,000'),
                const SizedBox(height: 12),
                const Text(
                  'Note: Fares may vary based on specific stops and time of day.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.marginLarge),
          
          // Route Schedule
          const Text(
            'Schedule',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekdays:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('First Trip: 6:00 AM'),
                const Text('Last Trip: 9:00 PM'),
                const Text('Frequency: Every 30 minutes during peak hours'),
                const SizedBox(height: 12),
                const Text(
                  'Weekends & Holidays:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('First Trip: 6:30 AM'),
                const Text('Last Trip: 8:00 PM'),
                const Text('Frequency: Every 45 minutes'),
                const SizedBox(height: 12),
                const Text(
                  'Note: Schedule may vary due to traffic conditions.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // Extra space for FAB
        ],
      ),
    );
  }
  
  Widget _buildStopsTab(List<app_route.RouteStop> routeStops) {
    if (routeStops.isEmpty) {
      return const Center(
        child: Text('No stops available for this route.'),
      );
    }
    
    // Sort stops by order
    final sortedStops = List<app_route.RouteStop>.from(routeStops)
      ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: sortedStops.length,
        itemBuilder: (context, index) {
          final routeStop = sortedStops[index];
          final stop = routeStop.stop;
          
          if (stop == null) {
            return const SizedBox.shrink();
          }
          
          final isFirstStop = index == 0;
          final isLastStop = index == sortedStops.length - 1;
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      if (isFirstStop)
                        const Icon(
                          Icons.circle,
                          color: AppColors.primary,
                          size: 16,
                        )
                      else if (isLastStop)
                        const Icon(
                          Icons.location_on,
                          color: AppColors.error,
                          size: 20,
                        )
                      else
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      
                      if (!isLastStop)
                        Container(
                          width: 2,
                          height: 30,
                          color: isFirstStop ? AppColors.primary : Colors.grey.shade300,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                stop.stopName,
                                style: TextStyle(
                                  fontWeight: isFirstStop || isLastStop ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (stop.isMajor)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Major Stop',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (stop.address != null && stop.address!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              stop.address!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (routeStop.distanceFromStart != null || routeStop.estimatedTimeFromStart != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                if (routeStop.distanceFromStart != null) ...[
                                  const Icon(
                                    Icons.straighten,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${routeStop.distanceFromStart!.toStringAsFixed(1)} km',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                if (routeStop.estimatedTimeFromStart != null) ...[
                                  const Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${routeStop.estimatedTimeFromStart} min',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTripsTab(List<Trip> trips) {
    final upcomingTrips = trips.where((trip) => trip.status != 'completed' && trip.status != 'cancelled').toList();
    
    if (upcomingTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus_outlined,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: AppSizes.marginMedium),
            const Text(
              'No upcoming trips',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppSizes.marginSmall),
            const Text(
              'There are no upcoming trips for this route at the moment',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: AppSizes.marginMedium),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: upcomingTrips.length,
        itemBuilder: (context, index) {
          final trip = upcomingTrips[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.marginMedium),
            child: TripCard(
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
            ),
          );
        },
      ),
    );
  }
  
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      
      if (remainingMinutes == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $remainingMinutes min';
      }
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  
  _SliverAppBarDelegate(this.tabBar);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}