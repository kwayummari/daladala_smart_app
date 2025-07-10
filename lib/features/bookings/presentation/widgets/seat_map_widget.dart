import 'package:flutter/material.dart';

class SeatMapWidget extends StatelessWidget {
  final Map<String, dynamic> seats;
  final List<String> selectedSeats;
  final int maxSelection;
  final Function(String) onSeatSelected;

  const SeatMapWidget({
    Key? key,
    required this.seats,
    required this.selectedSeats,
    required this.maxSelection,
    required this.onSeatSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final seatList = seats['seats'] as List<dynamic>? ?? [];

    return Column(
      children: [
        // Legend
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.green, 'Available'),
              _buildLegendItem(Colors.blue, 'Selected'),
              _buildLegendItem(Colors.red, 'Occupied'),
            ],
          ),
        ),

        // Driver section indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.drive_eta),
              SizedBox(width: 8),
              Text('Driver', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Seat Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 2 seats + aisle + 2 seats
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount:
                seatList.length + (seatList.length ~/ 2), // Add aisle spaces
            itemBuilder: (context, index) {
              // Add aisle space every 2 seats
              if ((index + 1) % 3 == 0) {
                return const SizedBox(); // Aisle space
              }

              final seatIndex = index - (index ~/ 3);
              if (seatIndex >= seatList.length) return const SizedBox();

              final seat = seatList[seatIndex];
              final seatNumber = seat['seat_number'] as String;
              final isAvailable = seat['is_available'] as bool;
              final isSelected = selectedSeats.contains(seatNumber);

              return GestureDetector(
                onTap: isAvailable ? () => onSeatSelected(seatNumber) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getSeatColor(isAvailable, isSelected),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue[700]! : Colors.grey[400]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      seatNumber,
                      style: TextStyle(
                        color: isAvailable ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Selection info
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Selected ${selectedSeats.length} of $maxSelection seats',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getSeatColor(bool isAvailable, bool isSelected) {
    if (isSelected) return Colors.blue;
    if (isAvailable) return Colors.green;
    return Colors.red;
  }
}
