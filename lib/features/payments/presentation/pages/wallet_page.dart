import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isLoading = true;
  double _balance = 25000.0;
  
  // Sample transaction data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 1,
      'type': 'topup',
      'amount': 10000.0,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'description': 'Top-up via M-Pesa',
    },
    {
      'id': 2,
      'type': 'payment',
      'amount': 1500.0,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'Trip payment: Mbezi - CBD',
    },
    {
      'id': 3,
      'type': 'topup',
      'amount': 20000.0,
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'description': 'Top-up via M-Pesa',
    },
    {
      'id': 4,
      'type': 'payment',
      'amount': 2000.0,
      'date': DateTime.now().subtract(const Duration(days: 11)),
      'description': 'Trip payment: Tegeta - CBD',
    },
    {
      'id': 5,
      'type': 'payment',
      'amount': 1500.0,
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'description': 'Trip payment: Kimara - CBD',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }
  
  Future<void> _loadWalletData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  Container(
                    margin: const EdgeInsets.all(16),
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
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daladala Wallet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Balance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "TZS ${_balance.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Top Up',
                                icon: Icons.add,
                                onPressed: () {
                                  // Show top up options
                                  _showTopUpOptions();
                                },
                                type: ButtonType.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Transfer',
                                icon: Icons.send,
                                onPressed: () {
                                  // Navigate to transfer page
                                },
                                type: ButtonType.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Transaction history
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Transaction History',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // List of transactions
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      final isTopUp = transaction['type'] == 'topup';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isTopUp
                                    ? AppTheme.successColor.withOpacity(0.1)
                                    : AppTheme.warningColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTopUp ? Icons.add : Icons.shopping_cart,
                                color: isTopUp
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction['description'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    transaction['date'].toString().substring(0, 10),
                                    style: TextStyle(
                                      color: AppTheme.textTertiaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Amount
                            Text(
                              '${isTopUp ? '+' : '-'} TZS ${transaction['amount'].toStringAsFixed(0)}',
                              style: TextStyle(
                                color: isTopUp
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
  
  void _showTopUpOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Up Wallet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a payment method',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Payment options
              _PaymentOptionItem(
                icon: Icons.phone_android,
                title: 'M-Pesa',
                subtitle: 'Top up via M-Pesa mobile money',
                onTap: () {
                  Navigator.pop(context);
                  // Handle M-Pesa top up
                },
              ),
              _PaymentOptionItem(
                icon: Icons.phone_android,
                title: 'Tigo Pesa',
                subtitle: 'Top up via Tigo Pesa mobile money',
                onTap: () {
                  Navigator.pop(context);
                  // Handle Tigo Pesa top up
                },
              ),
              _PaymentOptionItem(
                icon: Icons.phone_android,
                title: 'Airtel Money',
                subtitle: 'Top up via Airtel Money mobile money',
                onTap: () {
                  Navigator.pop(context);
                  // Handle Airtel Money top up
                },
              ),
              _PaymentOptionItem(
                icon: Icons.credit_card,
                title: 'Credit/Debit Card',
                subtitle: 'Top up using your credit or debit card',
                onTap: () {
                  Navigator.pop(context);
                  // Handle card top up
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentOptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOptionItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}