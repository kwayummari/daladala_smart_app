
import 'package:daladala_smart_app/features/bookings/presentation/providers/booking_provider2.dart';
import 'package:daladala_smart_app/features/bookings/presentation/widgets/route_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripSelectionWidget extends StatefulWidget {
  final Function(int, int, int) onTripSelected; // tripId, pickupStopId, dropoffStopId
  final Function(int) onPassengerCountChanged;
  final Function(List<String>) onSeatsSelected;

  const TripSelectionWidget({
    Key? key,
    required this.onTripSelected,
    required this.onPassengerCountChanged,
    required this.onSeatsSelected,
  }) : super(key: key);

  @override
  State<TripSelectionWidget> createState() => _TripSelectionWidgetState();
}

class _TripSelectionWidgetState extends State<TripSelectionWidget> {
  int? selectedRouteId;
  int? selectedPickupStopId;
  int? selectedDropoffStopId;
  int? selectedTripId;
  int passengerCount = 1;
  DateTime selectedDate = DateTime.now();
  List<String> selectedSeats = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Selection
            RouteSelector(
              onRouteSelected: (routeId) {
                setState(() {
                  selectedRouteId = routeId;
                  selectedPickupStopId = null;
                  selectedDropoffStopId = null;
                  selectedTripId = null;
                });
              },
              onPickupStopSelected: (stopId) {
                setState(() {
                  selectedPickupStopId = stopId;
                  selectedTripId = null;
                });
              },
              onDropoffStopSelected: (stopId) {
                setState(() {
                  selectedDropoffStopId = stopId;
                  selectedTripId = null;
                });
                _searchTrips();
              },
            ),

            const SizedBox(height: 16),

            // Date Selection
            Row(
              children: [
                const Text(
                  'Travel Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Passenger Count
            Row(
              children: [
                const Text(
                  'Passengers',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: passengerCount > 1 ? () {
                    setState(() {
                      passengerCount--;
                    });
                    widget.onPassengerCountChanged(passengerCount);
                  } : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$passengerCount',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: passengerCount < 6 ? () {
                    setState(() {
                      passengerCount++;
                    });
                    widget.onPassengerCountChanged(passengerCount);
                  } : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Available Trips
            if (bookingProvider.availableTrips.isNotEmpty) ...[
              const Text(
                'Available Trips',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: bookingProvider.availableTrips.length,
                  itemBuilder: (context, index) {
                    final trip = bookingProvider.availableTrips[index];
                    final isSelected = selectedTripId == trip['trip_id'];
                    
                    return Card(
                      color: isSelected ? Colors.blue[50] : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? Colors.blue : Colors.grey,
                          child: Icon(
                            Icons.directions_bus,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          '${_formatTime(trip['start_time'])} - ${trip['vehicle_plate']}',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${trip['available_seats']} seats available • TSh ${trip['base_fare']}',
                        ),
                        trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () {
                          setState(() {
                            selectedTripId = trip['trip_id'];
                          });
                          widget.onTripSelected(
                            trip['trip_id'],
                            selectedPickupStopId!,
                            selectedDropoffStopId!,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],

            // Seat Selection (if trip selected)
            if (selectedTripId != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Seat Preference',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Open seat selection dialog
                      _showSeatSelectionDialog();
                    },
                    child: Text(
                      selectedSeats.isEmpty 
                          ? 'Auto-assign seats'
                          : '${selectedSeats.length} seats selected',
                    ),
                  ),
                ],
              ),
              if (selectedSeats.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: selectedSeats.map((seat) {
                    return Chip(
                      label: Text(seat),
                      backgroundColor: Colors.blue[100],
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedSeats.remove(seat);
                        });
                        widget.onSeatsSelected(selectedSeats);
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      if (selectedRouteId != null) {
        _searchTrips();
      }
    }
  }

  void _searchTrips() {
    if (selectedRouteId != null) {
      context.read<BookingProvider>().searchTrips(
        routeId: selectedRouteId!,
        date: selectedDate,
      );
    }
  }

  void _showSeatSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Seats'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 30, // Assuming 30 seats
            itemBuilder: (context, index) {
              final seatNumber = 'S${(index + 1).toString().padLeft(2, '0')}';
              final isSelected = selectedSeats.contains(seatNumber);
              final canSelect = selectedSeats.length < passengerCount || isSelected;
              
              return GestureDetector(
                onTap: canSelect ? () {
                  setState(() {
                    if (isSelected) {
                      selectedSeats.remove(seatNumber);
                    } else if (selectedSeats.length < passengerCount) {
                      selectedSeats.add(seatNumber);
                    }
                  });
                } : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.blue 
                        : canSelect 
                            ? Colors.green 
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      seatNumber,
                      style: TextStyle(
                        color: isSelected || canSelect ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSeatsSelected(selectedSeats);
            },
            child: const Text('Confirm'),
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