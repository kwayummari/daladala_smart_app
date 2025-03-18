import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/models/route.dart' as app_route;
import 'package:daladala_smart_app/models/stop.dart';
import 'package:daladala_smart_app/providers/trip_provider.dart';
import 'package:daladala_smart_app/screens/routes/route_detail_screen.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({Key? key}) : super(key: key);

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final _startPointController = TextEditingController();
  final _endPointController = TextEditingController();
  
  Stop? _selectedStartStop;
  Stop? _selectedEndStop;
  
  List<Stop> _startStopSuggestions = [];
  List<Stop> _endStopSuggestions = [];
  
  List<app_route.Route> _searchResults = [];
  bool _isSearching = false;
  String _searchError = '';
  
  bool _showStartSuggestions = false;
  bool _showEndSuggestions = false;
  
  @override
  void initState() {
    super.initState();
    _loadStops();
  }
  
  @override
  void dispose() {
    _startPointController.dispose();
    _endPointController.dispose();
    super.dispose();
  }
  
  Future<void> _loadStops() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.fetchStops();
  }
  
  Future<void> _searchStops(String query, bool isStartPoint) async {
    if (query.length < 2) {
      setState(() {
        if (isStartPoint) {
          _startStopSuggestions = [];
          _showStartSuggestions = false;
        } else {
          _endStopSuggestions = [];
          _showEndSuggestions = false;
        }
      });
      return;
    }
    
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final results = await tripProvider.searchStops(query);
    
    setState(() {
      if (isStartPoint) {
        _startStopSuggestions = results;
        _showStartSuggestions = true;
      } else {
        _endStopSuggestions = results;
        _showEndSuggestions = true;
      }
    });
  }
  
  Future<void> _searchRoutes() async {
    // Validate inputs
    if (_selectedStartStop == null || _selectedEndStop == null) {
      setState(() {
        _searchError = 'Please select both start and end points';
      });
      return;
    }
    
    if (_selectedStartStop!.stopId == _selectedEndStop!.stopId) {
      setState(() {
        _searchError = 'Start and end points cannot be the same';
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _searchError = '';
    });
    
    try {
      // First try to find routes directly using the stop names
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      final results = await tripProvider.searchRoutes(
        _selectedStartStop!.stopName,
        _selectedEndStop!.stopName,
      );
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Failed to search routes: ${e.toString()}';
        _isSearching = false;
      });
    }
  }
  
  void _selectStartStop(Stop stop) {
    setState(() {
      _selectedStartStop = stop;
      _startPointController.text = stop.stopName;
      _showStartSuggestions = false;
    });
  }
  
  void _selectEndStop(Stop stop) {
    setState(() {
      _selectedEndStop = stop;
      _endPointController.text = stop.stopName;
      _showEndSuggestions = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Routes'),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _showStartSuggestions = false;
            _showEndSuggestions = false;
          });
        },
        child: Column(
          children: [
            // Search Form
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start Point
                  TextField(
                    controller: _startPointController,
                    decoration: InputDecoration(
                      labelText: 'From',
                      hintText: 'Enter starting point',
                      prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                      suffixIcon: _startPointController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _startPointController.clear();
                                setState(() {
                                  _selectedStartStop = null;
                                  _showStartSuggestions = false;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => _searchStops(value, true),
                    onTap: () {
                      setState(() {
                        _showStartSuggestions = _startPointController.text.length >= 2;
                        _showEndSuggestions = false;
                      });
                    },
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  
                  // End Point
                  TextField(
                    controller: _endPointController,
                    decoration: InputDecoration(
                      labelText: 'To',
                      hintText: 'Enter destination',
                      prefixIcon: const Icon(Icons.location_on, color: AppColors.error),
                      suffixIcon: _endPointController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _endPointController.clear();
                                setState(() {
                                  _selectedEndStop = null;
                                  _showEndSuggestions = false;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => _searchStops(value, false),
                    onTap: () {
                      setState(() {
                        _showEndSuggestions = _endPointController.text.length >= 2;
                        _showStartSuggestions = false;
                      });
                    },
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  
                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSearching ? null : _searchRoutes,
                      icon: const Icon(Icons.search),
                      label: const Text('SEARCH ROUTES'),
                    ),
                  ),
                  
                  // Error Message
                  if (_searchError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.paddingMedium),
                      child: Text(
                        _searchError,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Suggestions or Results
            Expanded(
              child: Stack(
                children: [
                  // Start Point Suggestions
                  if (_showStartSuggestions)
                    _buildSuggestionsList(
                      _startStopSuggestions,
                      (stop) => _selectStartStop(stop),
                    ),
                  
                  // End Point Suggestions
                  if (_showEndSuggestions)
                    _buildSuggestionsList(
                      _endStopSuggestions,
                      (stop) => _selectEndStop(stop),
                    ),
                  
                  // Search Results or Initial State
                  if (!_showStartSuggestions && !_showEndSuggestions)
                    _isSearching
                        ? const Center(child: LoadingIndicator())
                        : _buildSearchResults(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionsList(List<Stop> suggestions, Function(Stop) onSelect) {
    if (suggestions.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: const Center(
          child: Text('No stops found. Try a different search term.'),
        ),
      );
    }
    
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final stop = suggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(stop.stopName),
            subtitle: stop.address != null && stop.address!.isNotEmpty
                ? Text(stop.address!)
                : null,
            trailing: stop.isMajor
                ? Chip(
                    label: const Text(
                      'Major Stop',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  )
                : null,
            onTap: () => onSelect(stop),
          );
        },
      ),
    );
  }
  
  Widget _buildSearchResults() {
    if (_selectedStartStop == null || _selectedEndStop == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus_outlined,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: AppSizes.marginMedium),
            const Text(
              'Search for routes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppSizes.marginSmall),
            const Text(
              'Enter your starting point and destination to find routes',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: AppSizes.marginMedium),
            const Text(
              'No routes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppSizes.marginSmall),
            Text(
              'No direct routes found from ${_selectedStartStop!.stopName} to ${_selectedEndStop!.stopName}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final route = _searchResults[index];
        return _buildRouteCard(route);
      },
    );
  }
  
  Widget _buildRouteCard(app_route.Route route) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreen(
                routeId: route.routeId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route number and name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route ${route.routeNumber}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          route.routeName,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              
              // Start and End Points
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: AppColors.primary,
                        size: 12,
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.startPoint,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          route.endPoint,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.marginMedium),
              
              // Bottom row with details and action button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (route.distanceKm != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.straighten,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route.distanceKm!.toStringAsFixed(1)} km',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                  
                  // View Details Button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RouteDetailScreen(
                            routeId: route.routeId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
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
}