import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  
  const BookingCard({
    Key? key,
    required this.booking,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format booking time
    final bookingTime = DateTime.parse(booking.bookingTime);
    final formattedTime = DateFormat('hh:mm a').format(bookingTime);
    final formattedDate = DateFormat('EEE, MMM d').format(bookingTime);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Header - ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking #${booking.bookingId}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const Divider(),
              
              // Trip Info
              if (booking.trip != null && booking.trip!.route != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.directions_bus_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.trip!.route!.routeName,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Pickup and Dropoff
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
                          booking.pickupStop?.stopName ?? 'Unknown Pickup',
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          booking.dropoffStop?.stopName ?? 'Unknown Destination',
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Bottom Row - Date, Time, Passengers, and Payment Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$formattedDate, $formattedTime',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.passengerCount} ${booking.passengerCount > 1 ? 'persons' : 'person'}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  _buildPaymentStatusChip(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String displayText;
    
    switch (booking.status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'confirmed':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        displayText = 'Confirmed';
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
        displayText = booking.status;
    }
    
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
  
  Widget _buildPaymentStatusChip() {
    Color backgroundColor;
    Color textColor;
    String displayText;
    
    switch (booking.paymentStatus) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        displayText = 'Unpaid';
        break;
      case 'paid':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        displayText = 'Paid';
        break;
      case 'failed':
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        displayText = 'Failed';
        break;
      case 'refunded':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        displayText = 'Refunded';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        displayText = booking.paymentStatus;
    }
    
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
}