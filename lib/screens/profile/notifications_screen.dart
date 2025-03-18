import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/user.dart';
import 'package:daladala_smart_app/providers/user_provider.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchNotifications();
  }
  
  Future<void> _markAllAsRead() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.markAllNotificationsAsRead();
  }
  
  Future<void> _markAsRead(int notificationId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.markNotificationAsRead(notificationId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.notificationsLoading) {
            return const Center(child: LoadingIndicator());
          }
          
          final notifications = userProvider.notifications;
          
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  const Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key('notification_${notification.notificationId}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    // TODO: Implement delete notification
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${notification.title} dismissed'),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            // TODO: Implement undo
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    ),
                    color: notification.isRead ? null : Colors.blue.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
                      leading: CircleAvatar(
                        backgroundColor: _getNotificationColor(notification.type),
                        child: Icon(
                          _getNotificationIcon(notification.type),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notification.message),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, yyyy - h:mm a').format(
                              DateTime.parse(notification.createdAt),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: notification.isRead
                          ? null
                          : IconButton(
                              icon: const Icon(
                                Icons.mark_email_read,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _markAsRead(notification.notificationId),
                            ),
                      onTap: () {
                        if (!notification.isRead) {
                          _markAsRead(notification.notificationId);
                        }
                        
                        // Handle notification tap based on type and related entity
                        if (notification.relatedEntity != null && notification.relatedId != null) {
                          _navigateToRelatedScreen(
                            notification.relatedEntity!,
                            notification.relatedId!,
                          );
                        }
                      },
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
  
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'info':
        return Colors.blue;
      case 'success':
        return AppColors.success;
      case 'warning':
        return Colors.orange;
      case 'error':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'info':
        return Icons.info;
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }
  
  void _navigateToRelatedScreen(String entity, int id) {
    switch (entity) {
      case 'booking':
        Navigator.pushNamed(
          context,
          '/booking-details',
          arguments: id,
        );
        break;
      case 'trip':
        Navigator.pushNamed(
          context,
          '/trip-details',
          arguments: id,
        );
        break;
      case 'payment':
        Navigator.pushNamed(
          context,
          '/payment-details',
          arguments: id,
        );
        break;
      default:
        // Do nothing or show details in a dialog
        break;
    }
  }
}