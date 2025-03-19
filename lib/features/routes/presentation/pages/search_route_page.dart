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
          child: Text(
            'Available Routes (${results.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ),
        Text(
          'From ${_fromController.text} to ${_toController.text}',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
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
                onViewTrips: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TripSelectionPage(
                            routeId: route['id'] as int,
                            routeName: route['route_name'] as String,
                            from: _fromController.text,
                            to: _toController.text,
                          ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
