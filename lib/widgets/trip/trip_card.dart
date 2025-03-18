import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  
  const TripCard({
    Key? key,
    required this.trip,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final route = trip.route;
    if (route == null) {
      return const SizedBox.shrink();
    }
    
    // Format trip time
    final startTime = DateTime.parse(trip.startTime);
    final formattedTime = DateFormat('hh:mm a').format(startTime);
    final formattedDate = DateFormat('EEE, MMM d').format(startTime);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSizes.marginMedium),
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Route and Time
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.cardRadius),
                  topRight: Radius.circular(AppSizes.cardRadius),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route ${route.routeNumber}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          route.routeName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedTime,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Body - Route Details
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start and End Points
                  Row(
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: AppColors.primary,
                            size: 12,
                          ),
                          Container(
                            height: 30,
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
                      const SizedBox(width: AppSizes.marginSmall),
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
                            const SizedBox(height: 16),
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
                  
                  // Vehicle and Driver Info
                  Row(
                    children: [
                      if (trip.vehicle != null) ...[
                        _buildInfoItem(
                          Icons.directions_bus_outlined,
                          trip.vehicle!.plateNumber,
                        ),
                        const SizedBox(width: AppSizes.marginMedium),
                      ],
                      
                      if (trip.driver != null && trip.driver!.user != null) ...[
                        _buildInfoItem(
                          Icons.person_outline,
                          trip.driver!.user!.fullName,
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.marginMedium),
                  
                  // Status and Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(trip.status),
                      
                      TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Details'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;
    
    switch (status) {
      case 'scheduled':
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        displayText = 'Scheduled';
        break;
      case 'in_progress':
        backgroundColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        displayText = 'In Progress';
        break;
      case 'completed':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        displayText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
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
}