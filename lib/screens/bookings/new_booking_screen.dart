import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/route.dart' as app_route;
import 'package:daladala_smart_app/models/stop.dart' as app_stop;
import 'package:daladala_smart_app/models/trip.dart';
import 'package:daladala_smart_app/providers/booking_provider.dart';
import 'package:daladala_smart_app/providers/trip_provider.dart';
import 'package:daladala_smart_app/screens/bookings/booking_confirmation_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class NewBookingScreen extends StatefulWidget {
  final int routeId;
  
  const NewBookingScreen({
    Key? key,
    required this.routeId,
  }) : super(key: key);

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  int _currentStep = 0;
  
  // Step 1: Select trip
  Trip? _selectedTrip;
  
  // Step 2: Select pickup and dropoff
  app_stop.Stop? _selectedPickupStop;
  app_stop.Stop? _selectedDropoffStop;
  app_route.Fare? _calculatedFare;
  
  // Step 3: Passenger details
  int _passengerCount = 1;
  String _fareType = 'standard';
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      
      // Load route details
      await tripProvider.selectRoute(widget.routeId);
      
      // Load upcoming trips for this route
      await tripProvider.fetchUpcomingTrips(routeId: widget.routeId);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }
  
  void _selectTrip(Trip trip) {
    setState(() {
      _selectedTrip = trip;
      
      // Reset stops selection when trip changes
      _selectedPickupStop = null;
      _selectedDropoffStop = null;
      _calculatedFare = null;
    });
  }
  
  void _selectPickupStop(app_stop.Stop stop) {
    setState(() {
      _selectedPickupStop = stop;
      
      // Recalculate fare if both stops are selected
      if (_selectedDropoffStop != null) {
        _calculateFare();
      }
    });
  }
  
  void _selectDropoffStop(app_stop.Stop stop) {
    setState(() {
      _selectedDropoffStop = stop;
      
      // Recalculate fare if both stops are selected
      if (_selectedPickupStop != null) {
        _calculateFare();
      }
    });
  }
  
  Future<void> _calculateFare() async {
    if (_selectedPickupStop == null || _selectedDropoffStop == null) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      final fare = await tripProvider.calculateFare(
        widget.routeId,
        _selectedPickupStop!.stopId,
        _selectedDropoffStop!.stopId,
        fareType: _fareType,
      );
      
      setState(() {
        _calculatedFare = fare;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _calculatedFare = null;
        _isLoading = false;
        _errorMessage = 'Failed to calculate fare: ${e.toString()}';
      });
    }
  }
  
  Future<void> _createBooking() async {
    if (_selectedTrip == null ||
        _selectedPickupStop == null ||
        _selectedDropoffStop == null) {
      setState(() {
        _errorMessage = 'Please complete all the required information';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      final success = await bookingProvider.createBooking(
        _selectedTrip!.tripId,
        _selectedPickupStop!.stopId,
        _selectedDropoffStop!.stopId,
        _passengerCount,
      );
      
      if (success && mounted) {
        // Navigate to booking confirmation page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              bookingId: bookingProvider.currentBooking!.bookingId,
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = bookingProvider.processingError;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to create booking: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Booking'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Text(
                'Error',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSizes.marginLarge),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Consumer<TripProvider>(
      builder: (context, tripProvider, _) {
        if (tripProvider.selectedRoute == null) {
          return const Center(
            child: Text('Route not found'),
          );
        }
        
        return Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0 && _selectedTrip == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a trip'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            
            if (_currentStep == 1 &&
                (_selectedPickupStop == null || _selectedDropoffStop == null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select both pickup and dropoff points'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            
            // If on the last step, create booking
            if (_currentStep == 2) {
              _createBooking();
              return;
            }
            
            setState(() {
              _currentStep += 1;
            });
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            } else {
              Navigator.pop(context);
            }
          },
          steps: [
            // Step 1: Select Trip
            Step(
              title: const Text('Select Trip'),
              content: _buildTripSelection(tripProvider.upcomingTrips),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : (_selectedTrip != null ? StepState.indexed : StepState.indexed),
            ),
            
            // Step 2: Select Stops
            Step(
              title: const Text('Select Stops'),
              content: _buildStopSelection(tripProvider.routeStops),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : (_selectedPickupStop != null && _selectedDropoffStop != null
                      ? StepState.indexed
                      : StepState.indexed),
            ),
            
            // Step 3: Passenger Details and Fare
            Step(
              title: const Text('Passenger Details'),
              content: _buildPassengerDetails(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildTripSelection(List<Trip> trips) {
    if (trips.isEmpty) {
      return const Center(
        child: Text('No upcoming trips available'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a trip from the available options:',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSizes.marginMedium),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            final isSelected = _selectedTrip?.tripId == trip.tripId;
            
            // Format trip time
            final startTime = DateTime.parse(trip.startTime);
            final formattedTime = DateFormat('hh:mm a').format(startTime);
            final formattedDate = DateFormat('EEE, MMM d').format(startTime);
            
            return Card(
              elevation: isSelected ? 4 : 1,
              margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                side: isSelected
                    ? const BorderSide(color: AppColors.primary, width: 2)
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () => _selectTrip(trip),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Row(
                    children: [
                      // Status indicator
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.marginMedium),
                      
                      // Trip details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Vehicle info
                      if (trip.vehicle != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              trip.vehicle!.plateNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${trip.vehicle!.vehicleType} - ${trip.vehicle!.capacity} seats',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildStopSelection(List<app_route.RouteStop> routeStops) {
    if (routeStops.isEmpty) {
      return const Center(
        child: Text('No stops available for this route'),
      );
    }
    
    // Sort stops by order
    final sortedStops = List<app_route.RouteStop>.from(routeStops)
      ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    
    // Extract actual Stop objects for selection
    final stops = sortedStops.map((routeStop) => routeStop.stop).where((stop) => stop != null).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup Stop Selection
        const Text(
          'Select pickup point:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.marginSmall),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<app_stop.Stop>(
              value: _selectedPickupStop,
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Select pickup stop'),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: stops.map((stop) {
                return DropdownMenuItem<app_stop.Stop>(
                  value: stop,
                  child: Text(stop!.stopName),
                );
              }).toList(),
              onChanged: (app_stop.Stop? value) {
                if (value != null) {
                  _selectPickupStop(value);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Dropoff Stop Selection
        const Text(
          'Select destination:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.marginSmall),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<app_stop.Stop>(
              value: _selectedDropoffStop,
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Select destination'),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: stops.map((stop) {
                return DropdownMenuItem<app_stop.Stop>(
                  value: stop,
                  child: Text(stop!.stopName),
                );
              }).toList(),
              onChanged: (app_stop.Stop? value) {
                if (value != null && value != _selectedPickupStop) {
                  _selectDropoffStop(value);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Fare Type Selection
        const Text(
          'Fare Type:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.marginSmall),
        Row(
          children: [
            Radio<String>(
              value: 'standard',
              groupValue: _fareType,
              onChanged: (value) {
                setState(() {
                  _fareType = value!;
                  // Recalculate fare
                  if (_selectedPickupStop != null && _selectedDropoffStop != null) {
                    _calculateFare();
                  }
                });
              },
            ),
            const Text('Standard'),
            const SizedBox(width: AppSizes.marginMedium),
            Radio<String>(
              value: 'student',
              groupValue: _fareType,
              onChanged: (value) {
                setState(() {
                  _fareType = value!;
                  // Recalculate fare
                  if (_selectedPickupStop != null && _selectedDropoffStop != null) {
                    _calculateFare();
                  }
                });
              },
            ),
            const Text('Student'),
          ],
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Display Fare
        if (_calculatedFare != null)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fare Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('From:'),
                    Text(
                      _selectedPickupStop?.stopName ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('To:'),
                    Text(
                      _selectedDropoffStop?.stopName ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fare Type:'),
                    Text(
                      _fareType == 'standard' ? 'Standard' : 'Student',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fare Amount:'),
                    Text(
                      '${_calculatedFare!.amount.toStringAsFixed(0)} ${_calculatedFare!.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildPassengerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Number of passengers:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.marginSmall),
        Row(
          children: [
            IconButton(
              onPressed: _passengerCount > 1
                  ? () {
                      setState(() {
                        _passengerCount--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: _passengerCount > 1 ? AppColors.primary : Colors.grey,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _passengerCount.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: _passengerCount < 5
                  ? () {
                      setState(() {
                        _passengerCount++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: _passengerCount < 5 ? AppColors.primary : Colors.grey,
            ),
            const Text('(Maximum 5 passengers per booking)'),
          ],
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Booking Summary
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              
              if (_selectedTrip != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Trip:'),
                    Text(
                      'Route ${_selectedTrip!.route?.routeNumber ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date:'),
                    Text(
                      DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(_selectedTrip!.startTime)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Time:'),
                    Text(
                      DateFormat('hh:mm a').format(DateTime.parse(_selectedTrip!.startTime)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.marginSmall),
                const Divider(),
              ],
              
              if (_selectedPickupStop != null && _selectedDropoffStop != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('From:'),
                    Text(
                      _selectedPickupStop!.stopName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('To:'),
                    Text(
                      _selectedDropoffStop!.stopName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.marginSmall),
                const Divider(),
              ],
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Passengers:'),
                  Text(
                    '$_passengerCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fare Type:'),
                  Text(
                    _fareType == 'standard' ? 'Standard' : 'Student',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              if (_calculatedFare != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fare per person:'),
                    Text(
                      '${_calculatedFare!.amount.toStringAsFixed(0)} ${_calculatedFare!.currency}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:'),
                    Text(
                      '${(_calculatedFare!.amount * _passengerCount).toStringAsFixed(0)} ${_calculatedFare!.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: AppSizes.marginMedium),
              const Text(
                'Note: Payment will be processed after booking confirmation.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}