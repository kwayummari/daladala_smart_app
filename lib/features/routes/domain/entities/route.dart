import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
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
    
    final result = await getAllRoutesUseCase(const NoParams());
    
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
    
    final params = SearchRoutesParams(startPoint: startPoint, endPoint: endPoint);
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