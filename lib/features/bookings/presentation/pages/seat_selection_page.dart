import 'package:daladala_smart_app/features/bookings/presentation/providers/booking_provider.dart';
import 'package:daladala_smart_app/features/bookings/presentation/widgets/booking_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/seat_map_widget.dart';
import 'booking_confirmation_page.dart';

class SeatSelectionPage extends StatefulWidget {
  final Map<String, dynamic> trip;
  final int pickupStopId;
  final int dropoffStopId;

  const SeatSelectionPage({
    Key? key,
    required this.trip,
    required this.pickupStopId,
    required this.dropoffStopId,
  }) : super(key: key);

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  List<String> selectedSeats = [];
  int passengerCount = 1;

  @override
  void initState() {
    super.initState();
    _loadAvailableSeats();
  }

  void _loadAvailableSeats() {
    context.read<BookingProvider>().loadAvailableSeats(
      widget.trip['trip_id'],
      widget.pickupStopId,
      widget.dropoffStopId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Trip Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.trip['route_name'] ?? 'Unknown Route',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Departure: ${_formatTime(widget.trip['start_time'])}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Vehicle: ${widget.trip['vehicle_plate'] ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Passenger Count Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Passengers:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed:
                      passengerCount > 1
                          ? () {
                            setState(() {
                              passengerCount--;
                              if (selectedSeats.length > passengerCount) {
                                selectedSeats =
                                    selectedSeats.take(passengerCount).toList();
                              }
                            });
                          }
                          : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$passengerCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed:
                      passengerCount < 4
                          ? () {
                            setState(() {
                              passengerCount++;
                            });
                          }
                          : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Seat Map
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                if (bookingProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bookingProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(bookingProvider.error!),
                        ElevatedButton(
                          onPressed: _loadAvailableSeats,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return SeatMapWidget(
                  seats: bookingProvider.availableSeats ?? {},
                  selectedSeats: selectedSeats,
                  maxSelection: passengerCount,
                  onSeatSelected: (seatNumber) {
                    setState(() {
                      if (selectedSeats.contains(seatNumber)) {
                        selectedSeats.remove(seatNumber);
                      } else if (selectedSeats.length < passengerCount) {
                        selectedSeats.add(seatNumber);
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Booking Summary and Continue Button
          BookingSummaryWidget(
            trip: widget.trip,
            selectedSeats: selectedSeats,
            passengerCount: passengerCount,
            onContinue:
                selectedSeats.length == passengerCount
                    ? () {
                      // In seat_selection_page.dart, fix the navigation:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookingConfirmationPage(
                                tripId:
                                    widget.trip['trip_id']
                                        as int, // Extract trip_id from the map
                                routeName: widget.trip['route_name'] ?? '',
                                from: widget.trip['start_point'] ?? '',
                                to: widget.trip['end_point'] ?? '',
                                startTime:
                                    DateTime.tryParse(
                                      widget.trip['start_time'] ?? '',
                                    ) ??
                                    DateTime.now(),
                                fare: (widget.trip['fare'] ?? 0.0).toDouble(),
                                vehiclePlate:
                                    widget.trip['vehicle_plate'] ?? '',
                                pickupStopId: widget.pickupStopId,
                                dropoffStopId: widget.dropoffStopId,
                              ),
                        ),
                      );
                    }
                    : null,
          ),
        ],
      ),
    );
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
}
