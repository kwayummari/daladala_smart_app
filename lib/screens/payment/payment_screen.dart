import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/providers/booking_provider.dart';
import 'package:daladala_smart_app/providers/payment_provider.dart';
import 'package:daladala_smart_app/widgets/common/loading_indicator.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  
  const PaymentScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedPaymentMethod = 'mobile_money';
  final _phoneController = TextEditingController();
  final _transactionIdController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.fetchBookingDetails(widget.bookingId);
      
      // Check if booking is already paid
      if (bookingProvider.currentBooking?.isPaid ?? false) {
        // Navigate to success screen directly
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                bookingId: widget.bookingId,
              ),
            ),
          );
          return;
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load booking details: ${e.toString()}';
      });
    }
  }
  
  Future<void> _processPayment() async {
    // Validate inputs
    if (_selectedPaymentMethod == 'mobile_money') {
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your mobile money phone number'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      
      final success = await paymentProvider.processPayment(
        widget.bookingId,
        _selectedPaymentMethod,
        transactionId: _transactionIdController.text.isNotEmpty ? _transactionIdController.text : null,
      );
      
      if (success && mounted) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              bookingId: widget.bookingId,
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = paymentProvider.processingError;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to process payment: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Text(
                'Error',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSizes.marginLarge),
              ElevatedButton(
                onPressed: _loadBookingDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        final booking = bookingProvider.currentBooking;
        
        if (booking == null) {
          return const Center(
            child: Text('Booking not found'),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Info Header
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payment Amount',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${booking.fareAmount.toStringAsFixed(0)} TZS',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.marginSmall),
                      Text(
                        'Booking #${booking.bookingId}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.marginLarge),
              
              // Payment Methods
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              
              // Mobile Money
              _buildPaymentMethodCard(
                'mobile_money',
                'Mobile Money',
                'Pay using M-Pesa, Tigo Pesa, Airtel Money, etc.',
                Icons.phone_android,
              ),
              
              // Cash
              _buildPaymentMethodCard(
                'cash',
                'Cash',
                'Pay with cash to the driver when boarding',
                Icons.money,
              ),
              
              // Wallet
              _buildPaymentMethodCard(
                'wallet',
                'Wallet',
                'Pay using your Daladala Smart wallet balance',
                Icons.account_balance_wallet,
              ),
              
              const SizedBox(height: AppSizes.marginLarge),
              
              // Payment details form based on selected payment method
              if (_selectedPaymentMethod == 'mobile_money')
                _buildMobileMoneyForm(),
              else if (_selectedPaymentMethod == 'wallet')
                _buildWalletForm(),
              
              const SizedBox(height: AppSizes.marginLarge),
              
              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _selectedPaymentMethod == 'cash'
                        ? 'CONFIRM CASH PAYMENT'
                        : 'PAY NOW',
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.marginMedium),
              
              // Terms Text
              const Text(
                'By proceeding with the payment, you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPaymentMethodCard(
    String methodId,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedPaymentMethod == methodId;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = methodId;
          });
        },
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              // Radio button
              Radio<String>(
                value: methodId,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                activeColor: AppColors.primary,
              ),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.marginMedium),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMobileMoneyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Money Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Mobile Money Provider
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Mobile Money Provider',
            border: OutlineInputBorder(),
          ),
          value: 'mpesa',
          items: const [
            DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
            DropdownMenuItem(value: 'tigopesa', child: Text('Tigo Pesa')),
            DropdownMenuItem(value: 'airtelmoney', child: Text('Airtel Money')),
            DropdownMenuItem(value: 'halopesa', child: Text('Halo Pesa')),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Phone Number
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your mobile money phone number',
            border: OutlineInputBorder(),
            prefixText: '+255 ',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1. Enter your mobile money phone number above',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '2. Click "PAY NOW" button below',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '3. Wait for a payment prompt on your phone',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '4. Enter your PIN to complete the payment',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWalletForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wallet Payment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Wallet Balance
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Column(
            children: [
              const Text(
                'Current Wallet Balance',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '12,500 TZS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Show top-up dialog or navigate to top-up screen
                    },
                    child: const Text('TOP UP WALLET'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.marginMedium),
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1. Ensure you have sufficient balance in your wallet',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '2. Click "PAY NOW" button to complete the payment',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}