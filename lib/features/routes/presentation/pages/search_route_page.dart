import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_input.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../widgets/route_selection_result.dart';
import '../../../trips/presentation/pages/trip_selection_page.dart';

class SearchRoutePage extends StatefulWidget {
  const SearchRoutePage({Key? key}) : super(key: key);

  @override
  State<SearchRoutePage> createState() => _SearchRoutePageState();
}

class _SearchRoutePageState extends State<SearchRoutePage> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  bool _isSearching = false;
  bool _showResults = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _searchRoutes() async {
    FocusScope.of(context).unfocus();

    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both pickup and destination locations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _showResults = false;
    });

    // Simulate API call to search for routes
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSearching = false;
      _showResults = true;
    });
  }

  void _navigateToTripSelection(Map<String, dynamic> route) {
    // Show stop selection dialog before navigation
    _showStopSelectionDialog(route);
  }

  void _showStopSelectionDialog(Map<String, dynamic> route) {
    // Sample stops for the route (in real app, fetch from API)
    final routeStops = [
      {'id': 1, 'name': 'Mbezi Mwisho Terminal', 'is_major': true},
      {'id': 2, 'name': 'Mbezi Beach', 'is_major': false},
      {'id': 3, 'name': 'Sinza Mori', 'is_major': false},
      {'id': 4, 'name': 'Mwenge Bus Terminal', 'is_major': true},
      {'id': 5, 'name': 'Msimbazi', 'is_major': false},
      {'id': 6, 'name': 'Posta CBD', 'is_major': true},
    ];

    int? selectedPickupId;
    int? selectedDropoffId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Select Stops for ${route['route_name']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Choose your pickup and dropoff stops along this route',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Selected stops display
              if (selectedPickupId != null || selectedDropoffId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedPickupId != null)
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.green, size: 12),
                            const SizedBox(width: 8),
                            Text('From: ${routeStops.firstWhere((s) => s['id'] == selectedPickupId)['name']}'),
                          ],
                        ),
                      if (selectedPickupId != null && selectedDropoffId != null)
                        const SizedBox(height: 4),
                      if (selectedDropoffId != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 12),
                            const SizedBox(width: 8),
                            Text('To: ${routeStops.firstWhere((s) => s['id'] == selectedDropoffId)['name']}'),
                          ],
                        ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Stops list
              Expanded(
                child: ListView.builder(
                  itemCount: routeStops.length,
                  itemBuilder: (context, index) {
                    final stop = routeStops[index];
                    final isPickupSelected = selectedPickupId == stop['id'];
                    final isDropoffSelected = selectedDropoffId == stop['id'];
                    final isSelected = isPickupSelected || isDropoffSelected;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isPickupSelected 
                            ? Colors.green 
                            : isDropoffSelected 
                                ? Colors.red 
                                : Colors.grey.shade300,
                        child: Icon(
                          isPickupSelected 
                              ? Icons.circle 
                              : isDropoffSelected 
                                  ? Icons.location_on 
                                  : Icons.place,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        stop['name'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(stop['is_major'] as bool ? 'Major Terminal' : 'Regular Stop'),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: isPickupSelected ? Colors.green : Colors.red,
                            )
                          : null,
                      onTap: () {
                        setModalState(() {
                          if (selectedPickupId == null) {
                            selectedPickupId = stop['id'] as int;
                          } else if (selectedDropoffId == null && stop['id'] != selectedPickupId) {
                            selectedDropoffId = stop['id'] as int;
                          } else {
                            // Reset selection
                            selectedPickupId = stop['id'] as int;
                            selectedDropoffId = null;
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'View Trips',
                      onPressed: selectedPickupId != null && selectedDropoffId != null
                          ? () {
                              Navigator.pop(context);
                              
                              final pickupStop = routeStops.firstWhere((s) => s['id'] == selectedPickupId);
                              final dropoffStop = routeStops.firstWhere((s) => s['id'] == selectedDropoffId);
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TripSelectionPage(
                                    routeId: route['id'] as int,
                                    routeName: route['route_name'] as String,
                                    from: pickupStop['name'] as String,
                                    to: dropoffStop['name'] as String,
                                    pickupStopId: selectedPickupId!,    // ✅ Now provided
                                    dropoffStopId: selectedDropoffId!,  // ✅ Now provided
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Route'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // From field
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.circle_outlined,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomInput(
                        hint: 'From where?',
                        controller: _fromController,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                // Connecting line
                Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Center(
                        child: Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: const Divider(),
                      ),
                    ),
                  ],
                ),

                // To field
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomInput(
                        hint: 'To where?',
                        controller: _toController,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search button
                CustomButton(
                  text: 'Find Routes',
                  onPressed: _searchRoutes,
                  isLoading: _isSearching,
                  icon: Icons.search,
                ),

                const SizedBox(height: 8),

                // Use current location button
                TextButton.icon(
                  onPressed: () {
                    // Set current location as pickup
                    setState(() {
                      _fromController.text = 'Current Location';
                    });
                  },
                  icon: Icon(
                    Icons.my_location,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  label: Text(
                    'Use my current location',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child:
                _isSearching
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Searching for routes...',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _showResults
                    ? _buildSearchResults()
                    : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/route_search.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Find Your Route',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter your pickup and destination locations to find available routes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // Sample route results
    final results = [
      {
        'id': 1,
        'route_name': 'R001: Mbezi - CBD',
        'start_point': 'Mbezi Mwisho',
        'end_point': 'Posta CBD',
        'stops': 4,
        'distance_km': 18.5,
        'estimated_time': 45,
        'fare': 1500.0,
        'available_trips': 4,
      },
      {
        'id': 2,
        'route_name': 'R002: Kimara - CBD',
        'start_point': 'Kimara Mwisho',
        'end_point': 'Posta CBD',
        'stops': 4,
        'distance_km': 15.2,
        'estimated_time': 40,
        'fare': 1500.0,
        'available_trips': 3,
      },
      {
        'id': 3,
        'route_name': 'R003: Tegeta - CBD',
        'start_point': 'Tegeta Mwisho',
        'end_point': 'Posta CBD',
        'stops': 5,
        'distance_km': 22.8,
        'estimated_time': 55,
        'fare': 2000.0,
        'available_trips': 2,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Routes (${results.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              Text(
                'From ${_fromController.text} to ${_toController.text}',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final route = results[index];
              return RouteSelectionResult(
                id: route['id'] as int,
                routeName: route['route_name'] as String,
                startPoint: route['start_point'] as String,
                endPoint: route['end_point'] as String,
                stops: route['stops'] as int,
                distanceKm: route['distance_km'] as double,
                estimatedTime: route['estimated_time'] as int,
                fare: route['fare'] as double,
                availableTrips: route['available_trips'] as int,
                onViewTrips: () => _navigateToTripSelection(route), // ✅ Now shows stop selection first
              );
            },
          ),
        ),
      ],
    );
  }
}