import 'package:daladala_smart_app/features/bookings/presentation/providers/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../widgets/employee_info_form.dart';
import '../widgets/trip_selection_widget.dart';

class CreateEmployeeBookingPage extends StatefulWidget {
  const CreateEmployeeBookingPage({Key? key}) : super(key: key);

  @override
  State<CreateEmployeeBookingPage> createState() =>
      _CreateEmployeeBookingPageState();
}

class _CreateEmployeeBookingPageState extends State<CreateEmployeeBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _employeeNameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();

  int? selectedTripId;
  int? selectedPickupStopId;
  int? selectedDropoffStopId;
  int passengerCount = 1;
  List<String> selectedSeats = [];
  bool autoApprove = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadRoutes();
      context.read<BookingProvider>().loadStops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book for Employee'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Information
              const Text(
                'Employee Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              EmployeeInfoForm(
                employeeNameController: _employeeNameController,
                employeeIdController: _employeeIdController,
                departmentController: _departmentController,
              ),

              const SizedBox(height: 24),

              // Trip Selection
              const Text(
                'Trip Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TripSelectionWidget(
                onTripSelected: (tripId, pickupStopId, dropoffStopId) {
                  setState(() {
                    selectedTripId = tripId;
                    selectedPickupStopId = pickupStopId;
                    selectedDropoffStopId = dropoffStopId;
                  });
                },
                onPassengerCountChanged: (count) {
                  setState(() {
                    passengerCount = count;
                  });
                },
                onSeatsSelected: (seats) {
                  setState(() {
                    selectedSeats = seats;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Approval Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Approval Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Auto-approve this booking'),
                        subtitle: const Text(
                          'Booking will be confirmed immediately',
                        ),
                        value: autoApprove,
                        onChanged: (value) {
                          setState(() {
                            autoApprove = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Consumer<BusinessProvider>(
                  builder: (context, businessProvider, child) {
                    return ElevatedButton(
                      onPressed:
                          businessProvider.isLoading || !_canSubmit()
                              ? null
                              : _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          businessProvider.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                autoApprove
                                    ? 'Create & Approve Booking'
                                    : 'Create Booking',
                              ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _formKey.currentState?.validate() == true &&
        selectedTripId != null &&
        selectedPickupStopId != null &&
        selectedDropoffStopId != null;
  }

  void _submitBooking() async {
    if (!_canSubmit()) return;

    final businessProvider = context.read<BusinessProvider>();

    final bookingData = {
      'trip_id': selectedTripId,
      'pickup_stop_id': selectedPickupStopId,
      'dropoff_stop_id': selectedDropoffStopId,
      'employee_name': _employeeNameController.text,
      'employee_id': _employeeIdController.text,
      'department': _departmentController.text,
      'passenger_count': passengerCount,
      'seat_preferences': selectedSeats,
      'auto_approve': autoApprove,
    };

    final success = await businessProvider.createEmployeeBooking(bookingData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            autoApprove
                ? 'Employee booking created and approved successfully'
                : 'Employee booking created successfully and is pending approval',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(businessProvider.error ?? 'Failed to create booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}
