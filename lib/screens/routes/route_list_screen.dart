import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/route.dart' as app_route;
import 'package:daladala_smart_app/providers/trip_provider.dart';
import 'package:daladala_smart_app/screens/routes/route_detail_screen.dart';
import 'package:daladala_smart_app/screens/routes/route_search_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({Key? key}) : super(key: key);

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }
  
  Future<void> _loadRoutes() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.fetchRoutes();
  }
  
  Future<void> _onRefresh() async {
    await _loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RouteSearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          if (tripProvider.routesLoading) {
            return const Center(child: LoadingIndicator());
          }
          
          if (tripProvider.routesError.isNotEmpty) {
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
                    'Error: ${tripProvider.routesError}',
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
          
          if (tripProvider.routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_bus_outlined,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  Text(
                    'No routes available',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
              itemCount: tripProvider.routes.length,
              itemBuilder: (context, index) {
                final route = tripProvider.routes[index];
                return _buildRouteCard(route);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRouteCard(app_route.Route route) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreen(
                routeId: route.routeId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route number and name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route ${route.routeNumber}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          route.routeName,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildRouteStatusChip(route.status),
                ],
              ),
              const Divider(),
              
              // Start and End Points
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: AppColors.primary,
                        size: 12,
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: AppColors.error,
                        size: 16,
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
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          route.endPoint,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.marginMedium),
              
              // Distance and Duration
              Row(
                children: [
                  if (route.distanceKm != null) ...[
                    const Icon(
                      Icons.straighten,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${route.distanceKm!.toStringAsFixed(1)} km',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: AppSizes.marginMedium),
                  ],
                  
                  if (route.estimatedTimeMinutes != null) ...[
                    const Icon(
                      Icons.timer,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(route.estimatedTimeMinutes!),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // View Details Button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RouteDetailScreen(
                            routeId: route.routeId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Details'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRouteStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case 'active':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case 'inactive':
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        break;
      case 'under_maintenance':
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
    }
    
    String displayText = status.replaceAll('_', ' ');
    displayText = displayText[0].toUpperCase() + displayText.substring(1);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
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