import 'package:daladala_smart_app/services/api_service.dart';
import 'package:flutter/foundation.dart';

class QRProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentQRData;
  Map<String, dynamic>? _lastScanResult;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentQRData => _currentQRData;
  Map<String, dynamic>? get lastScanResult => _lastScanResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Generate booking QR code
  Future<void> generateBookingQR(int bookingId) async {
    _setLoading(true);
    try {
      final response = await ApiService.generateBookingQRCode(bookingId);
      final result = ApiService.handleResponse(response);
      
      if (result['success']) {
        _currentQRData = result['data']['data'];
        _error = null;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Failed to generate QR code: $e';
    }
    _setLoading(false);
  }

  // Get booking receipt
  Future<void> getBookingReceipt(int bookingId) async {
    _setLoading(true);
    try {
      // This would be a new API endpoint for getting booking receipt
      // For now, we'll simulate the response
      await Future.delayed(const Duration(seconds: 1));
      
      _currentQRData = {
        'receipt_number': 'DLS-BKG-20250710-000123',
        'amount': '3000.00',
        'qr_code': 'receipt_qr_data_here',
        'created_at': DateTime.now().toIso8601String(),
      };
      _error = null;
    } catch (e) {
      _error = 'Failed to get receipt: $e';
    }
    _setLoading(false);
  }

  // Validate ticket QR code
  Future<void> validateTicket(String qrData) async {
    _setLoading(true);
    try {
      final response = await ApiService.validateTicket(qrData);
      final result = ApiService.handleResponse(response);
      
      _lastScanResult = {
        'type': 'ticket',
        'valid': result['success'],
        'data': result['data'],
        'message': result['success'] ? 'Valid ticket' : result['error'],
      };
      
      _error = result['success'] ? null : result['error'];
    } catch (e) {
      _lastScanResult = {
        'type': 'ticket',
        'valid': false,
        'message': 'Failed to validate ticket',
      };
      _error = 'Failed to validate ticket: $e';
    }
    _setLoading(false);
  }

  // Verify receipt QR code
  Future<void> verifyReceipt(String qrData) async {
    _setLoading(true);
    try {
      // This would be a new API endpoint for receipt verification
      await Future.delayed(const Duration(seconds: 1));
      
      _lastScanResult = {
        'type': 'receipt',
        'valid': true,
        'data': {
          'receipt_number': 'DLS-BKG-20250710-000123',
          'amount': '3000.00',
          'customer_name': 'John Doe',
          'created_at': DateTime.now().toIso8601String(),
        },
        'message': 'Valid receipt',
      };
      _error = null;
    } catch (e) {
      _lastScanResult = {
        'type': 'receipt',
        'valid': false,
        'message': 'Failed to verify receipt',
      };
      _error = 'Failed to verify receipt: $e';
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}