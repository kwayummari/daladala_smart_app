import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/stop.dart';
import '../../domain/entities/fare.dart';
import '../../domain/usecases/get_all_routes_usecase.dart';
import '../../domain/usecases/get_route_stops_usecase.dart';
import '../../domain/usecases/get_route_fares_usecase.dart';
import '../../domain/usecases/search_routes_usecase.dart';

class RouteProvider extends ChangeNotifier {
  final GetAllRoutesUseCase getAllRoutesUseCase;
  final GetRouteStopsUseCase getRouteStopsUseCase;
  final GetRouteFaresUseCase? getRouteFaresUseCase;
  final SearchRoutesUseCase? searchRoutesUseCase;
  
  RouteProvider({
    required this.getAllRoutesUseCase,
    required this.getRouteStopsUseCase,
    this.getRouteFaresUseCase,
    this.searchRoutesUseCase,
  });
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  List<Route>? _routes;
  List<Route>? get routes => _routes;
  
  Route? _selectedRoute;
  Route? get selectedRoute => _selectedRoute;
  
  List<Stop>? _stops;
  List<Stop>? get stops => _stops;
  
  List<Fare>? _fares;
  List<Fare>? get fares => _fares;
  
  String? _error;
  String? get error => _error;
  
  // Get all routes
  Future<Either<Failure, List<Route>>> getAllRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await getAllRoutesUseCase(NoParams());
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (routes) {
        _routes = routes;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Get route stops
  Future<Either<Failure, List<Stop>>> getRouteStops(int routeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = GetRouteStopsParams(routeId: routeId);
    final result = await getRouteStopsUseCase(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (stops) {
        _stops = stops;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Get route fares
  Future<Either<Failure, List<Fare>>> getRouteFares(int routeId, {String? fareType}) async {
    if (getRouteFaresUseCase == null) {
      return Left(ServerFailure(message: 'Feature not implemented'));
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = GetRouteFaresParams(routeId: routeId, fareType: fareType);
    final result = await getRouteFaresUseCase!(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (fares) {
        _fares = fares;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Search routes
  Future<Either<Failure, List<Route>>> searchRoutes({
    String? startPoint,
    String? endPoint,
  }) async {
    if (searchRoutesUseCase == null) {
      return Left(ServerFailure(message: 'Feature not implemented'));
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = SearchRoutesParams(
      startPoint: startPoint,
      endPoint: endPoint,
    );
    final result = await searchRoutesUseCase!(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (routes) {
        _routes = routes;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Set selected route
  void setSelectedRoute(Route route) {
    _selectedRoute = route;
    notifyListeners();
  }
  
  // Clear selected route
  void clearSelectedRoute() {
    _selectedRoute = null;
    notifyListeners();
  }
  
  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Define the base entities stubs since we haven't implemented them yet
class Route {
  final int id;
  final String routeNumber;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final String? description;
  final double? distanceKm;
  final int? estimatedTimeMinutes;
  final String status;
  
  Route({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    this.description,
    this.distanceKm,
    this.estimatedTimeMinutes,
    required this.status,
  });
}

class Stop {
  final int id;
  final String stopName;
  final double latitude;
  final double longitude;
  final String? address;
  final bool isMajor;
  final String status;
  
  Stop({
    required this.id,
    required this.stopName,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.isMajor,
    required this.status,
  });
}

class Fare {
  final int id;
  final int routeId;
  final int startStopId;
  final int endStopId;
  final double amount;
  final String currency;
  final String fareType;
  final bool isActive;
  
  Fare({
    required this.id,
    required this.routeId,
    required this.startStopId,
    required this.endStopId,
    required this.amount,
    required this.currency,
    required this.fareType,
    required this.isActive,
  });
}

// Usecase parameter classes
class NoParams {}

class GetRouteStopsParams {
  final int routeId;
  
  GetRouteStopsParams({required this.routeId});
}

class GetRouteFaresParams {
  final int routeId;
  final String? fareType;
  
  GetRouteFaresParams({required this.routeId, this.fareType});
}

class SearchRoutesParams {
  final String? startPoint;
  final String? endPoint;
  
  SearchRoutesParams({this.startPoint, this.endPoint});
}