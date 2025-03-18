import 'package:flutter/foundation.dart';
import 'package:daladala_smart_app/config/api_config.dart';
import 'package:daladala_smart_app/models/booking.dart';
import 'package:daladala_smart_app/services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Payment> _paymentHistory = [];
  bool _historyLoading = false;
  String _historyError = '';
  
  Payment? _currentPayment;
  bool _currentPaymentLoading = false;
  String _currentPaymentError = '';
  
  // Process status
  bool _processing = false;
  String _processingError = '';
  
  // Getters
  List<Payment> get paymentHistory => _paymentHistory;
  bool get historyLoading => _historyLoading;
  String get historyError => _historyError;
  
  Payment? get currentPayment => _currentPayment;
  bool get currentPaymentLoading => _currentPaymentLoading;
  String get currentPaymentError => _currentPaymentError;
  
  bool get processing => _processing;
  String get processingError => _processingError;
  
  // Process payment
  Future<bool> processPayment(int bookingId, String paymentMethod, {String? transactionId, Map<String, dynamic>? paymentDetails}) async {
    _processing = true;
    _processingError = '';
    notifyListeners();
    
    try {
      final data = {
        'booking_id': bookingId,
        'payment_method': paymentMethod,
      };
      
      if (transactionId != null) {
        data['transaction_id'] = transactionId;
      }
      
      if (paymentDetails != null) {
        data['payment_details'] = paymentDetails;
      }
      
      final response = await _apiService.post<Payment>(
        ApiConfig.payments,
        data: data,
        fromJson: (json) => Payment.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        _currentPayment = response.data;
        await fetchPaymentHistory(); // Refresh payment history
        _processing = false;
        notifyListeners();
        return true;
      } else {
        _processingError = response.message;
        _processing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _processingError = 'Failed to process payment: ${e.toString()}';
      _processing = false;
      notifyListeners();
      return false;
    }
  }
  
  // Fetch payment history
  Future<void> fetchPaymentHistory() async {
    _historyLoading = true;
    _historyError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get<List<Payment>>(
        ApiConfig.paymentHistory,
        fromJsonList: (jsonList) => 
            jsonList.map((json) => Payment.fromJson(json)).toList(),
      );
      
      if (response.success && response.data != null) {
        _paymentHistory = response.data!;
      } else {
        _historyError = response.message;
      }
    } catch (e) {
      _historyError = 'Failed to fetch payment history: ${e.toString()}';
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch payment details
  Future<void> fetchPaymentDetails(int paymentId) async {
    _currentPaymentLoading = true;
    _currentPaymentError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get<Payment>(
        '${ApiConfig.paymentById}/$paymentId',
        fromJson: (json) => Payment.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        _currentPayment = response.data;
      } else {
        _currentPaymentError = response.message;
      }
    } catch (e) {
      _currentPaymentError = 'Failed to fetch payment details: ${e.toString()}';
    } finally {
      _currentPaymentLoading = false;
      notifyListeners();
    }
  }
  
  // Get payment for booking (convenience method)
  Future<Payment?> getPaymentForBooking(int bookingId) async {
    try {
      // First check current payment history
      final payment = _paymentHistory.firstWhere(
        (p) => p.bookingId == bookingId,
        orElse: () => Payment(
          paymentId: -1,
          bookingId: -1,
          userId: -1,
          amount: 0,
          currency: '',
          paymentMethod: '',
          paymentTime: '',
          status: '',
        ),
      );
      
      if (payment.paymentId != -1) {
        return payment;
      }
      
      // If not found, fetch payment history and try again
      await fetchPaymentHistory();
      
      return _paymentHistory.firstWhere(
        (p) => p.bookingId == bookingId,
        orElse: () => throw Exception('Payment not found'),
      );
    } catch (e) {
      debugPrint('Failed to get payment for booking: ${e.toString()}');
      return null;
    }
  }
}