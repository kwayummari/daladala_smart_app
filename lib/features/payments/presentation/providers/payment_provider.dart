import 'package:daladala_smart_app/features/payments/domain/usescases/process_payment_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class PaymentProvider extends ChangeNotifier {
  final ProcessPaymentUseCase processPaymentUseCase;
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;
  final GetWalletBalanceUseCase? getWalletBalanceUseCase;
  
  PaymentProvider({
    required this.processPaymentUseCase,
    required this.getPaymentHistoryUseCase,
    this.getWalletBalanceUseCase,
  });
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  List<Payment>? _paymentHistory;
  List<Payment>? get paymentHistory => _paymentHistory;
  
  Payment? _currentPayment;
  Payment? get currentPayment => _currentPayment;
  
  double _walletBalance = 0.0;
  double get walletBalance => _walletBalance;
  
  String? _error;
  String? get error => _error;
  
  // Process payment
  Future<Either<Failure, Payment>> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = ProcessPaymentParams(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      paymentDetails: paymentDetails,
    );
    
    final result = await processPaymentUseCase(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (payment) {
        _currentPayment = payment;
        // Add to payment history if available
        if (_paymentHistory != null) {
          _paymentHistory = [payment, ..._paymentHistory!];
        }
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Get payment history
  Future<Either<Failure, List<Payment>>> getPaymentHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await getPaymentHistoryUseCase(NoParams());
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (payments) {
        _paymentHistory = payments;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Get wallet balance
  Future<Either<Failure, double>> getWalletBalance() async {
    if (getWalletBalanceUseCase == null) {
      return Left(ServerFailure(message: 'Feature not implemented'));
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await getWalletBalanceUseCase!(NoParams());
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (balance) {
        _walletBalance = balance;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Set wallet balance (for mock purposes)
  void setWalletBalance(double balance) {
    _walletBalance = balance;
    notifyListeners();
  }
  
  // Clear current payment
  void clearCurrentPayment() {
    _currentPayment = null;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Define the Payment entity stub since we haven't implemented it yet
class Payment {
  final int id;
  final int bookingId;
  final int userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? transactionId;
  final DateTime paymentTime;
  final String status;
  final Map<String, dynamic>? paymentDetails;
  
  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentTime,
    required this.status,
    this.paymentDetails,
  });
}

// Usecase parameter classes
class ProcessPaymentParams {
  final int bookingId;
  final String paymentMethod;
  final String? transactionId;
  final Map<String, dynamic>? paymentDetails;
  
  ProcessPaymentParams({
    required this.bookingId,
    required this.paymentMethod,
    this.transactionId,
    this.paymentDetails,
  });
}

class NoParams {}

class GetWalletBalanceUseCase {
  Future<Either<Failure, double>> call(NoParams params) async {
    // This would typically call a repository
    // For now, return a mock balance
    return Right(25000.0);
  }
}