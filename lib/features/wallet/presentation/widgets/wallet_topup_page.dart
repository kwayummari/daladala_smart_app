import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../payments/presentation/widgets/payment_method_option.dart';
import '../providers/wallet_provider.dart';

class WalletTopUpPage extends StatefulWidget {
  const WalletTopUpPage({super.key});

  @override
  State<WalletTopUpPage> createState() => _WalletTopUpPageState();
}

class _WalletTopUpPageState extends State<WalletTopUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _customAmountController = TextEditingController();

  String _selectedPaymentMethod = 'mobile_money';
  double? _selectedAmount;
  bool _isProcessing = false;

  final List<double> _quickAmounts = [5000, 10000, 20000, 50000, 100000];

  @override
  void dispose() {
    _phoneController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _selectAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _customAmountController.clear();
    });
  }

  void _onCustomAmountChanged(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _selectedAmount = double.tryParse(value);
      });
    } else {
      setState(() {
        _selectedAmount = null;
      });
    }
  }

  Future<void> _processTopUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAmount == null || _selectedAmount! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Processing Top-up',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Processing your ${_getPaymentMethodName(_selectedPaymentMethod)} top-up of ${_selectedAmount!.toStringAsFixed(0)} TZS...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
    );

    try {
      final success = await walletProvider.topUpWallet(
        amount: _selectedAmount!,
        paymentMethod: _selectedPaymentMethod,
        phoneNumber:
            _selectedPaymentMethod == 'mobile_money'
                ? _phoneController.text.trim()
                : null,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog

        if (success) {
          if (_selectedPaymentMethod == 'mobile_money') {
            // Show mobile money instructions
            await _showMobileMoneyInstructions(walletProvider.topupResult);
          } else {
            // Show success dialog
            await _showSuccessDialog();
            Navigator.of(context).pop(); // Go back to wallet
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(walletProvider.error ?? 'Top-up failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Top-up failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'mobile_money':
        return 'mobile money';
      case 'card':
        return 'card';
      case 'bank_transfer':
        return 'bank transfer';
      default:
        return method;
    }
  }

  Future<void> _showMobileMoneyInstructions(
    Map<String, dynamic>? topupData,
  ) async {
    if (topupData == null) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Complete Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_android,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'A USSD prompt has been sent to your phone. Please follow the instructions to complete the payment.',
                  textAlign: TextAlign.center,
                ),
                if (topupData['zenopay_data']?['reference'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Reference: ${topupData['zenopay_data']['reference']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to wallet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Top-up Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 48,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your wallet has been topped up with ${_selectedAmount!.toStringAsFixed(0)} TZS',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance
              Consumer<WalletProvider>(
                builder: (context, walletProvider, child) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          walletProvider.formattedBalance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Amount Selection
              const Text(
                'Select Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Quick amount buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    _quickAmounts.map((amount) {
                      final isSelected = _selectedAmount == amount;
                      return InkWell(
                        onTap: () => _selectAmount(amount),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '${amount.toStringAsFixed(0)} TZS',
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              // Custom amount input
              const Text(
                'Or enter custom amount:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _customAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixText: 'TZS ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount < 1000) {
                      return 'Minimum amount is 1,000 TZS';
                    }
                    if (amount > 1000000) {
                      return 'Maximum amount is 1,000,000 TZS';
                    }
                  }
                  return null;
                },
                onChanged: _onCustomAmountChanged,
              ),

              const SizedBox(height: 32),

              // Payment Method
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              PaymentMethodOption(
                name: 'Mobile Money',
                icon: Icons.phone_android,
                description: 'Pay with M-Pesa, Tigo Pesa, or Airtel Money',
                isSelected: _selectedPaymentMethod == 'mobile_money',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'mobile_money';
                  });
                },
                badge: 'Recommended',
                badgeColor: Colors.green,
              ),

              if (_selectedPaymentMethod == 'mobile_money') ...[
                const SizedBox(height: 16),
                MobileMoneyInput(
                  controller: _phoneController,
                  onChanged: (value) {
                    // Auto-detect provider
                    setState(() {});
                  },
                ),
              ],

              const SizedBox(height: 16),

              PaymentMethodOption(
                name: 'Bank Transfer',
                icon: Icons.account_balance,
                description: 'Transfer from your bank account',
                isSelected: _selectedPaymentMethod == 'bank_transfer',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'bank_transfer';
                  });
                },
                enabled: false,
                disabledMessage: 'Coming Soon',
              ),

              const SizedBox(height: 16),

              PaymentMethodOption(
                name: 'Credit/Debit Card',
                icon: Icons.credit_card,
                description: 'Pay with your card',
                isSelected: _selectedPaymentMethod == 'card',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'card';
                  });
                },
                enabled: false,
                disabledMessage: 'Coming Soon',
              ),

              const SizedBox(height: 32),

              // Terms and conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Top-up may take a few minutes to reflect in your wallet balance.',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            text:
                _isProcessing
                    ? 'Processing...'
                    : 'Top Up ${_selectedAmount != null ? _selectedAmount!.toStringAsFixed(0) : "0"} TZS',
            onPressed:
                _selectedAmount == null || _isProcessing ? null : _processTopUp,
            isLoading: _isProcessing,
            disabled: _selectedAmount == null,
          ),
        ),
      ),
    );
  }
}
