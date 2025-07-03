// lib/features/wallet/presentation/providers/wallet_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../data/datasource/wallet_datasource.dart';

class WalletProvider extends ChangeNotifier {
  final WalletDataSource walletDataSource;

  WalletProvider({required this.walletDataSource});

  // State variables
  bool _isLoading = false;
  bool _isTopingUp = false;
  bool _isProcessingPayment = false;
  String? _error;
  Wallet? _wallet;
  List<WalletTransaction>? _transactions;
  Map<String, dynamic>? _topupResult;

  // Getters
  bool get isLoading => _isLoading;
  bool get isTopingUp => _isTopingUp;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get error => _error;
  Wallet? get wallet => _wallet;
  List<WalletTransaction>? get transactions => _transactions;
  Map<String, dynamic>? get topupResult => _topupResult;

  double get balance => _wallet?.balance ?? 0.0;
  String get formattedBalance => _wallet?.formattedBalance ?? '0 TZS';
  bool get hasWallet => _wallet != null;
  bool get canAfford => _wallet?.hasSufficientBalance ?? false;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear topup result
  void clearTopupResult() {
    _topupResult = null;
    notifyListeners();
  }

  // Get wallet balance
  Future<void> getWalletBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final wallet = await walletDataSource.getWalletBalance();
      _wallet = wallet;
    } catch (e) {
      _error = e.toString();
      print('Wallet balance error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Top up wallet
  Future<bool> topUpWallet({
    required double amount,
    required String paymentMethod,
    String? phoneNumber,
  }) async {
    _isTopingUp = true;
    _error = null;
    _topupResult = null;
    notifyListeners();

    try {
      final result = await walletDataSource.topUpWallet(
        amount: amount,
        paymentMethod: paymentMethod,
        phoneNumber: phoneNumber,
      );

      if (paymentMethod == 'mobile_money') {
        // Store ZenoPay data for UI
        _topupResult = result.toJson();
      } else {
        // Update wallet balance for instant methods
        _wallet = result;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      print('Wallet topup error: $e');
      return false;
    } finally {
      _isTopingUp = false;
      notifyListeners();
    }
  }

  // Get wallet transactions
  Future<void> getWalletTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final transactions = await walletDataSource.getWalletTransactions();
      _transactions = transactions;
    } catch (e) {
      _error = e.toString();
      print('Wallet transactions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process wallet payment
  Future<bool> processWalletPayment({required int bookingId}) async {
    _isProcessingPayment = true;
    _error = null;
    notifyListeners();

    try {
      final updatedWallet = await walletDataSource.processWalletPayment(
        bookingId: bookingId,
      );
      _wallet = updatedWallet;
      return true;
    } catch (e) {
      _error = e.toString();
      print('Wallet payment error: $e');
      return false;
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  // Check if user can afford amount
  bool canAffordAmount(double amount) {
    return _wallet?.canAfford(amount) ?? false;
  }

  // Refresh wallet data
  Future<void> refreshWallet() async {
    await getWalletBalance();
    await getWalletTransactions();
  }
}
