import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/utils/extensions.dart';
import '../../../bookings/presentation/pages/booking_success_page.dart';

class PaymentPage extends StatefulWidget {
  final int bookingId;
  final double amount;
  final int tripId;
  final String routeName;
  final String from;
  final String to;
  final DateTime startTime;
  final int passengerCount;

  const PaymentPage({
    Key? key,
    required this.bookingId,
    required this.amount,
    required this.tripId,
    required this.routeName,
    required this.from,
    required this.to,
    required this.startTime,
    required this.passengerCount,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'mobile_money';
  bool _isWalletSelected = false;
  bool _isProcessing = false;
  
  // Wallet balance (this would come from API)
  final double _walletBalance = 25000.0;
  
  bool get _canPayWithWallet => _walletBalance >= widget.amount;
  
  @override
  void initState() {
    super.initState();
    // Check if wallet has enough balance and set it as default if true
    if (_canPayWithWallet) {
      _isWalletSelected = true;
    }
  }
  
  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
      _isWalletSelected = false;
    });
  }
  
  void _toggleWallet(bool value) {
    if (!_canPayWithWallet && value) {
      // Show insufficient balance message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient wallet balance. Please top up or choose another payment method.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isWalletSelected = value;
      if (value) {
        _selectedPaymentMethod = '';
      } else if (_selectedPaymentMethod.isEmpty) {
        _selectedPaymentMethod = 'mobile_money';
      }
    });
  }
  
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isProcessing = false;
    });
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessPage(
            bookingId: widget.bookingId,
            tripId: widget.tripId,
            routeName: widget.routeName,
            from: widget.from,
            to: widget.to,
            startTime: widget.startTime,
            amount: widget.amount,
            passengerCount: widget.passengerCount,
            paymentMethod: _isWalletSelected ? 'wallet' : _selectedPaymentMethod,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.amount.toPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
            
            const SizedBox(height: 24),
            
            // Wallet option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pay with Wallet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Balance: ${_walletBalance.toPrice}',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isWalletSelected,
                        onChanged: _toggleWallet,
                        activeColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  
                  if (!_canPayWithWallet) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Insufficient balance. You need to top up ${(widget.amount - _walletBalance).toPrice} more.',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to wallet top up
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Top Up Wallet'),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Other payment methods
            if (!_isWalletSelected) ...[
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              
              // Mobile Money options
              _PaymentMethodOption(
                name: 'M-Pesa',
                icon: Icons.phone_android,
                description: 'Pay with M-Pesa mobile money',
                isSelected: _selectedPaymentMethod == 'mobile_money',
                onTap: () => _selectPaymentMethod('mobile_money'),
              ),
              
              _PaymentMethodOption(
                name: 'Tigo Pesa',
                icon: Icons.phone_android,
                description: 'Pay with Tigo Pesa mobile money',
                isSelected: _selectedPaymentMethod == 'tigo_pesa',
                onTap: () => _selectPaymentMethod('tigo_pesa'),
              ),
              
              _PaymentMethodOption(
                name: 'Airtel Money',
                icon: Icons.phone_android,
                description: 'Pay with Airtel Money mobile money',
                isSelected: _selectedPaymentMethod == 'airtel_money',
                onTap: () => _selectPaymentMethod('airtel_money'),
              ),
              
              // Credit/Debit Card
              _PaymentMethodOption(
                name: 'Credit/Debit Card',
                icon: Icons.credit_card,
                description: 'Pay with your credit or debit card',
                isSelected: _selectedPaymentMethod == 'card',
                onTap: () => _selectPaymentMethod('card'),
              ),
              
              // Cash option
              _PaymentMethodOption(
                name: 'Cash',
                icon: Icons.money,
                description: 'Pay with cash to the driver',
                isSelected: _selectedPaymentMethod == 'cash',
                onTap: () => _selectPaymentMethod('cash'),
              ),
            ],
          ],
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
        child: CustomButton(
          text: _isProcessing ? 'Processing Payment...' : 'Pay Now',
          onPressed: _processPayment,
          isLoading: _isProcessing,
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String name;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    Key? key,
    required this.name,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}