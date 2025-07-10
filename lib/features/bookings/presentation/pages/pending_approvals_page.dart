import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../widgets/approval_card.dart';

class PendingApprovalsPage extends StatefulWidget {
  const PendingApprovalsPage({Key? key}) : super(key: key);

  @override
  State<PendingApprovalsPage> createState() => _PendingApprovalsPageState();
}

class _PendingApprovalsPageState extends State<PendingApprovalsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().loadPendingApprovals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BusinessProvider>().loadPendingApprovals();
            },
          ),
        ],
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, child) {
          if (businessProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (businessProvider.error != null) {
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
                    onPressed: () => businessProvider.loadPendingApprovals(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final pendingApprovals = businessProvider.pendingApprovals;

          if (pendingApprovals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No Pending Approvals',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All employee bookings have been processed',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => businessProvider.loadPendingApprovals(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingApprovals.length,
              itemBuilder: (context, index) {
                final approval = pendingApprovals[index];
                return ApprovalCard(
                  approval: approval,
                  onApprove:
                      () => _approveBooking(approval['business_booking_id']),
                  onReject:
                      () => _rejectBooking(approval['business_booking_id']),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _approveBooking(int businessBookingId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Approve Booking'),
            content: const Text(
              'Are you sure you want to approve this employee booking?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await context
                      .read<BusinessProvider>()
                      .approveEmployeeBooking(businessBookingId, 'approved');

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking approved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Approve'),
              ),
            ],
          ),
    );
  }

  void _rejectBooking(int businessBookingId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Booking'),
            content: const Text(
              'Are you sure you want to reject this employee booking?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await context
                      .read<BusinessProvider>()
                      .approveEmployeeBooking(businessBookingId, 'rejected');

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking rejected'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }
}
