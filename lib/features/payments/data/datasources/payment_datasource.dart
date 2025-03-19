import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/constants.dart';
import '../models/payment_model.dart';

abstract class PaymentDataSource {
  /// Process a payment for a booking
  Future<PaymentModel> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  });
  
  /// Get payment history for the current user
  Future<List<PaymentModel>> getPaymentHistory();
  
  /// Get payment details by ID
  Future<PaymentModel> getPaymentDetails(int paymentId);
  
  /// Get wallet balance for the current user
  Future<double> getWalletBalance();
  
  /// Top up wallet
  Future<double> topUpWallet({
    required double amount,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  });
}

class PaymentDataSourceImpl implements PaymentDataSource {
  final DioClient dioClient;
  
  PaymentDataSourceImpl({required this.dioClient});
  
  @override
  Future<PaymentModel> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  }) async {
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
      
      final response = await dioClient.post(
        AppConstants.paymentsEndpoint,
        data: data,
      );
      
      if (response['status'] == 'success') {
        return PaymentModel.fromJson(response['data']);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<List<PaymentModel>> getPaymentHistory() async {
    try {
      final response = await dioClient.get('${AppConstants.paymentsEndpoint}/history');
      
      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((payment) => PaymentModel.fromJson(payment))
            .toList();
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<PaymentModel> getPaymentDetails(int paymentId) async {
    try {
      final response = await dioClient.get('${AppConstants.paymentsEndpoint}/$paymentId');
      
      if (response['status'] == 'success') {
        return PaymentModel.fromJson(response['data']);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<double> getWalletBalance() async {
    try {
      final response = await dioClient.get('${AppConstants.paymentsEndpoint}/wallet/balance');
      
      if (response['status'] == 'success') {
        return response['data']['balance']?.toDouble() ?? 0.0;
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<double> topUpWallet({
    required double amount,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final data = {
        'amount': amount,
        'payment_method': paymentMethod,
      };
      
      if (transactionId != null) {
        data['transaction_id'] = transactionId;
      }
      
      if (paymentDetails != null) {
        data['payment_details'] = paymentDetails;
      }
      
      final response = await dioClient.post(
        '${AppConstants.paymentsEndpoint}/wallet/topup',
        data: data,
      );
      
      if (response['status'] == 'success') {
        return response['data']['balance']?.toDouble() ?? 0.0;
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}