
import 'package:daladala_smart_app/features/bookings/presentation/pages/business_overview_page.dart';
import 'package:daladala_smart_app/features/bookings/presentation/pages/pending_approvals_page.dart';
import 'package:daladala_smart_app/features/business/presentation/pages/business_profile_page.dart';
import 'package:daladala_smart_app/features/business/presentation/pages/business_reports_page.dart';
import 'package:daladala_smart_app/features/business/presentation/pages/employee_bookings_page.dart';
import 'package:daladala_smart_app/features/dashboard/presentation/widgets/business_bottom_nav.dart';
import 'package:flutter/material.dart';

class BusinessDashboard extends StatefulWidget {
  const BusinessDashboard({Key? key}) : super(key: key);

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BusinessOverviewPage(),
    const EmployeeBookingsPage(),
    const PendingApprovalsPage(),
    const BusinessReportsPage(),
    const BusinessProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BusinessBottomNav(
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