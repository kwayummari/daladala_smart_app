import 'package:daladala_smart_app/features/routes/presentation/pages/stop_detail_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomeNearbyStops extends StatefulWidget {
  const HomeNearbyStops({Key? key}) : super(key: key);

  @override
  State<HomeNearbyStops> createState() => _HomeNearbyStopsState();
}

class _HomeNearbyStopsState extends State<HomeNearbyStops> {
  bool _isLoading = true;
  
  // Sample data for demonstration purposes
  final List<Map<String, dynamic>> _stops = [
    {
      'id': 1,
      'name': 'Mwenge Bus Terminal',
      'distance': 0.3,
      'routes': 8,
      'is_major': true,
    },
    {
      'id': 2,
      'name': 'Ubungo Bus Terminal',
      'distance': 0.7,
      'routes': 12,
      'is_major': true,
    },
    {
      'id': 4,
      'name': 'Posta CBD',
      'distance': 1.2,
      'routes': 10,
      'is_major': true,
    },
    {
      'id': 3,
      'name': 'Morocco',
      'distance': 1.5,
      'routes': 6,
      'is_major': false,
    },
    {
      'id': 5,
      'name': 'Magomeni',
      'distance': 2.0,
      'routes': 4,
      'is_major': false,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadNearbyStops();
  }
  
  Future<void> _loadNearbyStops() async {
    // Simulate API call with a delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Stops',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to see all nearby stops
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _stops.length,
                itemBuilder: (context, index) {
                  final stop = _stops[index];
                  return _NearbyStopItem(
                    id: stop['id'],
                    name: stop['name'],
                    distance: stop['distance'],
                    routes: stop['routes'],
                    isMajor: stop['is_major'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StopDetailPage(stopId: stop['id']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NearbyStopItem extends StatelessWidget {
  final int id;
  final String name;
  final double distance;
  final int routes;
  final bool isMajor;
  final VoidCallback onTap;

  const _NearbyStopItem({
    Key? key,
    required this.id,
    required this.name,
    required this.distance,
    required this.routes,
    required this.isMajor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top part with name and distance
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppTheme.textTertiaryColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            const Divider(height: 1),
            
            // Bottom part with routes info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$routes Routes',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isMajor ? 'Major Terminal' : 'Regular Stop',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}