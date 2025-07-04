// lib/features/payments/presentation/providers/payment_provider.dart
import 'dart:async';
import 'package:daladala_smart_app/core/error/failures.dart';
import 'package:daladala_smart_app/core/usecases/usecase.dart';
import 'package:daladala_smart_app/features/payments/domain/usescases/check_payment_status_usecase.dart';
import 'package:daladala_smart_app/features/payments/domain/usescases/get_payment_details_usecase.dart';
import 'package:daladala_smart_app/features/payments/domain/usescases/get_payment_history_usecase.dart';
import 'package:daladala_smart_app/features/payments/domain/usescases/process_payment_usecase.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';

class PaymentProvider extends ChangeNotifier {
  final ProcessPaymentUseCase processPaymentUseCase;
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;
  final GetPaymentDetailsUseCase? getPaymentDetailsUseCase;
  final CheckPaymentStatusUseCase? checkPaymentStatusUseCase;

  PaymentProvider({
    required this.processPaymentUseCase,
    required this.getPaymentHistoryUseCase,
    this.getPaymentDetailsUseCase,
    this.checkPaymentStatusUseCase,
  });

  // State variables
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  bool _isCheckingStatus = false;
  String? _error;
  List<Payment>? _paymentHistory;
  Payment? _currentPayment;
  Payment? _paymentDetails;
  Timer? _statusCheckTimer;

  // Getters
  bool get isLoading => _isLoading;
  bool get isProcessingPayment => _isProcessingPayment;
  bool get isCheckingStatus => _isCheckingStatus;
  String? get error => _error;
  List<Payment>? get paymentHistory => _paymentHistory;
  Payment? get currentPayment => _currentPayment;
  Payment? get paymentDetails => _paymentDetails;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear current payment
  void clearCurrentPayment() {
    _currentPayment = null;
    _stopStatusChecking();
    notifyListeners();
  }

  // Process payment
  Future<bool> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? phoneNumber,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    _isProcessingPayment = true;
    _error = null;
    notifyListeners();

    try {
      final result = await processPaymentUseCase(
        ProcessPaymentParams(
          bookingId: bookingId,
          paymentMethod: paymentMethod,
          phoneNumber: phoneNumber,
          transactionId: transactionId,
          paymentDetails: paymentDetails,
        ),
      );

      return result.fold(
        (failure) {
          _error = _getFailureMessage(failure);
          _isProcessingPayment = false;
          notifyListeners();
          return false;
        },
        (payment) {
          _currentPayment = payment;
          _isProcessingPayment = false;
          notifyListeners();

          // Start status checking for mobile money payments
          if (payment.isMobileMoneyPayment && payment.isPending) {
            _startStatusChecking(payment.id);
          }

          return true;
        },
      );
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isProcessingPayment = false;
      notifyListeners();
      return false;
    }
  }

  // Get payment history
  Future<void> getPaymentHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await getPaymentHistoryUseCase(NoParams());

      result.fold(
        (failure) {
          _error = _getFailureMessage(failure);
          _isLoading = false;
          notifyListeners();
        },
        (payments) {
          _paymentHistory = payments;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get payment details
  Future<void> getPaymentDetails(int paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await getPaymentDetailsUseCase!(
        GetPaymentDetailsParams(paymentId: paymentId),
      );

      result.fold(
        (failure) {
          _error = _getFailureMessage(failure);
          _isLoading = false;
          notifyListeners();
        },
        (payment) {
          _paymentDetails = payment;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check payment status manually
  Future<void> checkPaymentStatus(int paymentId) async {
    _isCheckingStatus = true;
    _error = null;
    notifyListeners();

    try {
      final result = await checkPaymentStatusUseCase!(
        CheckPaymentStatusParams(paymentId: paymentId),
      );

      result.fold(
        (failure) {
          _error = _getFailureMessage(failure);
          _isCheckingStatus = false;
          notifyListeners();
        },
        (payment) {
          _currentPayment = payment;
          _isCheckingStatus = false;
          notifyListeners();

          // Stop status checking if payment is completed or failed
          if (!payment.isPending) {
            _stopStatusChecking();
          }
        },
      );
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isCheckingStatus = false;
      notifyListeners();
    }
  }

  // Start automatic status checking for mobile money payments
  void _startStatusChecking(int paymentId) {
    _stopStatusChecking(); // Clear any existing timer

    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 10), // Check every 10 seconds
      (timer) async {
        await checkPaymentStatus(paymentId);

        // Stop checking after 5 minutes or if payment is not pending
        if (timer.tick >= 30 || // 30 * 10 seconds = 5 minutes
            _currentPayment?.isPending != true) {
          _stopStatusChecking();
        }
      },
    );
  }

  // Stop automatic status checking
  void _stopStatusChecking() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  // Get failure message
  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message ?? 'Server error occurred';
      case NetworkFailure _:
        return 'No internet connection';
      case AuthenticationFailure _:
        return 'Authentication failed. Please login again';
      case InputFailure _:
        return failure.message ?? 'Invalid input provided';
      case NotFoundFailure _:
        return 'Payment not found';
      default:
        return failure.message ?? 'An unexpected error occurred';
    }
  }

  @override
  void dispose() {
    _stopStatusChecking();
    super.dispose();
  }
}


class GetPaymentDetailsParams {
  final int paymentId;

  GetPaymentDetailsParams({required this.paymentId});
}

class CheckPaymentStatusParams {
  final int paymentId;

  CheckPaymentStatusParams({required this.paymentId});
}

