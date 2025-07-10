import 'package:daladala_smart_app/features/bookings/presentation/widgets/business_stats_card.dart';
import 'package:daladala_smart_app/features/bookings/presentation/widgets/recent_bookings_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import 'create_employee_booking_page.dart';

class BusinessOverviewPage extends StatefulWidget {
  const BusinessOverviewPage({Key? key}) : super(key: key);

  @override
  State<BusinessOverviewPage> createState() => _BusinessOverviewPageState();
}

class _BusinessOverviewPageState extends State<BusinessOverviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().loadBusinessAccount();
      context.read<BusinessProvider>().loadRecentBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BusinessProvider>().loadBusinessAccount();
              context.read<BusinessProvider>().loadRecentBookings();
            },
          ),
        ],
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, child) {
          if (businessProvider.isLoading &&
              businessProvider.businessAccount == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (businessProvider.error != null &&
              businessProvider.businessAccount == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    businessProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => businessProvider.loadBusinessAccount(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final businessAccount = businessProvider.businessAccount;
          if (businessAccount == null) {
            return _buildCreateBusinessAccount(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await businessProvider.loadBusinessAccount();
              await businessProvider.loadRecentBookings();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.business, color: Colors.purple[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  businessAccount['business_info']['business_name'] ??
                                      'N/A',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildStatusChip(
                                businessAccount['business_info']['status'],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reg. No: ${businessAccount['business_info']['registration_number'] ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Contact: ${businessAccount['business_info']['contact_person'] ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const CreateEmployeeBookingPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('New Booking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to pending approvals
                            DefaultTabController.of(context).animateTo(2);
                          },
                          icon: const Icon(Icons.approval),
                          label: Text(
                            'Approvals (${businessProvider.pendingApprovals.length})',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Statistics
                  const Text(
                    'Booking Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  BusinessStatsCard(
                    stats: businessAccount['booking_statistics'] ?? {},
                  ),

                  const SizedBox(height: 24),

                  // Recent Bookings
                  const Text(
                    'Recent Bookings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  RecentBookingsWidget(
                    bookings: businessProvider.recentBookings,
                    isLoading: businessProvider.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateBusinessAccount(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 80, color: Colors.purple[300]),
            const SizedBox(height: 24),
            const Text(
              'Create Business Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Set up your corporate account to manage employee bookings and get volume discounts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-business-account');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = Colors.green;
        text = 'Active';
        break;
      case 'pending_approval':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'suspended':
        color = Colors.red;
        text = 'Suspended';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontSize: 12),
    );
  }
}
