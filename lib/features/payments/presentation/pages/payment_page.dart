// lib/features/payments/presentation/pages/payment_page.dart
import 'package:daladala_smart_app/features/payments/presentation/widgets/payment_method_option.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/payment_provider.dart';

class PaymentPage extends StatefulWidget {
  final int bookingId;
  final double amount;
  final String currency;

  const PaymentPage({
    super.key,
    required this.bookingId,
    required this.amount,
    this.currency = 'TZS',
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedPaymentMethod;
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate phone number for mobile money
    if (_selectedPaymentMethod == 'mobile_money') {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    // Show processing dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => PaymentProcessingDialog(
              paymentMethod: _selectedPaymentMethod!,
              amount: widget.amount,
              currency: widget.currency,
            ),
      );
    }

    try {
      final success = await paymentProvider.processPayment(
        bookingId: widget.bookingId,
        paymentMethod: _selectedPaymentMethod!,
        phoneNumber:
            _selectedPaymentMethod == 'mobile_money'
                ? _phoneController.text.trim()
                : null,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog

        if (success) {
          final payment = paymentProvider.currentPayment!;

          if (payment.isMobileMoneyPayment && payment.isPending) {
            // Show mobile money instructions dialog
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => MobileMoneyInstructionsDialog(
                    payment: payment,
                    onCheckStatus: () => _checkPaymentStatus(payment.id),
                  ),
            );
          } else if (payment.isCompleted) {
            // Show success dialog
            await showDialog(
              context: context,
              builder: (context) => PaymentSuccessDialog(payment: payment),
            );

            _navigateToSuccess();
          }
        } else {
          // Show error dialog
          await showDialog(
            context: context,
            builder:
                (context) => PaymentFailedDialog(
                  error: paymentProvider.error ?? 'Payment failed',
                  onRetry: _processPayment,
                ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
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

  Future<void> _checkPaymentStatus(int paymentId) async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    await paymentProvider.checkPaymentStatus(paymentId);

    final payment = paymentProvider.currentPayment;
    if (payment != null && payment.isCompleted) {
      if (mounted) {
        Navigator.of(context).pop(); // Close instructions dialog

        await showDialog(
          context: context,
          builder: (context) => PaymentSuccessDialog(payment: payment),
        );

        _navigateToSuccess();
      }
    }
  }

  void _navigateToSuccess() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/payment-success',
      (route) => false,
      arguments: {
        'payment_id':
            Provider.of<PaymentProvider>(
              context,
              listen: false,
            ).currentPayment?.id,
        'booking_id': widget.bookingId,
        'amount': widget.amount,
        'payment_method': _selectedPaymentMethod,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment amount card
              Container(
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
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.amount.toPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking ID: #${widget.bookingId}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Payment methods section
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Mobile Money options
              PaymentMethodOption(
                name: 'Mobile Money',
                icon: Icons.phone_android,
                description: 'Pay with M-Pesa, Tigo Pesa, or Airtel Money',
                isSelected: _selectedPaymentMethod == 'mobile_money',
                onTap: () => _selectPaymentMethod('mobile_money'),
                badge: 'Recommended',
                badgeColor: Colors.green,
              ),

              // Mobile Money phone input
              if (_selectedPaymentMethod == 'mobile_money') ...[
                const SizedBox(height: 16),
                MobileMoneyInput(
                  controller: _phoneController,
                  onChanged: (value) {
                    // Auto-detect provider based on phone number
                    setState(() {});
                  },
                ),
              ],

              const SizedBox(height: 12),

              // Credit/Debit Card
              PaymentMethodOption(
                name: 'Credit/Debit Card',
                icon: Icons.credit_card,
                description: 'Pay with Visa, Mastercard, or other cards',
                isSelected: _selectedPaymentMethod == 'card',
                onTap: () => _selectPaymentMethod('card'),
                enabled: false, // Disabled for now
                disabledMessage: 'Coming Soon',
              ),

              const SizedBox(height: 12),

              // Cash option
              PaymentMethodOption(
                name: 'Cash',
                icon: Icons.money,
                description: 'Pay with cash to the driver',
                isSelected: _selectedPaymentMethod == 'cash',
                onTap: () => _selectPaymentMethod('cash'),
              ),

              const SizedBox(height: 12),

              // Wallet option (if implemented)
              PaymentMethodOption(
                name: 'Daladala Wallet',
                icon: Icons.account_balance_wallet,
                description: 'Pay from your wallet balance',
                isSelected: _selectedPaymentMethod == 'wallet',
                onTap: () => _selectPaymentMethod('wallet'),
                enabled: false, // Disabled for now
                disabledMessage: 'Coming Soon',
              ),

              const SizedBox(height: 32),

              // Payment security info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue.shade600, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your payment is secured with industry-standard encryption',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 14,
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
            text: _isProcessing ? 'Processing...' : 'Pay Now',
            onPressed: (_selectedPaymentMethod == null || _isProcessing)
                ? null
                : () {
                    _processPayment();
                  },
            isLoading: _isProcessing,
            disabled: _selectedPaymentMethod == null,
          ),
        ),
      ),
    );
  }
}
