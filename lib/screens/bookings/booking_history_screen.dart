import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/booking.dart';
import 'package:daladala_smart_app/providers/booking_provider.dart';
import 'package:daladala_smart_app/screens/bookings/booking_details_screen.dart';
import 'package:daladala_smart_app/widgets/booking/booking_card.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBookings() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.fetchBookings();
  }
  
  Future<void> _onRefresh() async {
    return _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'ACTIVE'),
            Tab(text: 'COMPLETED'),
            Tab(text: 'CANCELLED'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          if (bookingProvider.bookingsLoading) {
            return const Center(child: LoadingIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Active Bookings Tab
              _buildBookingsList(
                bookings: bookingProvider.activeBookings,
                emptyMessage: 'You have no active bookings',
                onRefresh: _onRefresh,
              ),
              
              // Completed Bookings Tab
              _buildBookingsList(
                bookings: bookingProvider.completedBookings,
                emptyMessage: 'You have no completed bookings',
                onRefresh: _onRefresh,
              ),
              
              // Cancelled Bookings Tab
              _buildBookingsList(
                bookings: bookingProvider.cancelledBookings,
                emptyMessage: 'You have no cancelled bookings',
                onRefresh: _onRefresh,
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildBookingsList({
    required List<Booking> bookings,
    required String emptyMessage,
    required Future<void> Function() onRefresh,
  }) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: AppSizes.marginMedium),
                    Text(
                      emptyMessage,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingDetailsScreen(
                    bookingId: booking.bookingId,
                  ),
                ),
              ).then((_) => _loadBookings());
            },
          );
        },
      ),
    );
  }
}