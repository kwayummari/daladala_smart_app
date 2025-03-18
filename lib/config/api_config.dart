import 'package:daladala_smart_app/config/app_config.dart';

class ApiConfig {
  // Base URL
  static const String baseUrl = AppConfig.apiBaseUrl;

  // Authentication endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String requestPasswordReset = '$baseUrl/auth/request-reset';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String verifyUser = '$baseUrl/auth/verify';

  // User endpoints
  static const String userProfile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String changePassword = '$baseUrl/users/change-password';
  static const String deleteAccount = '$baseUrl/users/account';
  static const String notifications = '$baseUrl/users/notifications';
  static const String markNotificationRead = '$baseUrl/users/notifications'; // + '/{id}/read'
  static const String markAllNotificationsRead = '$baseUrl/users/notifications/read-all';

  // Route endpoints
  static const String routes = '$baseUrl/routes';
  static const String routeById = '$baseUrl/routes'; // + '/{id}'
  static const String routeStops = '$baseUrl/routes'; // + '/{id}/stops'
  static const String routeFares = '$baseUrl/routes'; // + '/{id}/fares'
  static const String searchRoutes = '$baseUrl/routes/search';
  static const String fareBetweenStops = '$baseUrl/routes/fare';

  // Stop endpoints
  static const String stops = '$baseUrl/stops';
  static const String stopById = '$baseUrl/stops'; // + '/{id}'
  static const String searchStops = '$baseUrl/stops/search';

  // Trip endpoints
  static const String upcomingTrips = '$baseUrl/trips/upcoming';
  static const String tripById = '$baseUrl/trips'; // + '/{id}'
  static const String tripsByRoute = '$baseUrl/trips/route'; // + '/{route_id}'
  static const String updateTripStatus = '$baseUrl/trips/driver'; // + '/{id}/status'
  static const String updateVehicleLocation = '$baseUrl/trips/driver'; // + '/{trip_id}/location'

  // Booking endpoints
  static const String bookings = '$baseUrl/bookings';
  static const String bookingById = '$baseUrl/bookings'; // + '/{id}'
  static const String cancelBooking = '$baseUrl/bookings'; // + '/{id}/cancel'

  // Payment endpoints
  static const String payments = '$baseUrl/payments';
  static const String paymentHistory = '$baseUrl/payments/history';
  static const String paymentById = '$baseUrl/payments'; // + '/{id}'

  // Driver endpoints
  static const String driverProfile = '$baseUrl/drivers/profile';
  static const String driverAvailability = '$baseUrl/drivers/availability';
  static const String driverTrips = '$baseUrl/drivers/trips';
  static const String driverStatistics = '$baseUrl/drivers/statistics';

  // Schedule endpoints
  static const String schedulesByRoute = '$baseUrl/schedules/route'; // + '/{route_id}'
  static const String scheduleById = '$baseUrl/schedules'; // + '/{id}'

  // Review endpoints
  static const String reviews = '$baseUrl/reviews';
  static const String reviewsByTrip = '$baseUrl/reviews/trip'; // + '/{trip_id}'
  static const String reviewsByDriver = '$baseUrl/reviews/driver'; // + '/{driver_id}'
  static const String userReviews = '$baseUrl/reviews/my-reviews';

  // Vehicle endpoints
  static const String vehicles = '$baseUrl/vehicles';
  static const String vehicleById = '$baseUrl/vehicles'; // + '/{id}'
  static const String vehicleLocation = '$baseUrl/vehicles'; // + '/{id}/location'
}