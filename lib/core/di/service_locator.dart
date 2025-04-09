import 'package:daladala_smart_app/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:daladala_smart_app/features/bookings/domain/usecases/get_booking_details_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/bookings/data/datasources/booking_datasource.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/bookings/domain/usecases/create_booking_usecase.dart';
import '../../features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import '../../features/bookings/presentation/providers/booking_provider.dart';

import '../../features/routes/data/datasources/route_datasource.dart';
import '../../features/routes/data/repositories/route_repository_impl.dart';
import '../../features/routes/domain/repositories/route_repository.dart';
import '../../features/routes/domain/usecases/get_all_routes_usecase.dart';
import '../../features/routes/domain/usecases/get_route_stops_usecase.dart';
import '../../features/routes/presentation/providers/route_provider.dart';

import '../../features/payments/data/datasources/payment_datasource.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/payments/domain/usescases/process_payment_usecase.dart';
import '../../features/payments/domain/usescases/get_payment_history_usecase.dart';
import '../../features/payments/presentation/providers/payment_provider.dart';

import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/network_info.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

// Global GetIt instance
final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  
  // Storage
  getIt.registerSingleton<LocalStorage>(
    LocalStorageImpl(sharedPreferences: getIt<SharedPreferences>())
  );
  
  getIt.registerSingleton<SecureStorage>(
    SecureStorageImpl(secureStorage: getIt<FlutterSecureStorage>())
  );
  
  // Network
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl());
  
  getIt.registerSingleton<Dio>(Dio());
  
  getIt.registerSingleton<AuthInterceptor>(
    AuthInterceptor(
      secureStorage: getIt<SecureStorage>(),
    ),
  );
  
  getIt.registerSingleton<DioClient>(
    DioClient(
      dio: getIt<Dio>(),
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api',
      interceptors: [getIt<AuthInterceptor>()],
    ),
  );
  
  // Auth Feature
  getIt.registerSingleton<AuthDataSource>(
    AuthDataSourceImpl(dioClient: getIt<DioClient>())
  );
  
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      dataSource: getIt<AuthDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      secureStorage: getIt<SecureStorage>(),
      localStorage: getIt<LocalStorage>(),
    )
  );
  
  getIt.registerSingleton<LoginUseCase>(
    LoginUseCase(repository: getIt<AuthRepository>())
  );
  
  getIt.registerSingleton<RegisterUseCase>(
    RegisterUseCase(repository: getIt<AuthRepository>())
  );
  
  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(repository: getIt<AuthRepository>())
  );
  
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    )
  );
  
  // Bookings Feature
  getIt.registerSingleton<BookingDataSource>(
    // For debugging purposes, you can use the mock implementation
    // MockBookingDataSource()
    BookingDataSourceImpl(dioClient: getIt<DioClient>())
  );
  
  getIt.registerSingleton<BookingRepository>(
    BookingRepositoryImpl(
      dataSource: getIt<BookingDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    )
  );
  
  getIt.registerSingleton<GetUserBookingsUseCase>(
    GetUserBookingsUseCase(repository: getIt<BookingRepository>())
  );
  
  getIt.registerSingleton<GetBookingDetailsUseCase>(
    GetBookingDetailsUseCase(repository: getIt<BookingRepository>())
  );
  
  getIt.registerSingleton<CreateBookingUseCase>(
    CreateBookingUseCase(repository: getIt<BookingRepository>())
  );
  
  getIt.registerSingleton<CancelBookingUseCase>(
    CancelBookingUseCase(repository: getIt<BookingRepository>())
  );
  
  getIt.registerFactory<BookingProvider>(
    () => BookingProvider(
      getBookingDetailsUseCase: getIt<GetBookingDetailsUseCase>(),
      getUserBookingsUseCase: getIt<GetUserBookingsUseCase>(),
      createBookingUseCase: getIt<CreateBookingUseCase>(),
      cancelBookingUseCase: getIt<CancelBookingUseCase>(),
    )
  );
  
  // Routes Feature
  getIt.registerSingleton<RouteDataSource>(
    RouteDataSourceImpl(dioClient: getIt<DioClient>())
  );
  
  getIt.registerSingleton<RouteRepository>(
    RouteRepositoryImpl(
      dataSource: getIt<RouteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    )
  );
  
  getIt.registerSingleton<GetAllRoutesUseCase>(
    GetAllRoutesUseCase(repository: getIt<RouteRepository>())
  );
  
  getIt.registerSingleton<GetRouteStopsUseCase>(
    GetRouteStopsUseCase(repository: getIt<RouteRepository>())
  );
  
  getIt.registerFactory<RouteProvider>(
    () => RouteProvider(
      getAllRoutesUseCase: getIt<GetAllRoutesUseCase>(),
      getRouteStopsUseCase: getIt<GetRouteStopsUseCase>(),
    )
  );
  
  // Payments Feature
  getIt.registerSingleton<PaymentDataSource>(
    PaymentDataSourceImpl(dioClient: getIt<DioClient>())
  );
  
  getIt.registerSingleton<PaymentRepository>(
    PaymentRepositoryImpl(
      dataSource: getIt<PaymentDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    )
  );
  
  getIt.registerSingleton<ProcessPaymentUseCase>(
    ProcessPaymentUseCase(repository: getIt<PaymentRepository>())
  );
  
  getIt.registerSingleton<GetPaymentHistoryUseCase>(
    GetPaymentHistoryUseCase(repository: getIt<PaymentRepository>())
  );
  
  getIt.registerFactory<PaymentProvider>(
    () => PaymentProvider(
      processPaymentUseCase: getIt<ProcessPaymentUseCase>(),
      getPaymentHistoryUseCase: getIt<GetPaymentHistoryUseCase>(),
    )
  );
}