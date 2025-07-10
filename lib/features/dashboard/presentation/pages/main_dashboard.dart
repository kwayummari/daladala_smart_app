import 'package:daladala_smart_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'driver_dashboard.dart';
import 'passenger_dashboard.dart';
import 'business_dashboard.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({Key? key}) : super(key: key);

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

        // Route based on user role
        switch (user.role) {
          case 'driver':
            return const DriverDashboard();
          case 'admin':
          case 'operator':
            return const DriverDashboard(); // Admin can see driver features
          case 'business':
            return const BusinessDashboard();
          default:
            return const PassengerDashboard();
        }
      },
    );
  }
}
